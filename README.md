# Filewatcher CLI

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/filewatcher/filewatcher-cli?style=flat-square)](https://cirrus-ci.com/github/filewatcher/filewatcher-cli)
[![Codecov branch](https://img.shields.io/codecov/c/github/filewatcher/filewatcher-cli/master.svg?style=flat-square)](https://codecov.io/gh/filewatcher/filewatcher-cli)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/filewatcher/filewatcher-cli.svg?style=flat-square)](https://codeclimate.com/github/filewatcher/filewatcher-cli)
[![Depfu](https://img.shields.io/depfu/filewatcher/filewatcher-cli?style=flat-square)](https://depfu.com/repos/github/filewatcher/filewatcher-cli)
[![Inline docs](https://inch-ci.org/github/filewatcher/filewatcher-cli.svg?branch=master)](https://inch-ci.org/github/filewatcher/filewatcher-cli)
[![License](https://img.shields.io/github/license/filewatcher/filewatcher-cli.svg?style=flat-square)](https://github.com/filewatcher/filewatcher-cli/blob/master/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/filewatcher-cli.svg?style=flat-square)](https://rubygems.org/gems/filewatcher-cli)

CLI for [Filewatcher](https://github.com/filewatcher/filewatcher).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'filewatcher-cli'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install filewatcher-cli
```

## Usage

Run the `echo` command when the file `myfile` is changed:

```sh
$ filewatcher "myfile" "echo 'myfile has changed'"
```

Run any JavaScript in the current directory when it is updated in Windows
PowerShell:

```sh
> filewatcher *.js "node %FILENAME%"
```

In Linux/macOS:

```sh
$ filewatcher *.js 'node $FILENAME'
```

Place filenames in quotes to use Ruby filename globbing instead
of shell filename globbing. This will make Filewatcher look for files in
subdirectories too. To watch all JavaScript files in subdirectories in Windows:

```sh
> filewatcher "**/*.js" "node %FILENAME%"
```

In Linux/macOS:

```sh
$ filewatcher '**/*.js' 'node $FILENAME'
```

By default, Filewatcher executes the command only for the first changed file
that found from file system check, but you can using the `--every/-E` option
for running the command on each changed file.

```sh
$ filewatcher -E * 'echo file: $FILENAME'
```

Try to run the updated file as a script when it is updated by using the
`--exec/-e` option. Works with files with file extensions that looks like a
Python, Ruby, Perl, PHP, JavaScript or AWK script.

```sh
$ filewatcher -e *.rb
```

Print a list of all files matching \*.css first and then output the filename
when a file is being updated by using the `--list/-l` option:

```sh
$ filewatcher -l '**/*.css' 'echo file: $FILENAME'
```

Watch the "src" and "test" folders recursively, and run test when the file system gets updated:

```sh
$ filewatcher "src test" "ruby test/test_suite.rb"
```

### Restart long running commands

The `--restart/-r` option kills the command if it's still running when
a file system change happens. Can be used to restart locally running web servers
on updates, or kill long running tests and restart on updates. This option
often makes Filewatcher faster in general. To not wait for tests to finish:

```sh
$ filewatcher --restart "**/*.rb" "rake test"
```

By default, it sends `TERM` signal, but you can change it to what you want
via `--restart-signal` option:

```sh
$ filewatcher --restart --restart-signal=KILL "**/*.rb" "rake test"
```

The `--immediate/-I` option starts the command on startup without waiting for file system updates. To start a web server and have it automatically restart when HTML files are updated:

```sh
$ filewatcher --restart --immediate "**/*.html" "python -m SimpleHTTPServer"
```

### Daemonizing Filewatcher process

The `--daemon/-D` option starts Filewatcher in the background as system daemon, so Filewatcher will not be terminated by `Ctrl+C`, for example.

### Available environment variables

The environment variable `$FILENAME` is available in the shell command argument.
On UNIX like systems the command has to be enclosed in single quotes. To run
node whenever a JavaScript file is updated:

```sh
$ filewatcher *.js 'node $FILENAME'
```

Environment variables available from the command string:

```
BASENAME           File basename.
FILENAME           Relative filename.
ABSOLUTE_FILENAME  Absolute filename.
RELATIVE_FILENAME  Same as FILENAME but starts with "./"
EVENT              Event type. Is either 'updated', 'deleted' or 'created'.
DIRNAME            Absolute directory name.
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `toys rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/filewatcher/filewatcher-cli).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
