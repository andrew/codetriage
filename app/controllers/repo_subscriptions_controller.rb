class RepoSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    repo = Repo.find(params[:repo_id])
    @repo_subscription = current_user.repo_subscriptions.new repo: repo
    if @repo_subscription.save
      SendSingleTriageEmailJob.perform_later(@repo_subscription.id)
      redirect_to repo, notice: I18n.t('repo_subscriptions.subscribed')
    else
      flash[:error] = "Something went wrong"
      redirect_to repo_path(repo)
    end
  end

  def destroy
    @repo_sub = current_user.repo_subscriptions.find params[:id]
    repo = @repo_sub.repo
    @repo_sub.destroy
    redirect_to repo_path(repo)
  end

  def update
    @repo_sub = current_user.repo_subscriptions.find params[:id]
    if @repo_sub.update_attributes(repo_subscription_params)
      flash[:success] = "Email preferences updated!"
    else
      flash[:error] = "Something went wrong"
    end
    redirect_to repo_path(@repo_sub.repo)
  end

  private

    def repo_subscription_params
      params.require(:repo_subscription).permit(
        :email_limit
        )
    end
end
