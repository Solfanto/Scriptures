module Admin::ApplicationHelper
  FAILURE_KEYWORDS = %w[failed rejected declined cancelled canceled error invalid
    kyc_completed pending_3ds_validation payment_failed
  ].freeze
  SUCCESS_KEYWORDS = %w[success succeeded completed processed captured paid active valid transferred].freeze

  def format_value(record, attribute, **options)
    value = record.public_send(attribute.to_sym)

    if record.class.defined_enums.key?(attribute.to_s) || attribute.to_s.end_with?("_enum")
      return format_enum(record, attribute, value)
    end

    # Check if value is an Active Storage attachment
    if value.respond_to?(:attached?)
      # If it's an attachment but nothing is attached, return nil
      return nil unless value.attached?
      # If it's an image, format it
      if value.blob&.content_type&.start_with?("image/")
        return format_attached_image(value)
      end

      return format_attached_file(value)
    end

    case value
    when Date, Time, DateTime
      content_tag(:span, l(value, format: options[:format].presence || :long), class: "record-value-date")
    when true
      content_tag(:span, I18n.t("admin.labels.yes_label"), class: class_names("record-value-tag", "record-value-tag--success"))
    when false
      content_tag(:span, I18n.t("admin.labels.no_label"), class: class_names("record-value-tag", "record-value-tag--failure"))
    when ActiveRecord::Associations::CollectionProxy, ActiveRecord::Relation
      format_association_tags(value, limit: 2)
    when ActiveRecord::Base
      format_association_tags([ value ].compact)
    when Hash
      format_jsonb_table(value, obfuscate: !Current.user&.admin? || Rails.configuration.x.obfuscate_jsonb_values)
    when Array
      if value.first.is_a?(Hash)
        format_jsonb_table(value, obfuscate: !Current.user&.admin? || Rails.configuration.x.obfuscate_jsonb_values)
      else
        value.map { |item| item.to_s }.join(", ")
      end
    when Money
      humanized_money_with_symbol(value)
    when String
      # Check if this looks like code based on field name
      if code_field?(attribute)
        format_code(value)
      elsif url_field?(attribute)
        format_url(value)
      elsif status_field?(attribute)
        format_enum(record, attribute, value)
      else
        value
      end
    else
      value
    end
  end

  def format_record_title(record)
    if record.respond_to?(:admin_title)
      record.admin_title
    else
      "#{t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize)} ##{@record.id}"
    end
  end

  def back_to_index_url
    # Try to use referrer if it's from the index page, otherwise use index URL
    begin
      if request.referer.present?
        referer_uri = URI.parse(request.referer)
        index_path = url_for(controller: params[:controller], action: :index, only_path: true)

        # Check if referrer is from the same controller's index action
        if referer_uri.path == index_path || referer_uri.path == index_path + "/"
          request.referer
        else
          url_for(controller: params[:controller], action: :index)
        end
      else
        url_for(controller: params[:controller], action: :index)
      end
    rescue ActionController::UrlGenerationError, URI::InvalidURIError
      :back
    end
  end

  private

  def format_association_tags(association, limit: nil)
    return content_tag(:span, I18n.t("admin.labels.none", default: "None"), class: "record-value-empty") if association.empty?

    # If no limit, show all items
    if limit.nil?
      limited_association = association
      remaining_count = 0
    else
      limited_association = association.limit(limit)
      remaining_records = association.offset(limit)
      remaining_count = association.count - limit
    end

    tags = limited_association.map do |record|
      display_text =
        if record.respond_to?(:association_name)
          record.association_name
        elsif record.respond_to?(:name) && record.name.present?
          record.name
        elsif record.respond_to?(:email) && record.email.present?
          record.email
        else
          "#{record.class.name} ##{record.id}"
        end

      admin_path =
        begin
          url_for(controller: "admin/#{record.class.name.pluralize.underscore}", action: :show, id: record.id)
        rescue ActionController::UrlGenerationError
          nil
        end

      if admin_path.present?
        content_tag(:a,
          display_text,
          href: admin_path,
          class: "record-value-tag--association",
          data: { turbo_frame: "_top" }
        )
      else
        content_tag(:span, display_text, class: "record-value-tag--association")
      end
    end

    # Add "and X more" tag if there are remaining items
    if remaining_count > 0
      tags << content_tag(:span,
        I18n.t("admin.labels.more_items", count: remaining_count, default: "+%{count} more"),
        title: remaining_records.map { |record| record.association_name }.join(", "),
        class: "record-value-tag--more"
      )
    end

    content_tag(:div, tags.join.html_safe, class: "flex flex-wrap gap-1")
  end

  def format_jsonb_table(data, obfuscate: true)
    return content_tag(:span, I18n.t("admin.labels.no_data", default: "No data"), class: "record-value-empty") if data.empty?

    data = [ data ] unless data.is_a?(Array)

    table_html = content_tag(:table, class: "record-detail__jsonb-table") do
      data.map do |row|
        header_html = content_tag(:thead) do
          content_tag(:tr) do
            content_tag(:th, I18n.t("admin.labels.key", default: "Key"), class: "record-detail__jsonb-header") +
            content_tag(:th, I18n.t("admin.labels.value", default: "Value"), class: "record-detail__jsonb-header")
          end
        end

        body_html = content_tag(:tbody) do
          row.map do |key, value|
            # Check if the key matches any filtered parameters
            filtered_key = Rails.application.config.filter_parameters.any? do |filter|
              case filter
              when String, Symbol
                key.to_s.downcase.include?(filter.to_s.downcase)
              when Regexp
                key.to_s.match?(filter)
              end
            end

            # Obfuscate the value if the key is filtered
            display_value = if filtered_key && obfuscate
              "******"
            else
              format_jsonb_value(value, obfuscate: obfuscate)
            end

            content_tag(:tr) do
              content_tag(:td, key.to_s, class: "record-detail__jsonb-cell") +
              content_tag(:td, display_value, class: "record-detail__jsonb-cell")
            end
          end.join.html_safe
        end

        header_html + body_html
      end.join.html_safe
    end

    content_tag(:div, table_html, class: "record-detail__jsonb-container")
  end

  def format_jsonb_value(value, obfuscate: true)
    case value
    when Hash, Array
      colored = colorize_json(JSON.pretty_generate(value))
      content_tag(:pre,
        content_tag(:code, colored, class: "record-value-code"),
        class: "code-block"
      )
    else
      value.to_s
    end
  end

  def colorize_json(json_string)
    json_string.gsub(
      /("(?:[^"\\]|\\.)*")(\s*:)?|(\b(?:true|false|null)\b)|(-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b)/
    ) do
      if $2 # key (string followed by colon)
        content_tag(:span, $1, class: "text-blue-600 dark:text-blue-400") + $2
      elsif $1 # string value
        content_tag(:span, $1, class: "text-green-600 dark:text-green-400")
      elsif $3 # boolean/null
        content_tag(:span, $3, class: "text-purple-600 dark:text-purple-400")
      elsif $4 # number
        content_tag(:span, $4, class: "text-amber-600 dark:text-amber-400")
      end
    end.html_safe
  end

  def format_enum(record, attribute, value)
    return nil if value.blank?

    content_tag(:span, t("activerecord.attributes.#{record.class.model_name.i18n_key}.enum.#{attribute}.#{value}", default: value&.humanize), class: enum_tag_css_class(value))
  end

  def code_field?(field_name)
    return false if field_name.blank?

    field_name.to_s.downcase.end_with?("_code", "_pre")
  end

  def url_field?(field_name)
    return false if field_name.blank?

    field_name.to_s.downcase.end_with?("_url")
  end

  def status_field?(field_name)
    return false if field_name.blank?

    field_name.to_s.downcase.end_with?("_status")
  end

  def format_code(value)
    return content_tag(:span, I18n.t("admin.labels.no_code", default: "No code"), class: "record-value-empty") if value.blank?

    # Truncate very long code for display
    display_value = if value.length > 5_000
      value[0..5_000] + "\n" + I18n.t("admin.labels.truncated", default: "... (truncated)")
    else
      value
    end

    content_tag(:pre,
      content_tag(:code, display_value, class: "record-value-code"),
      class: "code-block"
    )
  end

  def format_url(value)
    return content_tag(:span, I18n.t("admin.labels.no_url", default: "No URL"), class: "record-value-empty") if value.blank?

    content_tag(:a, value, href: value, rel: "noopener noreferrer", target: "_blank", class: "record-value-link")
  end

  def enum_tag_css_class(value)
    return "" if value.blank?

    case value.to_s.downcase
    when *FAILURE_KEYWORDS
      class_names("record-value-tag", "record-value-tag--failure")
    when *SUCCESS_KEYWORDS
      class_names("record-value-tag", "record-value-tag--success")
    else
      class_names("record-value-tag", "record-value-tag--default")
    end
  end

  def tag_css_classes
    "record-value-tag"
  end

  def date_validation_min_date(model)
    options = model.validators_on(:birth_date)
      .select { |v| v.is_a?(ActiveModel::Validations::ComparisonValidator) }
      .first&.options
    return nil if options.blank?

    offset = 0
    limit =
      if options[:more_than_or_equal_to]
        options[:more_than_or_equal_to]
      elsif options[:more_than]
        offset = 1
        options[:more_than]
      else
        nil
      end

    return nil if limit.blank?

    (limit.respond_to?(:call) ? limit.call : limit) + offset.days
  end

  def date_validation_max_date(model)
    options = model.validators_on(:birth_date)
      .select { |v| v.is_a?(ActiveModel::Validations::ComparisonValidator) }
      .first&.options
    return nil if options.blank?

    offset = 0
    limit =
      if options[:less_than_or_equal_to]
        options[:less_than_or_equal_to]
      elsif options[:less_than]
        offset = 1
        options[:less_than]
      else
        nil
      end

    return nil if limit.blank?

    (limit.respond_to?(:call) ? limit.call : limit) - offset.days
  end

  def format_attached_file(attachment)
    return nil unless attachment.attached?

    link_to(
      attachment.filename.to_s,
      rails_blob_path(attachment, disposition: "attachment"),
      class: "record-value-link",
      target: "_blank",
      rel: "noopener noreferrer"
    )
  end

  def format_attached_image(attachment)
    return nil unless attachment.attached?

    image_tag(
      attachment,
      alt: attachment.filename.to_s,
      class: "record-value-image"
    )
  end

  def obfuscate_sensitive_data(record, key, value)
    return nil if record.nil? || value.nil?

    # Check if the key matches any filtered parameters
    filtered_key = Rails.application.config.filter_parameters.include?(key.to_sym)

    # Also check for encrypted fields (common_last_name, first_name, last_name, etc.)
    encrypted_key = record.encrypted_attributes.to_a.include?(key.to_sym)

    if filtered_key || encrypted_key
      "******"
    else
      case value
      when Date, Time, DateTime
        value.to_formatted_s(:default)
      when true
        content_tag(:span, I18n.t("admin.labels.yes_label"), class: class_names("record-value-tag", "record-value-tag--success"))
      when false
        content_tag(:span, I18n.t("admin.labels.no_label"), class: class_names("record-value-tag", "record-value-tag--failure"))
      when Array
        value.join(", ")
      else
        value.to_s
      end
    end
  end

  def sortable_header_link(url, sort_params_key:, &block)
    if sort_params_key.present?
      link_to url, class: "records__sort-link group", &block
    else
      content_tag(:span, class: "records__sort-link group", &block)
    end
  end
end
