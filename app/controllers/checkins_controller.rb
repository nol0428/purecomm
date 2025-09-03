class CheckinsController < ApplicationController
  def new
    @checkin = Checkin.new
    @partnership = Partnership.find(params[:partnership_id])
  end

  def edit
    @checkin = Checkin.find(params[:id])
    @partnership = Partnership.find(params[:partnership_id])
  end

  def create
    @partnership = Partnership.find(params[:partnership_id])
    @checkin = Checkin.new(checkin_params)
    @checkin.user = current_user
    @checkin.partnership = @partnership

    if @checkin.save
      redirect_to checkin_path(@checkin)
    else
      redirect_to partnership_path(@partnership), alert: "You already checked-in today"
    end
  end

  def update
    @checkin = Checkin.find(params[:id])
    if @checkin.update(checkin_params)
      if @checkin.nudge.nil?
        redirect_to checkin_path(@checkin)
      else
        redirect_to partnership_path(@checkin.partnership), notice: "Checked-in!"
      end
    else
      @partnership = @checkin.partnership
      @times = [
        ['Now', Time.now],
        ['1 Hours', Time.now + 1.hour],
        ['2 Hours', Time.now + 2.hours],
        ['3 Hours', Time.now + 3.hours],
        ['6 Hours', Time.now + 6.hours],
        ['12 Hours', Time.now + 12.hours]
      ]
      render 'show', status: :unprocessable_entity
    end
  end

  def show
    @checkin     = Checkin.find(params[:id])
    @partnership = @checkin.partnership
    if @checkin.user_id != current_user.id
      CheckinRead.find_or_create_by!(user: current_user, checkin: @checkin) do |cr|
        cr.read_at = Time.current
      end
    end
  end

  def badge
    partnership   = current_user.current_partnership
    partner_scope = partnership.checkins.where.not(user_id: current_user.id)
    read_ids      = CheckinRead.where(user_id: current_user.id, checkin_id: partner_scope.select(:id))
                               .pluck(:checkin_id)
    @count        = partner_scope.where.not(id: read_ids).count
    render :badge
  end

  private

  def checkin_params
    params.require(:checkin).permit(:mood, :my_day, :discuss, :comment, :nudge)
  end
end
