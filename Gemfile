source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Core
gem 'rails', '~> 7.1.0'
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 6.0'

# Ethereum
gem 'eth', '~> 0.5.11'  # Ethereum library
gem 'faraday', '~> 2.7'  # HTTP client for JSON-RPC

# Background Jobs
gem 'sidekiq', '~> 7.0'
gem 'redis', '~> 5.0'

# Pagination
gem 'kaminari', '~> 1.2'

# Serialization
gem 'active_model_serializers', '~> 0.10.13'

# Performance
gem 'bootsnap', require: false
gem 'rack-cors'
gem 'rack-attack'  # Rate limiting

# Monitoring
gem 'newrelic_rpm'  # Optional

group :development, :test do
  gem 'debug'
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'annotate'  # Add schema comments to models
  gem 'dotenv-rails' # Load .env file
end
