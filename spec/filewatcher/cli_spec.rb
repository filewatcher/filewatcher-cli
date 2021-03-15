# frozen_string_literal: true

require 'fileutils'
require_relative '../../lib/filewatcher/cli'

describe Filewatcher::CLI do
  before do
    FileUtils.mkdir_p tmp_dir
  end

  after do
    logger.debug "FileUtils.rm_r #{tmp_dir}"
    FileUtils.rm_r tmp_dir

    Filewatcher::SpecHelper.wait seconds: 5, interval: 0.2 do
      !File.exist?(tmp_dir)
    end
  end

  let(:filename) { 'tmp_file.txt' }
  let(:action) { :update }
  let(:directory) { false }

  let(:shell_watch_run_class) { Filewatcher::CLI::SpecHelper::ShellWatchRun }
  let(:tmp_dir) { shell_watch_run_class::TMP_DIR }
  let(:logger) { Filewatcher::SpecHelper.logger }

  let(:null_output) { Gem.win_platform? ? 'NUL' : '/dev/null' }
  let(:dumper) { :watched }
  let(:dumper_args) { [] }
  let(:options) { {} }
  let(:watch_run) do
    shell_watch_run_class.new(
      filename: filename,
      action: action,
      directory: directory,
      dumper: dumper,
      options: options,
      dumper_args: dumper_args
    )
  end

  let(:dump_file_content) { File.read(shell_watch_run_class::DUMP_FILE) }
  let(:expected_dump_file_existence) { true }
  let(:expected_dump_file_content) { 'watched' }

  shared_examples 'dump file existence' do
    describe 'file existence' do
      subject { File.exist?(shell_watch_run_class::DUMP_FILE) }

      it { is_expected.to be expected_dump_file_existence }
    end
  end

  shared_examples 'dump file content' do
    describe 'file content' do
      subject { dump_file_content }

      it { is_expected.to eq expected_dump_file_content }
    end
  end

  describe 'just run' do
    subject { system("#{shell_watch_run_class::EXECUTABLE} --help > #{null_output}") }

    it { is_expected.to be true }
  end

  describe 'ENV variables' do
    let(:filename) { 'foo.txt' }
    let(:dumper) { :env }

    before do
      watch_run.run
    end

    context 'when file created' do
      let(:action) { :create }

      let(:expected_dump_file_content) do
        %W[
          #{tmp_dir}/#{filename}
          #{filename}
          created
          #{tmp_dir}
          #{tmp_dir}/#{filename}
          spec/tmp/#{filename}
        ].join(', ')
      end

      include_examples 'dump file existence'

      include_examples 'dump file content'
    end

    context 'when file deleted' do
      let(:action) { :delete }

      let(:expected_dump_file_content) do
        %W[
          #{tmp_dir}/#{filename}
          #{filename}
          deleted
          #{tmp_dir}
          #{tmp_dir}/#{filename}
          spec/tmp/#{filename}
        ].join(', ')
      end

      include_examples 'dump file existence'

      include_examples 'dump file content'
    end
  end

  shared_context 'when started and stopped' do
    before do
      watch_run.start
      watch_run.stop
    end
  end

  describe '`--immediate` option' do
    let(:options) { { immediate: true } }

    include_context 'when started and stopped'

    include_examples 'dump file existence'

    include_examples 'dump file content'
  end

  context 'without immediate option and changes' do
    let(:options) { {} }
    let(:expected_dump_file_existence) { false }

    include_context 'when started and stopped'

    include_examples 'dump file existence'
  end

  describe '`--restart` option' do
    let(:options) { { restart: true } }

    before do
      watch_run.run(make_changes_times: 2)
    end

    shared_examples 'correct behavior' do
      include_examples 'dump file existence'

      include_examples 'dump file content'
    end

    include_examples 'correct behavior'

    describe '`--fork` alias' do
      include_examples 'correct behavior'
    end
  end

  describe '`--restart-signal` option' do
    let(:dumper) { :signal }
    let(:dumper_args) { [restart_signal] }

    before do
      watch_run.run(make_changes_times: 2)
    end

    context 'with `--restart` option' do
      let(:expected_dump_file_content) { restart_signal }

      context 'with default value' do
        let(:restart_signal) { 'TERM' }
        let(:options) { { restart: true } }
        let(:expected_dump_file_existence) { true }

        include_examples 'dump file existence'

        include_examples 'dump file content'
      end

      context 'with custom value' do
        let(:restart_signal) { 'INT' }
        let(:options) { { restart: true, 'restart-signal' => restart_signal } }
        let(:expected_dump_file_existence) { true }

        include_examples 'dump file existence'

        include_examples 'dump file content'
      end
    end
  end
end
