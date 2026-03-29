module Admin
  module Records
    module BulkActions
      extend ActiveSupport::Concern

      ### Bulk Discard Action

      def bulk_discard
        ids = params[:ids] || []
        return head :bad_request if ids.empty?

        records = record_class.where(id: ids)
        discarded_count = 0
        errors = []

        records.each do |record|
          begin
            if soft_deletable? && !record.discarded?
              record.discard!
              discarded_count += 1
            end
          rescue ActiveRecord::RecordNotSaved, ActiveRecord::InvalidRecord => e
            errors << "#{record_class.to_s.titleize} ##{record.id}: #{e.message}"
          end
        end

        respond_to do |format|
          format.turbo_stream do
            streams = []

            # Update flash messages
            if errors.any?
              streams << turbo_stream.replace("flash-message-alert",
                partial: "admin/application/alert",
                locals: { alert: I18n.t("admin.messages.some_items_could_not_be_discarded", errors: errors.join(", ")) })
            else
              plural = discarded_count == 1 ? "" : "s"
              streams << turbo_stream.replace("flash-message-notice",
                partial: "admin/application/notice",
                locals: { notice: I18n.t("admin.messages.items_discarded_successfully", count: discarded_count, plural: plural) })
            end

            # Update affected rows
            records.each do |record|
              if record.discarded?
                streams << turbo_stream.replace("row-#{record.class.to_s.underscore}-#{record.id}",
                  partial: "admin/records/row",
                  locals: { record_class:, record:, record_path:, index_columns:, column_widths:, link_column_key: })
              end
            end

            render turbo_stream: safe_join(streams)
          end
          format.json do
            if errors.any?
              render json: {
                success: false,
                message: I18n.t("admin.messages.some_items_could_not_be_discarded", errors: errors.join(", ")),
                discarded_count: discarded_count
              }, status: :unprocessable_content
            else
              plural = discarded_count == 1 ? "" : "s"
              render json: {
                success: true,
                message: I18n.t("admin.messages.items_discarded_successfully", count: discarded_count, plural: plural),
                discarded_count: discarded_count
              }
            end
          end
        end
      end

      ### Bulk Delete Action

      def bulk_delete
        ids = params[:ids] || []
        return head :bad_request if ids.empty?

        records = record_class.where(id: ids)
        deleted_count = 0
        errors = []

        records.each do |record|
          begin
            record.destroy!
            deleted_count += 1
          rescue ActiveRecord::RecordNotDestroyed => e
            errors << "#{record_class.to_s.titleize} ##{record.id}: #{e.message}"
          end
        end

        respond_to do |format|
          format.turbo_stream do
            streams = []

            # Update flash messages
            if errors.any?
              streams << turbo_stream.replace("flash-message-alert",
                partial: "admin/application/alert",
                locals: { alert: I18n.t("admin.messages.some_items_could_not_be_deleted", errors: errors.join(", ")) })
            else
              plural = deleted_count == 1 ? "" : "s"
              streams << turbo_stream.replace("flash-message-notice",
                partial: "admin/application/notice",
                locals: { notice: I18n.t("admin.messages.items_deleted_successfully", count: deleted_count, plural: plural) })
            end

            # Remove deleted rows from DOM
            records.each do |record|
              unless record.persisted?
                streams << turbo_stream.remove("row-#{record.class.to_s.underscore}-#{record.id}")
              end
            end

            render turbo_stream: safe_join(streams)
          end
          format.json do
            if errors.any?
              render json: {
                success: false,
                message: I18n.t("admin.messages.some_items_could_not_be_deleted", errors: errors.join(", ")),
                deleted_count: deleted_count
              }, status: :unprocessable_content
            else
              plural = deleted_count == 1 ? "" : "s"
              render json: {
                success: true,
                message: I18n.t("admin.messages.items_deleted_successfully", count: deleted_count, plural: plural),
                deleted_count: deleted_count
              }
            end
          end
        end
      end

      ### Bulk Restore Action

      def bulk_restore
        ids = params[:ids] || []
        return head :bad_request if ids.empty?

        records = record_class.with_discarded.where(id: ids)
        restored_count = 0
        errors = []

        records.each do |record|
          begin
            if soft_deletable? && record.discarded?
              record.undiscard!
              restored_count += 1
            end
          rescue ActiveRecord::RecordNotSaved, ActiveRecord::InvalidRecord => e
            errors << "#{record_class.to_s.titleize} ##{record.id}: #{e.message}"
          end
        end

        respond_to do |format|
          format.turbo_stream do
            streams = []

            # Update flash messages
            if errors.any?
              streams << turbo_stream.replace("flash-message-alert",
                partial: "admin/application/alert",
                locals: { alert: I18n.t("admin.messages.some_items_could_not_be_restored", errors: errors.join(", ")) })
            else
              plural = restored_count == 1 ? "" : "s"
              streams << turbo_stream.replace("flash-message-notice",
                partial: "admin/application/notice",
                locals: { notice: I18n.t("admin.messages.items_restored_successfully", count: restored_count, plural: plural) })
            end

            # Update affected rows
            records.each do |record|
              unless record.discarded?
                streams << turbo_stream.replace("row-#{record.class.to_s.underscore}-#{record.id}",
                  partial: "admin/records/row",
                  locals: { record_class:, record:, record_path:, index_columns:, column_widths:, link_column_key: })
              end
            end

            render turbo_stream: safe_join(streams)
          end
          format.json do
            if errors.any?
              render json: {
                success: false,
                message: I18n.t("admin.messages.some_items_could_not_be_restored", errors: errors.join(", ")),
                restored_count: restored_count
              }, status: :unprocessable_content
            else
              plural = restored_count == 1 ? "" : "s"
              render json: {
                success: true,
                message: I18n.t("admin.messages.items_restored_successfully", count: restored_count, plural: plural),
                restored_count: restored_count
              }
            end
          end
        end
      end
    end
  end
end
