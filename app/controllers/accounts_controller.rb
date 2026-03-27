class AccountsController < ApplicationController
  require_authentication

  def show
    @user = current_user
    @passkey_credentials = @user.passkey_credentials.order(:created_at)
  end

  def update
    @user = current_user
    if @user.update(account_params)
      redirect_to account_path, notice: "Settings saved."
    else
      @passkey_credentials = @user.passkey_credentials.order(:created_at)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:display_name, :default_corpus_slug, :default_translation_abbreviation, :language)
  end
end
