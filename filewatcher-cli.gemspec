# frozen_string_literal: true

require_relative 'lib/filewatcher/cli/constants'

Gem::Specification.new do |spec|
  spec.name        = 'filewatcher-cli'
  spec.version     = Filewatcher::CLI::VERSION
  spec.authors     = ['Thomas Flemming', 'Alexander Popov']
  spec.email       = ['thomas.flemming@gmail.com', 'alex.wayfer@gmail.com']

  spec.summary     = 'CLI for Filewatcher'
  spec.description = <<~DESC
    CLI for Filewatcher.
  DESC
  spec.license = 'MIT'

  source_code_uri = 'https://github.com/filewatcher/filewatcher-cli'

  spec.homepage = source_code_uri

  spec.metadata['source_code_uri'] = source_code_uri

  spec.metadata['homepage_uri'] = spec.homepage

  spec.metadata['changelog_uri'] =
    'https://github.com/filewatcher/filewatcher-cli/blob/main/CHANGELOG.md'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['{exe,lib}/**/*.{rb,txt}', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

  spec.bindir = Filewatcher::CLI::BINDIR
  spec.executables << 'filewatcher'

  spec.required_ruby_version = '>= 3.2', '< 5'

  spec.add_dependency 'clamp', '~> 1.3'
  spec.add_dependency 'filewatcher', '~> 3.0'
end
