# frozen_string_literal: true

require 'filewatcher/spec_helper'

class Filewatcher
  module CLI
    ## Helper for CLI specs
    module SpecHelper
      include Filewatcher::SpecHelper

      def environment_specs_coefficients
        super.merge(
          ## https://cirrus-ci.com/build/6442339705028608
          lambda do
            RUBY_PLATFORM == 'java' &&
              ENV['CI'] &&
              is_a?(Filewatcher::CLI::SpecHelper::ShellWatchRun)
          end => 2
        )
      end

      ## https://github.com/rubocop-hq/ruby-style-guide/issues/556#issuecomment-691274359
      # rubocop:disable Style/ModuleFunction
      extend self
      # rubocop:enable Style/ModuleFunction
    end
  end
end
