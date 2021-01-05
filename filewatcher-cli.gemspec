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
    'https://github.com/filewatcher/filewatcher-cli/blob/master/CHANGELOG.md'

  spec.files = Dir['{exe,lib}/**/*.{rb,txt}', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

  spec.bindir = Filewatcher::CLI::BINDIR
  spec.executables << 'filewatcher'

  spec.required_ruby_version = '~> 2.5'

  spec.add_runtime_dependency 'clamp', '~> 1.3'
  spec.add_runtime_dependency 'filewatcher', '~> 2.0.0.beta2'

  spec.add_development_dependency 'pry-byebug', '~> 3.9' unless RUBY_PLATFORM == 'java'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'gem_toys', '~> 0.5.0'
  spec.add_development_dependency 'toys', '~> 0.11.0'

  spec.add_development_dependency 'codecov', '~> 0.2.1'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'simplecov', '~> 0.21.1'

  spec.add_development_dependency 'rubocop', '~> 1.3'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
