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

  spec.required_ruby_version = '>= 2.6', '< 4'

  spec.add_runtime_dependency 'clamp', '~> 1.3'
  spec.add_runtime_dependency 'filewatcher', '~> 2.0.0.beta5'

  ## Windows requires some additional installations:
  ## https://cirrus-ci.com/task/5906822973358080?logs=bundle_install#L15
  unless RUBY_PLATFORM == 'java' || Gem.win_platform?
    spec.add_development_dependency 'pry-byebug', '~> 3.9'
  end

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'bundler-audit', '~> 0.9.0'

  spec.add_development_dependency 'gem_toys', '~> 0.12.1'
  spec.add_development_dependency 'toys', '~> 0.13.1'

  spec.add_development_dependency 'codecov', '~> 0.6.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'

  spec.add_development_dependency 'rubocop', '~> 1.29.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
