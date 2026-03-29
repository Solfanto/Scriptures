class Admin::CountriesController < Admin::ApplicationController
  skip_before_action :authorize_action!, only: :index

  def index
    # Priority countries to show at the top (customize for your region)
    priority_codes = %w[US GB CA AU]

    countries = ISO3166::Country.all.map do |country|
      {
        code: country.alpha2,
        name: country.translations[I18n.locale.to_s] || country.common_name,
        flag: country.emoji_flag
      }
    end.sort_by do |country|
      priority_index = priority_codes.index(country[:code])
      # Priority countries get index 0-3, others get 999 + alphabetical position
      [ priority_index || 999, country[:name].parameterize ]
    end

    render json: { countries: countries }
  end
end
