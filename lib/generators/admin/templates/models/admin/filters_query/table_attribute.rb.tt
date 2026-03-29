class Admin::FiltersQuery::TableAttribute
  # Strings are hardcoded to avoid any risk of SQL injection
  SPECIAL_COLUMNS = {}.freeze

  def initialize(attribute)
    @attribute = attribute
  end

  def [](key)
    SPECIAL_COLUMNS.dig(@attribute, key)
  end
end
