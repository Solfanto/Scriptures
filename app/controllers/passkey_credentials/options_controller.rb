module PasskeyCredentials
  class OptionsController < ApplicationController
    require_authentication only: :create

    def create
      options = WebAuthn::Credential.options_for_create(
        user: {
          id: WebAuthn.generate_user_id,
          name: current_user.email,
          display_name: current_user.display_name || current_user.email
        },
        exclude: current_user.passkey_credentials.pluck(:external_id)
      )
      session[:webauthn_create_challenge] = options.challenge
      render json: options
    end

    def show
      options = WebAuthn::Credential.options_for_get(
        allow: PasskeyCredential.pluck(:external_id)
      )
      session[:webauthn_authenticate_challenge] = options.challenge
      render json: options
    end
  end
end
