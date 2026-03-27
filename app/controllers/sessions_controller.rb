class SessionsController < ApplicationController
  require_authentication only: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    magic_token = MagicToken.generate_for(params[:email_address])
    SessionMailer.magic_link(magic_token.user, magic_token.token).deliver_later
    redirect_to new_session_path, notice: "Check your email for a sign-in link."
  end

  def magic_token
    user = MagicToken.find_and_consume!(params[:token])
    start_new_session_for user
    redirect_to after_authentication_url
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: "Invalid or expired link. Please try again."
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
