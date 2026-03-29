# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: %w[application admin/application]
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: %w[application admin/application]
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Admin entry point
pin "admin/application", preload: "admin/application"
pin_all_from "app/javascript/admin/controllers", under: "admin/controllers", preload: "admin/application"
pin_all_from "app/javascript/admin/turbo", under: "admin/turbo", preload: "admin/application"
