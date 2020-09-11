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

      option %w[-I --immediate], :flag, 'immediately execute a command',
        default: false

      option %w[-E --every --each], :flag,
        'run command for every updated file in one file system check',
        default: false

      option %w[-D --daemon --background], :flag, 'run in the background as system daemon',
        default: false

      option %w[-r --restart --fork], :flag, 'restart process when file system is updated',
        default: false

      option '--restart-signal', 'VALUE', 'termination signal for `restart` option',
        default: 'TERM'

      option %w[-l --list], :flag, 'print name of files being watched',
        default: false

      option %w[-e --exec --execute], :flag, 'execute file as a script when file is updated',
        default: false

      option '--include', 'GLOB', 'include files',
        default: File.join('**', '*')

      option '--exclude', 'GLOB', 'exclude file(s) matching', default: nil do |string|
        split_files_void_escaped_whitespace string.split(' ') unless string.to_s.empty?
      end

      option %w[-i --interval], 'SECONDS', 'interval to scan file system', default: 0.5 do |string|
        Float(string)
      end

      option %w[-p --plugins], 'LIST', 'list of comma-separated required plugins',
        default: [] do |string|
          string.split(',').each { |plugin| require "filewatcher/#{plugin}" }
        end

      parameter 'FILES', 'file names to scan'

      parameter '[COMMAND]', 'shell command to execute when file changes'

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
          self.class.declared_options.map do |option|
            [option.attribute_name.to_sym, public_send(option.read_method)]
          end.to_h
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
          changes = every? ? changes : changes.first(1)

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

      def restart(pid, restart_signal, env, command)
        begin
          raise Errno::ESRCH unless pid

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
