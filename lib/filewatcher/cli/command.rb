# frozen_string_literal: true

require 'filewatcher'

require_relative 'env'
require_relative 'runner'
require_relative 'constants'

require 'clamp'

class Filewatcher
  module CLI
    ## Class for CLI command
    class Command < Clamp::Command
      banner <<~TEXT
        Filewatcher scans the file system and executes shell commands when files changes.
      TEXT

      require_relative 'command/options'

      parameter 'FILES', 'file names to scan' do |string|
        split_files_void_escaped_whitespace string.split unless string.to_s.empty?
      end

      parameter '[COMMAND]', 'shell command to execute when file changes'

      option ['-v', '--version'], :flag, 'Print versions' do
        Filewatcher.print_version
        puts "Filewatcher CLI #{Filewatcher::CLI::VERSION}"
        exit 0
      end

      def execute
        @child_pid = nil

        initialize_filewatcher

        print_if_list

        Process.daemon(true, true) if daemon?

        watch
      rescue SystemExit, Interrupt
        @filewatcher.finalize
      end

      private

      def initialize_filewatcher
        @filewatcher = Filewatcher.new(
          files,
          ## https://github.com/mdub/clamp/issues/105
          self.class.declared_options.to_h do |option|
            [option.attribute_name.to_sym, public_send(option.read_method)]
          end
        )
      end

      def split_files_void_escaped_whitespace(files)
        files
          .map { |name| name.gsub(/\\\s/, '_ESCAPED_WHITESPACE_').split(/\s/) }
          .flatten
          .uniq
          .map { |name| name.gsub('_ESCAPED_WHITESPACE_', '\ ') }
      end

      def watch
        @filewatcher.watch do |changes|
          changes = changes.first(1) unless every?

          changes.each do |filename, event|
            command = command_for_file filename

            next puts "file #{event}: #{filename}" unless command

            @child_pid = execute_command filename, event, command
          end
        end
      end

      def print_if_list
        return unless list?

        puts 'Watching:'
        @filewatcher.found_filenames.each { |filename| puts " #{filename}" }
      end

      def execute_command(filename, event, command)
        env = Filewatcher::CLI::Env.new(filename, event).to_h
        if restart?
          restart(@child_pid, restart_signal, env, command)
        else
          spawn env, command
          nil
        end
      end

      def command_for_file(filename)
        if exec? && File.exist?(filename) then Filewatcher::CLI::Runner.new(filename).command
        elsif command then command
        end
      end

      WINDOWS_SIGNALS_WARNING = <<~WARN
        WARNING: Signals don't work on Windows properly: https://bugs.ruby-lang.org/issues/17820
        It's recommended to use only the `KILL` (default `restart-signal` on Windows).
      WARN
      private_constant :WINDOWS_SIGNALS_WARNING

      def restart(pid, restart_signal, env, command)
        begin
          raise Errno::ESRCH unless pid

          ## Signals don't work on Windows for some reason:
          ## https://cirrus-ci.com/task/5706760947236864?logs=test#L346
          ## https://bugs.ruby-lang.org/issues/17820
          ## https://blog.simplificator.com/2016/01/18/how-to-kill-processes-on-windows-using-ruby/
          ## But `KILL` works.
          warn WINDOWS_SIGNALS_WARNING if Gem.win_platform? && restart_signal != 'KILL'

          Process.kill(restart_signal, pid)
          Process.wait(pid)
        rescue Errno::ESRCH
          nil # already killed
        end
        Process.spawn(env, command)
      end

      def spawn(env, command)
        Process.spawn(env, command)
        Process.wait
      rescue SystemExit, Interrupt
        exit(0)
      end
    end
  end
end
