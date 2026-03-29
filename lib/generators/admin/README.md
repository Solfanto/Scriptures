# Admin Interface Generator

This Rails generator creates a complete admin interface with controllers, views, layouts, JavaScript, and supporting files.

## Usage

### Generate Complete Admin Interface

```bash
rails generate admin:install
```

### Generate Admin Controller for Specific Model

```bash
rails generate admin:model ModelName --index=column1,column2 --show=column1,column2,column3
```

**Example:**
```bash
rails generate admin:model User --index=id,email,created_at --show=id,email,admin,created_at,updated_at
```

This will:
- Create `app/controllers/admin/users_controller.rb`
- Add routes (CRUD + soft delete + bulk actions) to `config/routes.rb`
- Add a sidebar link in `app/views/admin/application/_sidebar.html.erb`

## Generated Files

### Controllers
- `app/controllers/admin/application_controller.rb` - Base admin controller with authentication and authorization
- `app/controllers/admin/dashboard_controller.rb` - Empty dashboard controller for the admin root page
- `app/controllers/admin/records_controller.rb` - Generic CRUD controller for admin records
- `app/controllers/admin/countries_controller.rb` - Country data API for country select inputs

### Controller Concerns
- `app/controllers/concerns/admin/records/bulk_actions.rb` - Bulk discard, delete, restore
- `app/controllers/concerns/admin/records/csv_export.rb` - CSV export for index and show
- `app/controllers/concerns/admin/records/positioning.rb` - Drag-and-drop record reordering
- `app/controllers/concerns/admin/records/soft_delete.rb` - Discard and restore actions
- `app/controllers/concerns/safe_pagination.rb` - Safe Pagy wrapper with range error handling

### Models
- `app/models/admin/filters_query/base.rb` - Base filter query builder with range, date, like, boolean, and money queries
- `app/models/admin/filters_query/table_attribute.rb` - Special column attribute wrapper

### Helpers
- `app/helpers/admin/application_helper.rb` - Value formatting, enum display, JSONB tables, attachment display

### Views
- `app/views/layouts/admin/application.html.erb` - Admin layout with sidebar
- `app/views/admin/application/` - Shared components (sidebar, flash messages, scripts)
- `app/views/admin/dashboard/index.html.erb` - Default dashboard landing page for `admin_root`
- `app/views/admin/records/` - Complete CRUD views (index, show, new, edit, form, table, row, actions, pagination)
- `app/views/admin/records/inputs/` - 18 input field partials:
  - `_association.html.erb` - Has-many/has-one association selector
  - `_belongs_to.html.erb` - Belongs-to association selector
  - `_boolean.html.erb` - Checkbox field
  - `_countries_select.html.erb` - Multi-country select
  - `_country_select.html.erb` - Single country select
  - `_date.html.erb` - Date picker
  - `_datetime.html.erb` - Datetime picker
  - `_email.html.erb` - Email input
  - `_enum.html.erb` - Enum select dropdown
  - `_filterable_select.html.erb` - Searchable select
  - `_jsonb.html.erb` - Key-value JSONB editor
  - `_money.html.erb` - Amount + currency input
  - `_number.html.erb` - Number input
  - `_password.html.erb` - Password with generate/copy/toggle
  - `_password_confirmation.html.erb` - Password confirmation with toggle
  - `_photo.html.erb` - Photo upload with camera capture
  - `_tel.html.erb` - Telephone input
  - `_text.html.erb` - Text input
- `app/views/admin/records/history/` - Audit log / version history view

### JavaScript Controllers (Stimulus)
- `records_controller.js` - Table with bulk actions, column visibility, filtering, selection
- `sidebar_controller.js` - Mobile sidebar toggle
- `flash_message_controller.js` - Auto-dismiss flash messages
- `password_controller.js` - Password visibility toggle
- `password_generator_controller.js` - Secure password generation and copy
- `country_select_controller.js` - Country dropdown with search
- `countries_select_controller.js` - Multi-country select
- `association_selector_controller.js` - Modal association picker
- `jsonb_editor_controller.js` - Dynamic key-value editor
- `filterable_select_controller.js` - Searchable select dropdown
- `pagination_controller.js` - Page size form submission
- `keyboard_navigation_controller.js` - Keyboard shortcuts
- `positions_controller.js` - Drag-and-drop row reordering
- `photo_capture_controller.js` - Camera capture with iOS support
- `copy_to_clipboard_controller.js` - Clipboard copy utility
- Turbo integration (scroll preservation)

### Stylesheets
- `app/assets/stylesheets/admin/application.css` - Complete admin styles (Tailwind CSS)
- `app/assets/stylesheets/admin/buttons.css` - Button component styles

## Features

### CRUD Operations
- Full Create, Read, Update, Delete functionality
- Soft delete (discard/restore) support
- Bulk actions (discard, delete, restore selected)
- Pagination with customizable page sizes
- Multi-column sorting
- Per-column filtering with advanced query syntax

### Filter Query Syntax
- Range: `10-20` (BETWEEN 10 AND 20)
- Comparison: `>10`, `>=10`, `<10`, `<=10`
- Multiple: `10,40-50` (= 10 OR BETWEEN 40 AND 50)
- Date: `2024`, `2024-01`, `2024-01-15`, `>=2024-01`
- Like: `hello world` (AND), `hello,world` (OR)
- Exact: `=value`, Negation: `!=value`
- Null: `=` (IS NULL), `null`
- Boolean: `yes`/`no`, `true`/`false`, `1`/`0`

### CSV Export
- Index CSV export with date range filtering
- Show CSV export for individual records
- Override `export_csv_index?` / `export_csv_show?` to enable

### Record Positioning
- Drag-and-drop reordering via positions_controller.js
- Uses `set_before` / `set_after` on positionable models

### Version History
- PaperTrail integration for audit logging
- Shows field-level changes with old/new values
- Version restore functionality

### Form Components
- 18 input field types with automatic type detection
- Association selectors with search modals
- Country selection with ISO3166 integration
- JSONB key-value editor
- Photo capture with camera support
- Password generation with copy

## Customization

### Adding New Record Types

1. Run the model generator:
   ```bash
   rails generate admin:model User --index=id,email,created_at --show=id,email,admin,created_at,updated_at
   ```

2. Customize the generated controller:
   ```ruby
   class Admin::UsersController < Admin::RecordsController
     private

     def record_scope
       User.all
     end

     def record_path(...)
       admin_user_path(...)
     end

     def record_class
       User
     end

     def index_columns
       %w[id email admin created_at]
     end

     def show_columns
       %w[id email admin created_at updated_at]
     end

     def edit_columns
       %w[email password password_confirmation admin]
     end

     def record_params
       params.require(:user).permit(:email, :password, :password_confirmation, :admin)
     end

     def filter_query_class
       Admin::FiltersQuery::UserFiltersQuery
     end
   end
   ```

3. Create a filter query class:
   ```ruby
   class Admin::FiltersQuery::UserFiltersQuery < Admin::FiltersQuery::Base
     def all
       query = relation
       query = ilike_query(query, :email, filter[:email])
       query = boolean_query(query, :admin, filter[:admin])
       query = date_query(query, :created_at, filter[:created_at])
       query.order(order)
     end

     private

     def permitted_filter_params
       %i[email admin created_at]
     end
   end
   ```

## Dependencies

The generator assumes you have:
- Rails 8+
- Tailwind CSS 4+
- StimulusJS
- Turbo Rails
- Pagy gem for pagination
- ISO3166 gem for country data
- PaperTrail gem for audit history (optional)
- Discard gem for soft deletes (optional)
