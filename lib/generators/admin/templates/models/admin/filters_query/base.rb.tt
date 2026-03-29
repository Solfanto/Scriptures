class Admin::FiltersQuery::Base
  class InputError < ArgumentError; end

  attr_reader :filter, :order, :relation

  FALSE_VALUES = [
    false, 0, "0", :"0", "f", :f, "F", :F, "false", :false, "FALSE", :FALSE, "False", "off", :off, "OFF", :OFF,
    "no", :no, "NO", :NO, "No", "n", :n, "N", :N
  ].to_set.freeze

  TRUE_VALUES = [
    true, 1, "1", :"1", "t", :t, "T", :T, "true", :true, "TRUE", :TRUE, "True", "on", :on, "ON", :ON,
    "yes", :yes, "YES", :YES, "Yes", "y", :y, "Y", :Y
  ].to_set.freeze

  NIL_VALUES = [
    "nil", :nil, "NULL", :NULL, "null", :null
  ].to_set.freeze

  def initialize(relation, filter: {}, order: {})
    @relation = relation
    @filter = (filter || {}).slice(*permitted_filter_params)
    @order = (order || {}).select { |k| permitted_order_params.include?(k.to_sym) }
  end

  def all
    raise NotImplementedError
  end

  private

  def permitted_filter_params
    []
  end

  def permitted_order_params
    permitted_filter_params
  end

  # "10-20" => attribute BETWEEN 10 AND 20
  # "10" => attribute = 10
  # "10,40-50" => attribute = 10 OR attribute BETWEEN 40 AND 50
  # ">10" => attribute > 10
  # "-20" => attribute <= 20
  # "=-20" => attribute = -20
  def range_query(query, attribute, values_string, having: false)
    return query if values_string.nil?
    return query.where(attribute => nil) if values_string.downcase == "null"

    arel_attribute = attribute.is_a?(Symbol) ? query.arel_table[attribute] : attribute
    or_queries = []

    values = values_string.split(",").map(&:strip).compact_blank
    values.each do |value|
      range_values = value.split("-").map(&:strip)
      or_queries <<
        if value == "="
          query_where_equal(query, arel_attribute, nil, having:)
        elsif value.starts_with?("=")
          query_where_equal(query, arel_attribute, value[1..], having:)
        elsif range_values.empty?
          query
        elsif range_values.size == 2
          query_where_between(query, arel_attribute, range_values, having:)
        elsif range_values.first.blank?
          query_where_lower_than_or_equal(query, arel_attribute, range_values.last, having:)
        elsif value.end_with?("-")
          query_where_greater_than_or_equal(query, arel_attribute, value[...-1], having:)
        elsif value.start_with?(">=")
          query_where_greater_than_or_equal(query, arel_attribute, value[2..], having:)
        elsif value.start_with?("<=")
          query_where_lower_than_or_equal(query, arel_attribute, value[2..], having:)
        elsif value.start_with?(">")
          query_where_greater_than(query, arel_attribute, value[1..], having:)
        elsif value.start_with?("<")
          query_where_lower_than(query, arel_attribute, value[1..], having:)
        else
          query_where_equal(query, arel_attribute, value, having:)
        end
    end

    or_queries.each_with_index do |or_query, i|
      query = i.zero? ? or_query : query.or(or_query)
    end
    query
  end

  # "10-20" => attribute BETWEEN 10 AND 20
  # "10" => attribute = 10
  # "10,40-50" => attribute = 10 OR attribute BETWEEN 40 AND 50
  # ">10" => attribute > 10
  def price_range_query(query, attribute, values_string, currency:, default_currency: "USD", having: false)
    return query if values_string.nil?

    @exchange_ratio ||= {}
    @exchange_ratio[currency.downcase.to_sym] ||=
      if currency == default_currency
        1
      else
        (Money.from_amount(1000, currency).exchange_to(default_currency).amount.to_f / 1000.0)
      end
    exchange_ratio = @exchange_ratio[currency.downcase.to_sym]

    arel_attribute = attribute.is_a?(Symbol) ? query.arel_table[attribute] : attribute
    or_queries = []

    values = values_string.split(",").map(&:strip).compact_blank
    values.each do |value|
      range_values = value.split("-").map(&:strip)
      or_queries <<
        if value == "="
          query_where_equal(query, arel_attribute, nil, having:)
        elsif value.starts_with?("=")
          query_where_equal(query, arel_attribute, value[1..].to_d * exchange_ratio, having:)
        elsif range_values.empty?
          query
        elsif range_values.size == 2
          query_where_between(query, arel_attribute, range_values.map { |v| v.to_d * exchange_ratio }, having:)
        elsif range_values.first.blank?
          query_where_lower_than_or_equal(query, arel_attribute, range_values.last.to_d * exchange_ratio, having:)
        elsif value.end_with?("-")
          query_where_greater_than_or_equal(query, arel_attribute, value[...-1].to_d * exchange_ratio, having:)
        elsif value.start_with?(">=")
          query_where_greater_than_or_equal(query, arel_attribute, value[2..].to_d * exchange_ratio, having:)
        elsif value.start_with?("<=")
          query_where_lower_than_or_equal(query, arel_attribute, value[2..].to_d * exchange_ratio, having:)
        elsif value.start_with?(">")
          query_where_greater_than(query, arel_attribute, value[1..].to_d * exchange_ratio, having:)
        elsif value.start_with?("<")
          query_where_lower_than(query, arel_attribute, value[1..].to_d * exchange_ratio, having:)
        else
          query_where_equal(query, arel_attribute, value.to_d * exchange_ratio, having:)
        end
    end

    or_queries.each_with_index do |or_query, i|
      query = i.zero? ? or_query : query.or(or_query)
    end
    query
  end

  def date_start_end_query(query, attribute, start_at, end_at)
    return query if start_at.nil? && end_at.nil?

    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]
    if end_at.nil?
      query.where(arel_attribute.gteq(start_at))
    elsif start_at.nil?
      query.where(arel_attribute.lteq(end_at))
    else
      query.where(arel_attribute.between(start_at..end_at))
    end
  end

  # "2020" => attribute.year = 2020
  # ">=2020" => attribute.year <= 10
  # "2020-2021" => attribute = 10 OR attribute BETWEEN 40 AND 50
  # "<10,>=50" => attribute < 10 OR attribute >= 50
  def date_query(query, attribute, date_string)
    return query if date_string.blank?

    operator, start_year, _, start_month, _, start_day, _, end_year, _, end_month, _, end_day =
      date_string.scan(/^([<>=]{0,2}?)(\d{4})(-(\d{2})(-(\d{2}))?)?(-(\d{4})(-(\d{2}))?(-(\d{2}))?)?$/).first

    if date_string == "="
      query.where(attribute => nil)
    elsif (operator.blank? || operator == "=") && start_year.present? && end_year.blank?
      date_equal_query(query, attribute, start_year, start_month, start_day)
    elsif end_year.present?
      date_range_query(query, attribute, [ start_year, start_month, start_day ], [ end_year, end_month, end_day ])
    elsif operator == ">="
      date_greater_or_equal_query(query, attribute, start_year, start_month, start_day)
    elsif operator == ">"
      date_greater_query(query, attribute, start_year, start_month, start_day)
    elsif operator == "<="
      date_lower_or_equal_query(query, attribute, start_year, start_month, start_day)
    elsif operator == "<"
      date_lower_query(query, attribute, start_year, start_month, start_day)
    else
      query.none
    end
  end

  def date_equal_query(query, attribute, start_year, start_month, start_day)
    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]

    if start_month.blank?
      start_of_year = DateTime.new(start_year.to_i).in_time_zone.beginning_of_year
      end_of_year = DateTime.new(start_year.to_i).in_time_zone.end_of_year
      query.where(arel_attribute.gteq(start_of_year)).where(arel_attribute.lteq(end_of_year))
    elsif start_day.blank?
      start_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.beginning_of_month
      end_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.end_of_month
      query.where(arel_attribute.gteq(start_of_month)).where(arel_attribute.lteq(end_of_month))
    else
      start_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.beginning_of_day
      end_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.end_of_day
      query.where(arel_attribute.gteq(start_of_day)).where(arel_attribute.lteq(end_of_day))
    end
  rescue Date::Error
    raise InputError, "Invalid date for '#{attribute}'"
  end

  def date_range_query(query, attribute, start_date_elements, end_date_elements)
    start_year, start_month, start_day = start_date_elements
    end_year, end_month, end_day = end_date_elements
    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]

    if end_month.blank?
      start_of_year = DateTime.new(start_year.to_i).in_time_zone.beginning_of_year
      end_of_year = DateTime.new(end_year.to_i).in_time_zone.end_of_year
      query.where(arel_attribute.gteq(start_of_year)).where(arel_attribute.lteq(end_of_year))
    elsif end_day.blank?
      start_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.beginning_of_month
      end_of_month = DateTime.new(end_year.to_i, end_month.to_i).in_time_zone.end_of_month
      query.where(arel_attribute.gteq(start_of_month)).where(arel_attribute.lteq(end_of_month))
    else
      start_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.beginning_of_day
      end_of_day = DateTime.new(end_year.to_i, end_month.to_i, end_day.to_i).in_time_zone.end_of_day
      query.where(arel_attribute.gteq(start_of_day)).where(arel_attribute.lteq(end_of_day))
    end
  rescue Date::Error
    raise InputError, "Invalid date for '#{attribute}'"
  end

  def date_greater_or_equal_query(query, attribute, start_year, start_month, start_day)
    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]

    if start_month.blank?
      start_of_year = DateTime.new(start_year.to_i).in_time_zone.beginning_of_year
      query.where(arel_attribute.gteq(start_of_year))
    elsif start_day.blank?
      start_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.beginning_of_month
      query.where(arel_attribute.gteq(start_of_month))
    else
      start_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.beginning_of_day
      query.where(arel_attribute.gteq(start_of_day))
    end
  rescue Date::Error
    raise InputError, "Invalid date for '#{attribute}'"
  end

  def date_greater_query(query, attribute, start_year, start_month, start_day)
    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]

    if start_month.blank?
      end_of_year = DateTime.new(start_year.to_i).in_time_zone.end_of_year
      query.where(arel_attribute.gt(end_of_year))
    elsif start_day.blank?
      end_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.end_of_month
      query.where(arel_attribute.gt(end_of_month))
    else
      end_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.end_of_day
      query.where(arel_attribute.gt(end_of_day))
    end
  rescue Date::Error
    raise InputError, "Invalid date for '#{attribute}'"
  end

  def date_lower_or_equal_query(query, attribute, start_year, start_month, start_day)
    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]

    if start_month.blank?
      end_of_year = DateTime.new(start_year.to_i).in_time_zone.end_of_year
      query.where(arel_attribute.lteq(end_of_year))
    elsif start_day.blank?
      end_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.end_of_month
      query.where(arel_attribute.lteq(end_of_month))
    else
      end_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.end_of_day
      query.where(arel_attribute.lteq(end_of_day))
    end
  rescue Date::Error
    raise InputError, "Invalid date for '#{attribute}'"
  end

  def date_lower_query(query, attribute, start_year, start_month, start_day)
    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]

    if start_month.blank?
      start_of_year = DateTime.new(start_year.to_i).in_time_zone.beginning_of_year
      query.where(arel_attribute.lt(start_of_year))
    elsif start_day.blank?
      start_of_month = DateTime.new(start_year.to_i, start_month.to_i).in_time_zone.beginning_of_month
      query.where(arel_attribute.lt(start_of_month))
    else
      start_of_day = DateTime.new(start_year.to_i, start_month.to_i, start_day.to_i).in_time_zone.beginning_of_day
      query.where(arel_attribute.lt(start_of_day))
    end
  rescue Date::Error
    raise InputError, "Invalid date for '#{attribute}'"
  end

  # "hello world,=alice" => (attribute LIKE '%hello%' AND attribute LIKE '%world%') OR attribute = 'alice'
  # commas are OR separators
  # spaces are AND separators
  def like_query(query, attributes, values_string, case_sensitive: true)
    return query if values_string.nil?

    or_queries = []
    attributes = [ attributes ] unless attributes.is_a?(Array)

    attributes.each do |attribute|
      arel_attribute = if attribute.is_a?(Arel::Attributes::Attribute) || attribute.is_a?(Arel::Nodes::Node)
                         attribute
      else
                         query.arel_table[attribute]
      end

      values = values_string.split(",").map(&:strip).compact_blank
      values.each do |value|
        or_queries <<
          if value.starts_with?("=")
            extracted_value = value[1..]
            if extracted_value.blank?
              query.where(arel_attribute.eq(extracted_value).or(arel_attribute.eq(nil)))
            else
              query.where(arel_attribute.eq(extracted_value))
            end
          elsif value.starts_with?("!=")
            extracted_value = value[2..]
            if extracted_value.blank?
              query.where(arel_attribute.not_eq("")).where(arel_attribute.not_eq(nil))
            else
              query.where(arel_attribute.not_eq(extracted_value))
            end
          else
            sub_query = query
            value.split.map(&:strip).compact_blank.each do |word|
              cast_attribute = Arel::Nodes::InfixOperation.new("::", arel_attribute, Arel::Nodes::SqlLiteral.new("TEXT"))
              sub_query = sub_query.where(cast_attribute.matches("%#{word}%", nil, case_sensitive))
            end
            sub_query
          end
      end
    end

    or_queries.each_with_index do |or_query, i|
      query = i.zero? ? or_query : query.or(or_query)
    end

    query
  end

  def ilike_query(query, attributes, values_string)
    like_query(query, attributes, values_string, case_sensitive: false)
  end

  # "Yes" => attribute = true
  def boolean_query(query, attribute, value)
    return query if value.blank?

    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]
    if value == "="
      query.where(arel_attribute.eq(nil))
    else
      bool =
        if FALSE_VALUES.include?(value.to_s.downcase)
          false
        elsif NIL_VALUES.include?(value.to_s.downcase)
          nil
        else
          true
        end
      query.where(arel_attribute.eq(bool))
    end
  end

  # "10" => attribute = 10
  # ">10" => attribute > 10
  # "10,40-50" => attribute = 10 OR attribute BETWEEN 40 AND 50
  # "<10,>=50" => attribute < 10 OR attribute >= 50
  def numeric_query(query, attribute, values_string)
    return query if values_string.blank?

    arel_attribute = attribute.is_a?(Arel::Attributes::Attribute) ? attribute : query.arel_table[attribute]
    or_queries = []

    values = values_string.split(",").map(&:strip)
    values.each do |value|
      range_values = value.split("-").map(&:strip)
      or_queries <<
        if range_values.size == 2
          query.where(arel_attribute.between(range_values[0]..range_values[1]))
        else
          if value.starts_with?("<=")
            query.where(arel_attribute.lteq(value[2..]))
          elsif value.starts_with?("<")
            query.where(arel_attribute.lt(value[1..]))
          elsif value.starts_with?(">=")
            query.where(arel_attribute.gteq(value[2..]))
          elsif value.starts_with?(">")
            query.where(arel_attribute.gt(value[1..]))
          elsif value.starts_with?("=")
            extracted_value = value[1..]
            if extracted_value.blank?
              query.where(arel_attribute.eq(extracted_value).or(arel_attribute.eq(nil)))
            else
              query.where(arel_attribute.eq(extracted_value))
            end
          else
            query.where(Arel::Nodes::NamedFunction.new("CAST", [ arel_attribute.as("TEXT") ]).matches("#{value}%"))
          end
        end
    end

    or_queries.each_with_index do |or_query, i|
      query = i.zero? ? or_query : query.or(or_query)
    end
    query
  end

  def query_where_between(query, arel_attribute, range_values, having:)
    if having
      query.having(arel_attribute[:between], range_values[0].to_d, range_values[1].to_d)
    elsif arel_attribute.is_a?(Admin::FiltersQuery::TableAttribute)
      query.where(arel_attribute[:between], range_values[0].to_d, range_values[1].to_d)
    else
      query.where(arel_attribute.between(range_values[0].to_d..range_values[1].to_d))
    end
  end

  def query_where_greater_than_or_equal(query, arel_attribute, value, having:)
    if having
      query.having(arel_attribute[:greater_than_or_equal], value.to_d)
    elsif arel_attribute.is_a?(Admin::FiltersQuery::TableAttribute)
      query.where(arel_attribute[:greater_than_or_equal], value.to_d)
    else
      query.where(arel_attribute.gteq(value.to_d))
    end
  end

  def query_where_lower_than_or_equal(query, arel_attribute, value, having:)
    if having
      query.having(arel_attribute[:lower_than_or_equal], value.to_d)
    elsif arel_attribute.is_a?(Admin::FiltersQuery::TableAttribute)
      query.where(arel_attribute[:lower_than_or_equal], value.to_d)
    else
      query.where(arel_attribute.lteq(value.to_d))
    end
  end

  def query_where_greater_than(query, arel_attribute, value, having:)
    if having
      query.having(arel_attribute[:greater_than], value.to_d)
    elsif arel_attribute.is_a?(Admin::FiltersQuery::TableAttribute)
      query.where(arel_attribute[:greater_than], value.to_d)
    else
      query.where(arel_attribute.gt(value.to_d))
    end
  end

  def query_where_lower_than(query, arel_attribute, value, having:)
    if having
      query.having(arel_attribute[:lower_than], value.to_d)
    elsif arel_attribute.is_a?(Admin::FiltersQuery::TableAttribute)
      query.where(arel_attribute[:lower_than], value.to_d)
    else
      query.where(arel_attribute.lt(value.to_d))
    end
  end

  # Custom money range query that converts decimal amounts to cents using Money gem
  def money_range_query(query, attribute, values_string, currency: "EUR", having: false)
    return query if values_string.nil?
    return query.where(attribute => nil) if values_string.downcase == "null"

    # Convert money values to cents in the string format
    # Handle each comma-separated value independently
    converted_values = values_string.split(",").map do |value|
      value = value.strip

      # Handle special cases that don't contain money amounts
      next value if value == "=" || value.empty?

      # Convert money amounts to cents while preserving operators and structure
      # Match patterns like: >10, >=10, <=10, <10, =10, =-10, 10-, -20, 10-20, 10
      converted = value.gsub(/([<>=]?=?-?)(\d+(?:\.\d+)?)(?=-|$)/) do |match|
        operator = $1
        amount = $2
        cents = amount.to_money(currency).cents
        "#{operator}#{cents}"
      end

      converted
    end.join(",")

    range_query(query, attribute, converted_values, having:)
  end

  def query_where_equal(query, arel_attribute, value, having:)
    if having
      query.having(arel_attribute[:equal], value&.to_d)
    elsif arel_attribute.is_a?(Admin::FiltersQuery::TableAttribute)
      query.where(arel_attribute[:equal], value&.to_d)
    else
      query.where(arel_attribute.eq(value&.to_d))
    end
  end
end
