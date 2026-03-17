source 'https://rubygems.org'
ruby '~> 3.4.7'

gem 'rails', '~> 8.1.1'

# Use Puma as the app server
gem 'puma', '~> 6.0'
gem 'newrelic_rpm'
gem 'activerecord-nulldb-adapter'
gem 'active_model_serializers', '~> 0.10.15'
gem 'font-awesome-rails'
gem 'gon', '~> 6.4'
gem 'httparty', '~> 0.21.0'
gem 'rails_12factor'

gem 'propshaft'
gem 'jsbundling-rails'
gem 'cssbundling-rails'

gem "csv", require: false

group :development do
  gem 'rails_best_practices', '>= 1.23', require: false
  gem 'brakeman', '4.8.2', require: false
  gem 'rubocop', require: false
  gem 'bundler-audit', require: false
  # Deploy with Capistrano
  gem 'capistrano'
end

group :development, :test do
  gem 'jasmine'
  gem 'spring'
end

group :test do
  gem 'minitest-rails', '~> 8.1'
  gem 'minitest-reporters'
  # gem 'mini_backtrace'
end

# fixing a few travisCI complaints
gem 'rake', group: :test
gem 'test-unit'

group :production do
  gem 'unicorn', '~> 6.1'
end
