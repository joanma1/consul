class Officing::VotersController < Officing::BaseController

  def new
    @voter = Poll::Voter.new
  end

  def show
  end

  def create
    #create_voter
    sign_in_voter
    if true#officer.has_tablet?
      redirect_to new_officing_poll_vote_path
    end
  end

  private

    def sign_in_voter
      @voter = Poll::Voter.first
      sign_out
      sign_in(:user, @voter.user)
    end

end