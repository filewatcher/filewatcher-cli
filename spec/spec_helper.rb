# frozen_string_literal: true

require 'pry-byebug' unless RUBY_PLATFORM == 'java' || Gem.win_platform?

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |c|
  c.example_status_persistence_file_path = "#{__dir__}/examples.txt"
end

require_relative '../lib/filewatcher/cli'
require_relative '../lib/filewatcher/cli/spec_helper'
