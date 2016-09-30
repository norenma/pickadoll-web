source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'
# Use sqlite3 as the database for Active Record
gem 'mysql2', '~> 0.3.17'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'
gem 'sshkit-sudo'

gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
# Use dotenv-rails for environment variables
# gem 'dotenv-rails'

# Use Capistrano for deployment
group :development do
  gem 'capistrano-rails'
  # For configuring nginx/unicorn -- use special fork for Red Hat server
  gem 'capistrano-unicorn-nginx', '~> 3.4.0',
    git: 'https://github.com/erwald/capistrano-unicorn-nginx.git', ref: '38f9e9c'
  gem 'capistrano-rbenv', '~> 2.0' # For using rbenv on server
  gem 'highline', '~> 1.7' # To avoid echoing passwords in terminal
end

# Use debugger
# gem 'debugger', group: [:development, :test]
