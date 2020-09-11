# frozen_string_literal: true

require_relative '../spec_helper/dump_to_file'

signal = ARGV.first
Signal.trap(signal) do
  dump_to_file signal
end

Filewatcher::SpecHelper.wait seconds: 60
