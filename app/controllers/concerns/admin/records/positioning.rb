module Admin
  module Records
    module Positioning
      extend ActiveSupport::Concern

      included do
        helper_method :positionable?,
          :update_position_path
      end

      ### Update Position Action

      def update_position
        unless positionable?
          return render json: { success: false, error: "Record is not positionable" }, status: :bad_request
        end

        target_record_id = params[:target_record_id]
        placement = params[:placement] # "before" or "after"

        unless target_record_id.present? && %w[before after].include?(placement)
          return render json: { success: false, error: "Missing target_record_id or placement" }, status: :bad_request
        end

        target_record = record_class.find(target_record_id)

        if placement == "before"
          @record.set_before(target_record)
        else
          @record.set_after(target_record)
        end

        render json: { success: true }
      end

      private

      def positionable?
        # Check if the record class or instance responds to positionable? method
        if @record
          @record.respond_to?(:positionable?) && @record.positionable?
        else
          record_class.respond_to?(:positionable?) && record_class.positionable?
        end
      end

      def update_position_path(record)
        # eg. update_position_admin_cms_record_category_path(record)
        # Override in subclasses if needed, or use the default implementation
        url_for(controller: params[:controller], action: :update_position, id: record.id)
      end
    end
  end
end
