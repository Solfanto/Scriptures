module Admin
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    class_option :index, type: :string, desc: "Columns to show in index view (comma-separated)"
    class_option :show, type: :string, desc: "Columns to show in show view (comma-separated)"

    def create_controller
      template "controller.rb.tt", "app/controllers/admin/#{plural_name}_controller.rb"
    end

    def add_route
      route_content = <<~ROUTE.indent(4)
        resources :#{plural_name} do
          member do
            post :discard
            post :restore
            patch :update_position
          end
          collection do
            post :bulk_discard
            post :bulk_delete
            post :bulk_restore
          end
        end
      ROUTE

      inject_into_file "config/routes.rb", route_content, after: "namespace :admin do\n"
    end

    def add_sidebar_link
      sidebar_file = "app/views/admin/application/_sidebar.html.erb"

      if File.exist?(sidebar_file)
        sidebar_content = File.read(sidebar_file)

        new_item = <<~HTML.indent(4)
          <a href="<%= admin_#{plural_name}_path %>" class="sidebar__link <%= 'sidebar__link--active' if controller_name == '#{plural_name}' %>">
            <span class="sidebar__text"><%= t("activerecord.models.#{singular_name}", default: "#{class_name.pluralize}") %></span>
          </a>
        HTML

        # Add before the closing nav section
        if sidebar_content.include?("<!-- Generator: new sidebar links above -->")
          sidebar_content.sub!("<!-- Generator: new sidebar links above -->", "#{new_item}    <!-- Generator: new sidebar links above -->")
          File.write(sidebar_file, sidebar_content)
        end
      end
    end

    private

    def index_columns
      return [] unless options[:index]
      options[:index].split(",").map(&:strip)
    end

    def show_columns
      return [] unless options[:show]
      options[:show].split(",").map(&:strip)
    end

    def model_class
      class_name
    end

    def plural_name
      name.pluralize.underscore
    end

    def singular_name
      name.underscore
    end
  end
end
