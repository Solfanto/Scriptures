class PasskeyCredentialsController < ApplicationController
  require_authentication only: %i[create destroy options_for_create]

  def options_for_create
    options = WebAuthn::Credential.options_for_create(
      user: {
        id: WebAuthn.generate_user_id,
        name: current_user.email_address,
        display_name: current_user.display_name || current_user.email_address
      },
      exclude: current_user.passkey_credentials.pluck(:external_id)
    )
    session[:webauthn_create_challenge] = options.challenge
    render json: options
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_create(params[:credential])
    webauthn_credential.verify(session.delete(:webauthn_create_challenge))

    current_user.passkey_credentials.create!(
      external_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
      label: params[:label].presence || "Passkey"
    )

    render json: { status: "ok" }
  rescue WebAuthn::Error => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def options_for_authenticate
    options = WebAuthn::Credential.options_for_get(
      allow: PasskeyCredential.pluck(:external_id)
    )
    session[:webauthn_authenticate_challenge] = options.challenge
    render json: options
  end

  def authenticate
    webauthn_credential = WebAuthn::Credential.from_get(params[:credential])
    stored = PasskeyCredential.find_by!(external_id: webauthn_credential.id)

    webauthn_credential.verify(
      session.delete(:webauthn_authenticate_challenge),
      public_key: stored.public_key,
      sign_count: stored.sign_count
    )

    stored.update!(sign_count: webauthn_credential.sign_count)
    start_new_session_for(stored.user)

    render json: { redirect_to: after_authentication_url }
  rescue WebAuthn::Error, ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    current_user.passkey_credentials.find(params[:id]).destroy
    redirect_to account_path, notice: "Passkey removed."
  end
end
