class SessionsController < ApplicationController
  require_authentication only: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    browser_token = SecureRandom.urlsafe_base64(32)
    magic_token = MagicToken.generate_for(params[:email_address], browser_token: browser_token)
    cookies.signed[:browser_token] = { value: browser_token, expires: MagicToken::LIFETIME, httponly: true, same_site: :lax }
    SessionMailer.magic_link(magic_token.user, magic_token.token, magic_token.short_code).deliver_later
    redirect_to verify_session_path
  end

  def verify
  end

  def verify_code
    browser_token = cookies.signed[:browser_token]
    unless browser_token
      redirect_to new_session_path, alert: "Please request a new sign-in link."
      return
    end

    user = MagicToken.find_and_consume_by_code!(params[:code], browser_token: browser_token)
    cookies.delete(:browser_token)
    start_new_session_for user
    redirect_to after_authentication_url
  rescue ActiveRecord::RecordNotFound
    redirect_to verify_session_path, alert: "Invalid or expired code. Please try again."
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
