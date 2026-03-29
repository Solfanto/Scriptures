class Admin::ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  include SafePagination

  helper Admin::ApplicationHelper

  # Authorization methods
  before_action :require_authentication!
  before_action :require_authorization!
  before_action :authorize_action!

  before_action :set_paper_trail_whodunnit

  layout "admin/application"

  helper_method :authorized_for_read?,
    :authorized_for_create?,
    :authorized_for_update?,
    :authorized_for_destroy?,
    :authorized_for_discard?

  def to_hash
    {
      name: self.class.name,
      headers: headers.to_h,
      controller_name: controller_name,
      action_name: action_name
    }
  end

  private

  rescue_from StandardError do |exception|
    raise exception if exception.is_a?(ActionController::RoutingError)

    Rails.error.report(exception, handled: true, severity: :error, context: to_hash)

    respond_to do |format|
      format.html { redirect_back(fallback_location: admin_root_path, alert: exception.message) }
      format.json { render json: { error: exception.message }, status: :internal_server_error }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("flash-message-alert", partial: "admin/application/alert", locals: { alert: exception.message }), status: :internal_server_error
      end
    end
  end unless Rails.env.development?

  def find_current_auditor
    Current.user if Current.user&.admin?
  end

  def require_authorization!
    return if Current.user&.admin?

    raise ActionController::RoutingError.new("Not Found")
  end

  # Authorization methods
  def authorize_action!
    unless authorized_for_action?(action_name)
      redirect_back(fallback_location: admin_root_url, alert: I18n.t("admin.messages.not_authorized", default: "Not authorized"))
    end
  end

  def authorized_for_action?(action_name)
    case action_name.to_sym
    when :index, :show
      authorized_for_read?
    when :new, :create
      authorized_for_create?
    when :edit, :update
      authorized_for_update?
    when :destroy, :bulk_delete
      authorized_for_destroy?
    when :discard, :bulk_discard
      authorized_for_discard?
    else
      authorized_for_read? # Default to read permissions for unknown actions
    end
  end

  def authorized_for_read?
    # Override in subclasses for custom read permissions
    default_authorization
  end

  def authorized_for_create?
    # Override in subclasses for custom create permissions
    default_authorization
  end

  def authorized_for_update?
    # Override in subclasses for custom update permissions
    default_authorization
  end

  def authorized_for_destroy?
    # Override in subclasses for custom destroy permissions
    default_authorization
  end

  def authorized_for_discard?
    # Override in subclasses for custom discard permissions
    default_authorization
  end

  def default_authorization
    # Default: require admin access
    # Override in subclasses for custom authorization logic
    Current.user&.admin?
  end
end
