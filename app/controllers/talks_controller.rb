class TalksController < ApplicationController

  def index
    @partnership = Partnership.find(params[:partnership_id])
    @talks = @partnership.talks
  end
end
