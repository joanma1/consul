class Officing::VotesController < Officing::BaseController
  skip_before_action :verify_officer

  layout "nvotes"

  def new
    @poll = Poll.first
  end

  #Agora Callback
  def create
    sign_out
    redirect_to new_officing_poll_pin_path
  end

end