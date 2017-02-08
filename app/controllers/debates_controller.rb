class DebatesController < ApplicationController
  before_action :redirect_to_plaza, only: :show

  include FeatureFlags
  include CommentableActions
  include FlagActions

  before_action :parse_search_terms, only: [:index, :suggest]
  before_action :parse_advanced_search_terms, only: :index
  before_action :parse_tag_filter, only: :index
  before_action :set_search_order, only: :index
  before_action :authenticate_user!, except: [:index, :show, :map]

  feature_flag :debates

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w{hot_score confidence_score created_at relevance}, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def index_customization
    @featured_debates = @debates.featured
    @proposal_successfull_exists = Proposal.successful.exists?
    discard_probe_debates
  end

  def show
    super
    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)
  end

  def vote
    @debate.register_vote(current_user, params[:value])
    set_debate_votes(@debate)
    log_event("debate", "vote", I18n.t("tracking.events.name.#{params[:value]}"))
  end

  def unmark_featured
    @debate.update_attribute(:featured_at, nil)
    redirect_to request.query_parameters.merge(action: :index)
  end

  def mark_featured
    @debate.update_attribute(:featured_at, Time.current)
    redirect_to request.query_parameters.merge(action: :index)
  end

  def discard_probe_debates
    @resources = @resources.not_probe
  end

  private

    def debate_params
      params.require(:debate).permit(:title, :description, :tag_list, :comment_kind, :terms_of_service)
    end

    def resource_model
      Debate
    end

    def redirect_to_plaza
      plaza = Probe.where(codename: 'plaza').first
      probe_option = ProbeOption.where(probe: plaza, debate_id: params[:id]).first
      if probe_option.present?
        redirect_to plaza_probe_option_path(probe_option, anchor: 'comments')
      end
    end

end
