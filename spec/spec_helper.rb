# frozen_string_literal: true

require 'pry-byebug' unless RUBY_PLATFORM == 'java'

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require_relative '../lib/filewatcher/cli'
require_relative '../lib/filewatcher/cli/spec_helper'

require_relative 'filewatcher/cli/spec_helper/shell_watch_run'
require_relative 'filewatcher/cli/spec_helper/dump_to_file'
