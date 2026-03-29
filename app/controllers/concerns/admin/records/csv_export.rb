module Admin
  module Records
    module CsvExport
      extend ActiveSupport::Concern

      included do
        helper_method :export_csv_show?,
          :export_csv_index?
      end

      private

      def index_csv_render(query)
        unless export_csv_index?
          head :forbidden
          return
        end

        start_date = Date.parse(params[:start_date]) if params[:start_date].present?
        end_date = Date.parse(params[:end_date]) if params[:end_date].present?
        records = query.all.where(created_at: start_date..end_date).reorder(id: :asc)

        # If no date range is provided, limit the number of records
        records = records.limit(export_csv_index_limit) if start_date.blank? && end_date.blank?

        filename = "#{record_class.name.pluralize.underscore.to_sym}_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"

        csv_data = CSV.generate do |csv|
          csv << records.first.csv_headers(context: :index) if records.first&.respond_to?(:csv_headers)
          records.each do |record|
            csv << record.to_csv(context: :index) if record.respond_to?(:to_csv)
          end
        end

        send_data csv_data, filename: filename
      end

      def export_csv_index_limit
        1_000
      end

      def show_csv_render
        csv_data = CSV.generate do |csv|
          csv << @record.csv_headers(context: :show) if @record.respond_to?(:csv_headers)
          if @record.respond_to?(:to_csv)
            @record.to_csv(context: :show).each do |row|
              csv << row
            end
          end
        end

        send_data csv_data, filename: @record.try(:csv_filename)
      end

      def export_csv_show?
        # Override in subclasses to enable CSV export for show action
        # eg. return true if the model implements to_csv method

        false
      end

      def export_csv_index?
        # Override in subclasses to enable CSV export for index action
        # eg. return true if the model implements csv_headers and to_csv methods

        false
      end
    end
  end
end
