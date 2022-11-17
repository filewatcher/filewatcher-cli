# frozen_string_literal: true

require_relative '../constants'
require_relative '../spec_helper'

class Filewatcher
  module CLI
    module SpecHelper
      ## Watch runner for calls from shell
      class ShellWatchRun
        include Filewatcher::SpecHelper::WatchRun
        include CLI::SpecHelper

        executable_path = File.realpath "#{__dir__}/../../../../#{CLI::BINDIR}/filewatcher"
        EXECUTABLE = "#{'ruby ' if Gem.win_platform?}#{executable_path}" \

        DUMP_FILE = File.join(TMP_DIR, 'dump')

        def initialize(watch_path, options:, dumper:, dumper_args:, **rest_args)
          super(**rest_args)

          @watch_path = watch_path
          @options = options
          @options[:interval] ||= 0.2
          debug "options = #{options_string}"
          @dumper = dumper
          debug "dumper = #{@dumper}"
          @dumper_args = dumper_args.join(' ')
        end

        def start
          super

          spawn_filewatcher

          wait

          wait seconds: 3 do
            debug "pid state = #{pid_state.inspect}"
            dump_file_exists = File.exist?(DUMP_FILE)
            debug "#{__method__}: File.exist?(DUMP_FILE) = #{dump_file_exists}"
            pid_ready? && (!@options[:immediate] || dump_file_exists)
          end

          ## Dump file can exists with `--immediate` option, but Filewatcher can not have time
          ## to initialize `@last_snapshot` in main cycle.
          wait
        end

        def stop
          kill_filewatcher

          wait do
            pid_state.nil?
          end

          super
        end

        private

        def options_string
          @options_string ||=
            @options
              .map { |key, value| value.is_a?(TrueClass) ? "--#{key}" : "--#{key}=#{value}" }
              .join(' ')
        end

        SPAWN_OPTIONS = Gem.win_platform? ? {} : { pgroup: true }

        def spawn_filewatcher
          dumper_full_command = "#{__dir__}/dumpers/#{@dumper}_dumper.rb #{@dumper_args}"
          spawn_command =
            "#{EXECUTABLE} #{options_string} \"#{@watch_path}\" \"ruby #{dumper_full_command}\""
          debug "spawn_command = #{spawn_command}"
          @pid = spawn spawn_command, **SPAWN_OPTIONS

          debug "@pid = #{@pid}"

          debug Process.detach(@pid)
        end

        def make_changes
          super

          wait seconds: 3 do
            dump_file_exists = File.exist?(DUMP_FILE)
            debug "#{__method__}: File.exist?(DUMP_FILE) = #{dump_file_exists}"
            debug "#{__method__}: DUMP_FILE content = #{File.read(DUMP_FILE)}" if dump_file_exists
            dump_file_exists
          end
        end

        def kill_filewatcher
          debug __method__
          if Gem.win_platform?
            Process.kill('KILL', @pid)
          else
            ## Problems: https://github.com/thomasfl/filewatcher/pull/83
            ## Solution: https://stackoverflow.com/a/45032252/2630849
            debug 'Process TERM'
            Process.kill('TERM', -Process.getpgid(@pid))
            debug 'Process waitall'
            Process.waitall
          end
        rescue Errno::ESRCH
          nil ## already killed
        ensure
          wait
        end

        def pid_state
          if Gem.win_platform?
            match = `tasklist /FI "PID eq #{@pid}" /FO "LIST" /V`.match(/Status:\s+(\w+)/)
            return unless match

            match[1]
          else
            ## For macOS output:
            ## https://travis-ci.org/thomasfl/filewatcher/jobs/304433538
            state = `ps -ho state -p #{@pid}`.sub('STAT', '').strip
            ## Return `nil` for consistency with Windows
            state.empty? ? nil : state
          end
        end

        def pid_ready?
          ps = pid_state

          return if ps.nil?

          ps == (Gem.win_platform? ? 'Running' : 'S')
        end

        def wait(seconds: 1)
          super seconds: seconds, interval: @options[:interval]
        end
      end
    end
  end
end
