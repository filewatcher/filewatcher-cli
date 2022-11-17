# frozen_string_literal: true

require_relative 'shell_watch_run'

def dump_to_file(content)
  Filewatcher::CLI::SpecHelper.debug "#{__method__} #{content.inspect}"

  File.write(
    File.join(Filewatcher::CLI::SpecHelper::ShellWatchRun::DUMP_FILE),
    "#{content}\n",
    mode: 'a+'
  )
end
