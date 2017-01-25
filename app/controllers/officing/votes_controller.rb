class Officing::VotesController < Officing::BaseController
  skip_before_action :verify_officer
  skip_authorization_check

  layout "nvotes"

  def new
    @poll = Poll.first
  end

end