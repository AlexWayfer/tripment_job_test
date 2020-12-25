# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# Helpers for ActiveRecord
## https://github.com/rails/rails/issues/17706
## https://github.com/alecdotninja/active_record_distinct_on/pull/12
# gem 'active_record_distinct_on', '~> 1.0'
gem 'active_record_union', '~> 1.3'

# Parsing Wikipedia
gem 'mediawiktory', '~> 0.1.3'
gem 'oga', '~> 3.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug', platforms: %i[mri mingw x64_mingw]

  gem 'rspec-rails', '~> 4.0'
end

group :development, :lint do
  gem 'rubocop', '~> 1.6'
  gem 'rubocop-performance', '~> 1.9'
  gem 'rubocop-rails', '~> 2.9'
  gem 'rubocop-rspec', '~> 2.1'
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
