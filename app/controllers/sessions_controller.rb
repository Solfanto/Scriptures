class SessionsController < ApplicationController
  require_authentication only: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    browser_token = SecureRandom.urlsafe_base64(32)
    magic_token = MagicToken.generate_for(params[:email], browser_token: browser_token)
    cookies.signed[:browser_token] = { value: browser_token, expires: MagicToken::LIFETIME, httponly: true, same_site: :lax }
    SessionMailer.magic_link(magic_token.user, magic_token.token, magic_token.short_code).deliver_later
    redirect_to session_verification_path
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
