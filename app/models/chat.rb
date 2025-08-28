class Chat < ApplicationRecord
  belongs_to :partnership
  has_many :messages, dependent: :destroy

  before_validation :set_default_model

  private

  def set_default_model
    # Make sure the chat always knows which model to use
    self.model_id ||= ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini")
  end
end
