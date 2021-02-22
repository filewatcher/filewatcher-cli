# frozen_string_literal: true

require 'filewatcher/spec_helper'

class Filewatcher
  module CLI
    ## Helper for CLI specs
    module SpecHelper
      extend Filewatcher::SpecHelper

      module_function

      def environment_specs_coefficients
        @environment_specs_coefficients ||= super.merge(
          ## https://cirrus-ci.com/build/6442339705028608
          lambda do
            RUBY_PLATFORM == 'java' &&
              ENV['CI'] &&
              is_a?(Filewatcher::CLI::SpecHelper::ShellWatchRun)
          end => 2
        )
      end
    end
  end
end
