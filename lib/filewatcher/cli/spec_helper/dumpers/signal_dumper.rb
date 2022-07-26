# frozen_string_literal: true

require_relative '../dump_to_file'

signal = ARGV.first
Signal.trap(signal) do
  dump_to_file signal
  exit
end

Filewatcher::CLI::SpecHelper.wait seconds: 60
