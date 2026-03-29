module Admin
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc "Generate admin interface files including controllers, views, layouts, and JavaScript"

    def create_directories
      empty_directory "app/controllers/admin"
      empty_directory "app/controllers/concerns/admin/records"
      empty_directory "app/models/admin/filters_query"
      empty_directory "app/views/layouts/admin"
      empty_directory "app/views/admin/application"
      empty_directory "app/views/admin/dashboard"
      empty_directory "app/views/admin/records"
      empty_directory "app/views/admin/records/inputs"
      empty_directory "app/views/admin/records/history"
      empty_directory "app/javascript/admin/controllers"
      empty_directory "app/javascript/admin/turbo"
      empty_directory "app/assets/stylesheets/admin"
      empty_directory "app/helpers/admin"
    end

    def create_controllers
      template "controllers/application_controller.rb.tt", "app/controllers/admin/application_controller.rb"
      template "controllers/dashboard_controller.rb.tt", "app/controllers/admin/dashboard_controller.rb"
      template "controllers/records_controller.rb.tt", "app/controllers/admin/records_controller.rb"
      template "controllers/countries_controller.rb.tt", "app/controllers/admin/countries_controller.rb"
    end

    def create_concerns
      template "controllers/concerns/admin/records/bulk_actions.rb.tt", "app/controllers/concerns/admin/records/bulk_actions.rb"
      template "controllers/concerns/admin/records/csv_export.rb.tt", "app/controllers/concerns/admin/records/csv_export.rb"
      template "controllers/concerns/admin/records/positioning.rb.tt", "app/controllers/concerns/admin/records/positioning.rb"
      template "controllers/concerns/admin/records/soft_delete.rb.tt", "app/controllers/concerns/admin/records/soft_delete.rb"
      template "controllers/concerns/safe_pagination.rb.tt", "app/controllers/concerns/safe_pagination.rb"
    end

    def create_models
      template "models/admin/filters_query/base.rb.tt", "app/models/admin/filters_query/base.rb"
      template "models/admin/filters_query/table_attribute.rb.tt", "app/models/admin/filters_query/table_attribute.rb"
    end

    def create_helpers
      template "helpers/admin/application_helper.rb.tt", "app/helpers/admin/application_helper.rb"
    end

    def create_layouts
      template "views/layouts/admin/application.html.erb.tt", "app/views/layouts/admin/application.html.erb"
    end

    def create_application_views
      template "views/admin/application/_sidebar.html.erb.tt", "app/views/admin/application/_sidebar.html.erb"
      template "views/admin/application/_notice.html.erb.tt", "app/views/admin/application/_notice.html.erb"
      template "views/admin/application/_alert.html.erb.tt", "app/views/admin/application/_alert.html.erb"
      template "views/admin/application/_scripts.html.erb.tt", "app/views/admin/application/_scripts.html.erb"
    end

    def create_dashboard_views
      template "views/admin/dashboard/index.html.erb.tt", "app/views/admin/dashboard/index.html.erb"
    end

    def create_record_views
      template "views/admin/records/index.html.erb.tt", "app/views/admin/records/index.html.erb"
      template "views/admin/records/show.html.erb.tt", "app/views/admin/records/show.html.erb"
      template "views/admin/records/new.html.erb.tt", "app/views/admin/records/new.html.erb"
      template "views/admin/records/edit.html.erb.tt", "app/views/admin/records/edit.html.erb"
      template "views/admin/records/_form.html.erb.tt", "app/views/admin/records/_form.html.erb"
      template "views/admin/records/_records.html.erb.tt", "app/views/admin/records/_records.html.erb"
      template "views/admin/records/_row.html.erb.tt", "app/views/admin/records/_row.html.erb"
      template "views/admin/records/_actions.html.erb.tt", "app/views/admin/records/_actions.html.erb"
      template "views/admin/records/_records_actions.html.erb.tt", "app/views/admin/records/_records_actions.html.erb"
      template "views/admin/records/_pagination_header.html.erb.tt", "app/views/admin/records/_pagination_header.html.erb"
      template "views/admin/records/_pagination_footer.html.erb.tt", "app/views/admin/records/_pagination_footer.html.erb"
    end

    def create_record_input_views
      %w[
        association belongs_to boolean countries_select country_select
        date datetime email enum filterable_select jsonb money number
        password password_confirmation photo tel text
      ].each do |input|
        template "views/admin/records/inputs/_#{input}.html.erb.tt", "app/views/admin/records/inputs/_#{input}.html.erb"
      end
    end

    def create_history_views
      template "views/admin/records/history/index.html.erb.tt", "app/views/admin/records/history/index.html.erb"
    end

    def create_javascript
      template "javascript/admin/application.js.tt", "app/javascript/admin/application.js"
      template "javascript/admin/controllers/application.js.tt", "app/javascript/admin/controllers/application.js"
      template "javascript/admin/controllers/index.js.tt", "app/javascript/admin/controllers/index.js"

      %w[
        association_selector copy_to_clipboard country_select countries_select
        filterable_select flash_message jsonb_editor keyboard_navigation
        pagination password password_generator photo_capture positions
        records sidebar
      ].each do |controller|
        template "javascript/admin/controllers/#{controller}_controller.js.tt", "app/javascript/admin/controllers/#{controller}_controller.js"
      end

      template "javascript/admin/turbo/index.js.tt", "app/javascript/admin/turbo/index.js"
      template "javascript/admin/turbo/preserve_scrolling.js.tt", "app/javascript/admin/turbo/preserve_scrolling.js"
    end

    def create_stylesheets
      template "assets/stylesheets/admin/application.css.tt", "app/assets/stylesheets/admin/application.css"
      template "assets/stylesheets/admin/buttons.css.tt", "app/assets/stylesheets/admin/buttons.css"
    end

    def add_routes
      route <<~ROUTES
        namespace :admin do
          root "dashboard#index"
          get "countries", to: "countries#index"
        end
      ROUTES
    end

    private

    def empty_directory(path)
      FileUtils.mkdir_p(path) unless File.directory?(path)
    end
  end
end
