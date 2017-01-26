class Officing::VotersController < Officing::BaseController

  def new
    @voter = Poll::Voter.new
  end

  def show
    @voter = Poll::Voter.first.user
    @polls = Poll.limit(3)
    #@polls = Poll.answerable_by(@voter.user)
  end

  def create
    #@voter = Poll::Voter.new(poll_voter_params)
    @voter = Poll::Voter.first
    @poll = Poll.first
    if @voter.save
      redirect_to officing_poll_voter_path(@poll, @voter)
    else
      render :new
    end
  end

  def vote_with_tablet
    sign_in_voter
    redirect_to new_officing_poll_vote_path
  end

  def vote_in_booth
    @voter = Poll::Voter.new
    #@voter.update(voted_at: Time.now)
    redirect_to new_officing_poll_voter_path
  end

  private

    def poll_voter_params
    end

    def sign_in_voter
      @voter = Poll::Voter.first
      sign_out
      sign_in(:user, @voter.user)
    end

end