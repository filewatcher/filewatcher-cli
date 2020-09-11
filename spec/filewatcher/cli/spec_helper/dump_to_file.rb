# frozen_string_literal: true

require_relative 'shell_watch_run'

def dump_to_file(content)
  File.write File.join(Filewatcher::CLI::SpecHelper::ShellWatchRun::DUMP_FILE), content
end
