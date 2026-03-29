module Admin
  module Records
    module SoftDelete
      extend ActiveSupport::Concern

      included do
        helper_method :soft_deletable?,
          :discarded?
      end

      ### Discard Action

      def discard
        record_name = "#{t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize)} ##{@record.id}"

        unless soft_deletable?
          record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
          redirect_to record_path(id: @record.id), alert: I18n.t("admin.messages.cannot_be_discarded", record_name: record_name)
          return
        end

        if discarded?
          record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
          redirect_to record_path(id: @record.id), alert: I18n.t("admin.messages.already_discarded", record_name: record_name)
          return
        end

        begin
          @record.discard!
          return if discard_after_save_action

          redirect_to records_path, notice: I18n.t("admin.messages.record_successfully_discarded", record_name: record_name)
        rescue ActiveRecord::RecordNotSaved, ActiveRecord::InvalidRecord => e
          record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
          error_message = I18n.t("admin.messages.problem_discarding", record_name: record_name)
          if @record.errors.any?
            error_message += " #{e.message}"
          end

          return if discard_after_save_action

          redirect_to record_path(id: @record.id), alert: error_message
        end
      end

      ### Restore Action

      def restore
        record_name = "#{t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize)} ##{@record.id}"

        if @record.undiscard
          return if restore_after_save_action

          redirect_to records_path, notice: I18n.t("admin.messages.record_successfully_restored", record_name: record_name)
        else
          record_name = t("activerecord.models.#{@record.model_name.i18n_key}", default: record_class.to_s.titleize.downcase)
          error_message = I18n.t("admin.messages.problem_restoring", record_name: record_name)
          if @record.errors.any?
            error_message += " #{@record.errors.full_messages.join(', ')}"
          end

          return if restore_after_save_action

          redirect_to record_path(id: @record.id), alert: error_message
        end
      end

      private

      def soft_deletable?
        record_class.column_names.include?("discarded_at")
      end

      def discarded?
        @record.respond_to?(:discarded?) && @record.discarded?
      end

      def discard_after_save_action
        # Override in subclasses to define the discard action
        false
      end

      def restore_after_save_action
        # Override in subclasses to define the restore action
        false
      end
    end
  end
end
