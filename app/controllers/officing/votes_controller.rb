class Officing::VotesController < Officing::BaseController
  skip_before_action :verify_officer

  layout "nvotes"

  def new
    @poll = Poll.first
  end

end