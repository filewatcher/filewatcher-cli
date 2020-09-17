# frozen_string_literal: true

class Filewatcher
  module CLI
    ## Options for CLI command
    class Command < Clamp::Command
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
    end
  end
end
