# frozen_string_literal: true

require_relative '../dump_to_file'

dump_to_file(
  %w[
    FILENAME BASENAME EVENT DIRNAME ABSOLUTE_FILENAME RELATIVE_FILENAME
  ].map { |var| ENV.fetch(var) }.join(', ')
)
