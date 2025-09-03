class Partnership < ApplicationRecord
  belongs_to :user_one, class_name: "User"
  belongs_to :user_two, class_name: "User"

  has_many :checkins, dependent: :destroy
  has_many :grievances, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :talks, dependent: :destroy
  has_one :chat, dependent: :destroy

  BAD_MOODS = Checkin::BAD_MOODS

  def partner_of(user)
    user_one == user ? user_two : user_one
  end

  # NEW: helper to always have a Chat ready
  def ensure_chat!
    chat || create_chat!(
      model_id: ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini")
    )
  end

  def unread_checkins_count_for(user)
    checkins.left_joins(:checkin_reads).where.not(user_id: user.id).where(checkin_reads: { id: nil }).count
  end

  def recent_bad_mood_ratio(days: 7)
    start = days.days.ago
    scope = checkins.where("created_at >= ?", start)
    total = scope.count
    return 0.0 if total.zero?

    bad = scope.where(mood: BAD_MOODS).count
    bad.to_f / total
  end

  def health_status_for(user, days: 7)
    unread = unread_checkins_count_for(user)
    ratio  = recent_bad_mood_ratio(days: days)

    level =
      if unread >= 5 || ratio >= 0.6 then :danger
      elsif unread >= 3 || ratio >= 0.4 then :warning
      elsif unread >= 1 || ratio >= 0.2 then :info
      else :ok
      end

    { level: level, unread: unread, ratio: ratio.round(2), days: days }
  end
end
