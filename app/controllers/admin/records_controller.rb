class Admin::RecordsController < Admin::ApplicationController
  class NotAuthorizedError < StandardError; end

  include Admin::Records::BulkActions
  include Admin::Records::CsvExport
  include Admin::Records::SoftDelete
  include Admin::Records::Positioning

  helper_method :record_path,
    :record_class,
    :sort_params,
    :toggle_sort,
    :sort_params_index,
    :filter_enabled?,
    :filterable_columns,
    :column_widths,
    :column_titles,
    :available_page_sizes,
    :index_columns,
    :show_columns,
    :edit_columns,
    :required_columns,
    :association_field?,
    :get_association_class,
    :record_display_name,
    :jsonb_field?,
    :link_column_key,
    :history_available?,
    :history_path

  AVAILABLE_PAGE_SIZES = [ 50, 100, 500 ].freeze

  prepend_before_action :set_record, only: %i[ show edit update destroy discard restore update_position ]

  ### Index Action

  def index
    filter_query_class = self.filter_query_class

    # For soft-deletable models, include discarded records
    base_query = if record_class.column_names.include?("discarded_at")
      record_scope.with_discarded
    else
      record_scope.all
    end

    query = filter_query_class
      .new(base_query, filter: params[:filter], order: sort_params.presence || default_sort_params)
      .all
    query = query.includes(*association_fields) if association_fields.any?

    @pagy, @records = safe_pagy(query, limit: params[:limit] || available_page_sizes.first)

    return if index_action

    respond_to do |format|
      format.html { render index_view_path }
      format.json { render json: {
        "#{record_class.name.pluralize.underscore.to_sym}": @records.map(&method(:record_to_json)),
        pagination: @pagy.data_hash }
      }
      format.csv { index_csv_render(query) }
    end
  end

  ### Show Action

  def show
    return if show_action

    respond_to do |format|
      format.html { render show_view_path }
      format.json { render json: record_to_json(@record) }
      format.csv { show_csv_render }
    end
  end

  ### New Action

  def new
    @record = record_class.new(default_attributes)

    return if new_after_build_action

    render new_view_path
  end

  ### Create Action

  def create
    @record = record_class.new
    @record.assign_attributes(record_params)
    @record.assign_attributes(forced_attributes)

    return if create_after_build_action

    if @record.save(context: create_context)
      return if create_after_save_action

      record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize)
      redirect_to record_path(id: @record.id), notice: I18n.t("admin.messages.record_successfully_created", record_name: record_name)
    else
      record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
      flash.now[:alert] = I18n.t("admin.messages.problem_creating", record_name: record_name)

      return if create_after_save_action

      render new_view_path, status: :unprocessable_content
    end

  rescue NotAuthorizedError => e
    redirect_back(fallback_location: new_view_path, alert: e.message)
  end

  ### Edit Action

  def edit
    return if edit_after_build_action

    render edit_view_path
  end

  ### Update Action

  def update
    @record.with_lock do
      @record.assign_attributes(record_params)

      return if update_before_save_action

      if @record.save(context: update_context)
        return if update_after_save_action

        record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize)
        redirect_to record_path(id: @record.id), notice: I18n.t("admin.messages.record_successfully_updated", record_name: record_name)
      else
        record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
        flash.now[:alert] = I18n.t("admin.messages.problem_updating", record_name: record_name)

        return if update_after_save_action

        render edit_view_path, status: :unprocessable_content
      end
    end

  rescue NotAuthorizedError => e
    redirect_back(fallback_location: edit_view_path, alert: e.message)
  end

  ### Destroy Action

  def destroy
    record_name = "#{t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize)} ##{@record.id}"

    return if destroy_before_destroy_action

    begin
      @record.destroy!
      return if destroy_after_destroy_action

      redirect_to records_path, notice: I18n.t("admin.messages.record_successfully_deleted", record_name: record_name)
    rescue ActiveRecord::DeleteRestrictionError => e
      redirect_to record_path(id: @record.id), alert: t("errors.messages.delete_restriction_error")
    rescue ActiveRecord::RecordNotDestroyed => e
      record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
      error_message = I18n.t("admin.messages.problem_deleting", record_name: record_name)
      if @record.errors.any?
        error_message += " #{e.message}"
      end

      return if destroy_after_destroy_action

      redirect_to record_path(id: @record.id), alert: error_message
    end
  end

  private

  ### Hooks

  def show_action
    # Override in subclasses to define the show action
    false
  end

  def create_after_build_action
    # Override in subclasses to define the create action
    false
  end

  def create_after_save_action
    # Override in subclasses to define the create action
    false
  end

  def create_context
    # Override in subclasses to define the create context
    nil
  end

  def new_after_build_action
    # Override in subclasses to define the new action
    false
  end

  def index_action
    # Override in subclasses to define the index action
    false
  end

  def edit_after_build_action
    # Override in subclasses to define the edit action
    false
  end

  def update_before_save_action
    # Override in subclasses to define the update before save action
    false
  end

  def update_after_save_action
    # Override in subclasses to define the update action
    false
  end

  def update_context
    # Override in subclasses to define the update context
    nil
  end

  def destroy_before_destroy_action
    # Override in subclasses to define the destroy before destroy action
    false
  end

  def destroy_after_destroy_action
    # Override in subclasses to define the destroy action
    false
  end

  ### Record

  def set_record
    @record = record_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to records_path, alert: I18n.t("admin.messages.record_not_found", record_name: t("activerecord.models.#{record_class.model_name.i18n_key}", default: record_class.to_s.titleize), id: params[:id])
  end

  def record_class
    case record_scope
    when ActiveRecord::Relation
      record_scope.klass
    when Array
      record_scope.first.class
    else
      record_scope
    end
  end

  def filter_query_class
    "Admin::FiltersQuery::#{record_class.name}FiltersQuery".constantize
  end

  def toggle_sort(column, to_string: false)
    toggled_params = sort_params.dup
    case toggled_params[column]
    when nil
      toggled_params[column] = :asc
    when :asc
      toggled_params[column] = :desc
    when :desc
      toggled_params.delete(column)
    end

    to_string ? toggled_params.map { |k, v| "#{v == :desc ? "-" : ""}#{k}" }.join(",") : toggled_params
  end

  def sort_params_index(column)
    sort_params.keys.index(column)
  end

  def sort_params
    params[:sort].to_s.split(",").map do |sort|
      next unless record_class.column_names.include?(sort.delete_prefix("-"))

      if sort.start_with?("-")
        [ sort[1..], :desc ]
      else
        [ sort, :asc ]
      end
    end.compact.to_h.with_indifferent_access
  end

  def default_sort_params
    # eg. { created_at: :desc }

    { id: :desc }
  end

  def available_page_sizes
    self.class::AVAILABLE_PAGE_SIZES
  end

  ### Column Config

  def index_columns
    record_class.columns.map(&:name)
  end

  def filterable_columns
    index_columns
  end

  def filter_enabled?
    filterable_columns.any?
  end

  def column_widths
    # eg. { name: "100px", email: "200px" }.with_indifferent_access

    {}.with_indifferent_access
  end

  def column_titles
    # Override in subclasses to define custom column titles
    # eg. { otp_required_for_sign_in: "OTP Required" }.with_indifferent_access

    {}.with_indifferent_access
  end

  def show_columns
    # Override in subclasses to define which columns to show on detail page
    # eg. %w[id email verified created_at updated_at]

    record_class.columns.map(&:name)
  end

  def edit_columns
    # Override in subclasses to define which columns to show on edit form
    # eg. %w[email verified admin otp_required_for_sign_in]

    record_class.columns.map(&:name).reject { |col| %w[id created_at updated_at].include?(col) }
  end

  def required_columns
    # Override in subclasses to define which columns are required
    # eg. %w[name email]

    []
  end

  ### View Paths

  def views_path_base
    # eg. "admin/users"

    "admin/records"
  end

  def index_view_path
    "#{views_path_base}/index"
  end

  def show_view_path
    "#{views_path_base}/show"
  end

  def new_view_path
    "#{views_path_base}/new"
  end

  def edit_view_path
    "#{views_path_base}/edit"
  end

  ### Scope & Paths

  def record_scope
    # eg. User.active

    raise NotImplementedError
  end

  def records_path
    url_for(controller: params[:controller], action: :index)
  end

  def record_path(...)
    # eg. admin_user_path(...)

    raise NotImplementedError
  end

  ### Attributes & Params

  def default_attributes
    # Override in subclasses to define default attributes
    # eg. { verified: true }

    {}
  end

  def forced_attributes
    # Override in subclasses to define forced attributes
    # eg. { created_by: Current.user }

    {}
  end

  def record_params
    # Override in subclasses for custom parameter handling
    # Default implementation uses edit_columns for permitted parameters
    # eg. params.require(:user).permit(:email, :verified, :admin, :otp_required_for_sign_in)

    model_name = record_class.model_name.param_key

    # Separate array fields from regular fields
    regular_keys = []
    array_keys_hash = {}
    remove_keys = []

    edit_columns.each do |key|
      if array_field?(key)
        # Array fields need to be permitted as { key: [] }
        array_keys_hash[key.to_sym] = []
      else
        # Regular fields are just symbols
        regular_keys << key.to_sym
      end

      # Add remove_<key> for Active Storage attachments
      if record_class.respond_to?(:reflect_on_attachment) && record_class.reflect_on_attachment(key.to_sym)
        remove_keys << "remove_#{key}".to_sym
      end
    end

    # Build permit arguments: regular keys as symbols, array keys as hash, remove keys as symbols
    permit_args = regular_keys + remove_keys
    permit_args << array_keys_hash if array_keys_hash.any?

    permitted_params = params.require(model_name).permit(*permit_args)

    # Process JSONB fields
    process_jsonb_params(permitted_params)
  end

  def process_jsonb_params(params)
    # Parse JSON strings for JSONB fields
    params.each do |key, value|
      if jsonb_field?(key) && value.is_a?(String)
        begin
          parsed_value = JSON.parse(value)
          params[key] = parsed_value.is_a?(Hash) && parsed_value.any? ? parsed_value : {}
        rescue JSON::ParserError
          # If JSON parsing fails, set to {}
          params[key] = {}
        end
      end
    end
    params
  end

  ### Field Detection

  def association_fields
    # Override in subclasses to define which associations to include
    # eg. %w[users organizations]

    []
  end

  def association_field?(field_name)
    return false unless record_class.respond_to?(:reflect_on_association)

    association = record_class.reflect_on_association(field_name.to_sym)
    association.present?
  end

  def jsonb_field?(field_name)
    column = record_class.columns.find { |c| c.name == field_name.to_s }
    column&.type == :jsonb
  end

  def array_field?(field_name)
    column = record_class.columns.find { |c| c.name == field_name.to_s }
    return false unless column

    column.respond_to?(:array?) && column.array?
  end

  def get_association_class(field_name)
    association = record_class.reflect_on_association(field_name.to_sym)
    association&.class_name || field_name.classify
  end

  ### Display Helpers

  def record_display_name(record)
    # Try common display methods
    if record.respond_to?(:name)
      record.name
    elsif record.respond_to?(:email)
      record.email
    elsif record.respond_to?(:title)
      record.title
    elsif record.respond_to?(:display_name)
      record.display_name
    else
      "#{record.class.name} ##{record.id}"
    end
  end

  def record_to_json(record)
    {
      id: record.id,
      name: record_display_name(record),
      details: record.as_json,
      url: record_path(id: record.id)
    }
  end

  def link_column_key
    record_class.primary_key
  end

  def history_available?
    # Check if the record responds to versions (PaperTrail)
    @record.respond_to?(:versions)
  end

  def history_path(record)
    # Override in subclasses to provide history path
    # eg. admin_card_holder_history_path(record)
    # Return nil if not available

    nil
  end
end
