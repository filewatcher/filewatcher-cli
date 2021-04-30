# frozen_string_literal: true

require 'filewatcher/spec_helper'

class Filewatcher
  module CLI
    ## Helper for CLI specs
    module SpecHelper
      include Filewatcher::SpecHelper

      ENVIRONMENT_SPECS_COEFFICIENTS = {
        lambda do
          RUBY_ENGINE == 'jruby' &&
            # ENV['CI'] &&
            is_a?(Filewatcher::CLI::SpecHelper::ShellWatchRun)
        end => 2,
        lambda do
          RUBY_ENGINE == 'truffleruby' &&
            # ENV['CI'] &&
            is_a?(Filewatcher::CLI::SpecHelper::ShellWatchRun)
        end => 2
      }.freeze

      def environment_specs_coefficients
        @environment_specs_coefficients ||= super.merge ENVIRONMENT_SPECS_COEFFICIENTS
      end

      ## https://github.com/rubocop/ruby-style-guide/issues/556#issuecomment-828672008
      # rubocop:disable Style/ModuleFunction
      extend self
      # rubocop:enable Style/ModuleFunction
    end
  end
end
