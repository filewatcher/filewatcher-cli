# frozen_string_literal: true

include :bundler, static: true

require 'gem_toys'
expand GemToys::Template, version_file_path: "#{__dir__}/lib/filewatcher/cli/constants.rb"

alias_tool :g, :gem

tool :console do
  def run
    require_relative 'lib/filewatcher/cli'

    require 'pry'
    Pry.start
  end
end

alias_tool :c, :console
