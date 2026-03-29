namespace :tailwindcss do
  desc "Build admin Tailwind CSS"
  task build_admin: :environment do
    command = [
      Tailwindcss::Ruby.executable,
      "-i", Rails.root.join("app/assets/tailwind/admin/application.css").to_s,
      "-o", Rails.root.join("app/assets/builds/admin/application.css").to_s
    ]
    command << "--minify" unless Rails.env.development?
    system(*command, exception: true)
  end

  desc "Watch and build admin Tailwind CSS on file changes"
  task watch_admin: :environment do
    command = [
      Tailwindcss::Ruby.executable,
      "-i", Rails.root.join("app/assets/tailwind/admin/application.css").to_s,
      "-o", Rails.root.join("app/assets/builds/admin/application.css").to_s,
      "-w"
    ]
    system(*command)
  rescue Interrupt
    # clean exit
  end
end

Rake::Task["tailwindcss:build"].enhance([ "tailwindcss:build_admin" ])
