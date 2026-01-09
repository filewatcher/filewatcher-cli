# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  ## Windows requires some additional installations:
  ## https://cirrus-ci.com/task/5906822973358080?logs=bundle_install#L15
  gem 'pry-byebug', '~> 3.9' unless RUBY_PLATFORM == 'java' || Gem.win_platform?

  gem 'gem_toys', '~> 1.0.1'
  gem 'toys', '~> 0.15.3'
end

group :audit do
  gem 'bundler', '~> 2.0'
  gem 'bundler-audit', '~> 0.9.0'
end

group :test do
  gem 'rspec', '~> 3.9'
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura', '~> 2.1'
end

group :lint do
  gem 'rubocop', '~> 1.61.0'
  gem 'rubocop-performance', '~> 1.0'
  gem 'rubocop-rspec', '~> 2.26.1'
end

# gem 'filewatcher', path: '../filewatcher'
