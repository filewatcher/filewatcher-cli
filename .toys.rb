# frozen_string_literal: true

include :bundler, static: true

require 'gem_toys'
expand GemToys::Template, version_file_path: "#{__dir__}/lib/filewatcher/cli/constants.rb"

alias_tool :g, :gem
