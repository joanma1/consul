class Officing::PinController < Officing::BaseController
  skip_before_action :authenticate_user!
  skip_before_action :verify_officer

  layout "nvotes"

  def new
    sign_out
    @pin = ""
  end

  def create
    @officer = Poll::Officer.first
    sign_in(:user, @officer.user)
    redirect_to new_officing_poll_voter_path
  end

end