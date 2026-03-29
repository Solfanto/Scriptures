module SafePagination
  extend ActiveSupport::Concern

  private

  def safe_pagy(query, **options)
    options[:client_max_limit] ||= 1_000
    pagy(query, **options, raise_range_error: true)
  rescue Pagy::RangeError => e
    pagy(query, **options, page: e.pagy.last, raise_range_error: false)
  end
end
