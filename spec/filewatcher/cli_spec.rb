# frozen_string_literal: true

require 'fileutils'
require_relative '../../lib/filewatcher/cli'
require_relative '../../lib/filewatcher/cli/spec_helper/shell_watch_run'

describe Filewatcher::CLI do
  before do
    FileUtils.mkdir_p tmp_dir
  end

  after do
    logger.debug "FileUtils.rm_r #{tmp_dir}"
    FileUtils.rm_r tmp_dir

    Filewatcher::CLI::SpecHelper.wait seconds: 5, interval: 0.2 do
      !File.exist?(tmp_dir)
    end
  end

  def transform_spec_files(file)
    shell_watch_run_class.transform_spec_files(file)
  end

  let(:shell_watch_run_class) { Filewatcher::CLI::SpecHelper::ShellWatchRun }
  let(:tmp_dir) { shell_watch_run_class::TMP_DIR }
  let(:tmp_files_dir) { shell_watch_run_class::TMP_FILES_DIR }
  let(:logger) { Filewatcher::SpecHelper.logger }

  let(:raw_file_name) { 'tmp_file.txt' }
  let(:initial_files) { { raw_file_name => {} } }

  let(:changes) do
    files = Array(initial_files.keys)
    files << raw_file_name if files.empty?
    files.to_h do |file|
      [transform_spec_files(file), { event: change_event, directory: change_directory }]
    end
  end

  let(:change_event) { :update }
  let(:change_directory) { false }

  let(:watch_path) { "#{tmp_files_dir}/**/*" }

  let(:null_output) { Gem.win_platform? ? 'NUL' : '/dev/null' }
  let(:dumper) { :watched }
  let(:dumper_args) { [] }
  let(:options) { {} }

  let(:make_changes_times) { 1 }

  let(:watch_run) do
    shell_watch_run_class.new(
      watch_path,
      initial_files: initial_files,
      changes: changes,
      dumper: dumper,
      options: options,
      dumper_args: dumper_args
    )
  end

  let(:dump_file_content) { File.read(shell_watch_run_class::DUMP_FILE) }
  let(:expected_dump_file_existence) { true }
  let(:expected_dump_file_content) { "watched\n" * make_changes_times }

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
    let(:dumper) { :env }

    before do
      watch_run.run
    end

    context 'when file created' do
      let(:initial_files) { {} }
      let(:change_event) { :create }

      let(:expected_dump_file_content) do
        [
          transform_spec_files(raw_file_name),
          raw_file_name,
          'created',
          transform_spec_files(nil),
          transform_spec_files(raw_file_name),
          "#{tmp_files_dir}/#{raw_file_name}",
          nil
        ].join("\n")
      end

      include_examples 'dump file existence'

      include_examples 'dump file content'
    end

    context 'when file deleted' do
      let(:change_event) { :delete }

      let(:expected_dump_file_content) do
        [
          transform_spec_files(raw_file_name),
          raw_file_name,
          'deleted',
          transform_spec_files(nil),
          transform_spec_files(raw_file_name),
          "#{tmp_files_dir}/#{raw_file_name}",
          nil
        ].join("\n")
      end

      include_examples 'dump file existence'

      include_examples 'dump file content'
    end

    context 'with multiple paths to watch' do
      let(:file_1) { 'tmp_file_1.txt' }
      let(:subdir) { 'subdir' }
      let(:file_2) { "#{subdir}/tmp_file_2.txt" }

      let(:watch_path) { "#{tmp_files_dir}/#{file_1} #{tmp_files_dir}/#{subdir}" }

      let(:initial_files) do
        {
          file_1 => {}
        }
      end

      let(:changes) do
        {
          **initial_files.to_h { |key, _value| [transform_spec_files(key), { event: :update }] },
          transform_spec_files(file_2) => { event: :create }
        }
      end

      context '`--every` option' do
        let(:options) { super().merge(every: true) }

        let(:expected_dump_file_content) do
          [
            transform_spec_files(file_1),
            file_1,
            'updated',
            transform_spec_files(nil),
            transform_spec_files(file_1),
            "#{tmp_files_dir}/#{file_1}",

            transform_spec_files(file_2),
            File.basename(file_2),
            'created',
            transform_spec_files(subdir),
            transform_spec_files(file_2),
            "#{tmp_files_dir}/#{file_2}",

            nil
          ].join("\n")
        end

        include_examples 'dump file existence'

        include_examples 'dump file content'
      end
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

    let(:make_changes_times) { 2 }

    before do
      watch_run.run(make_changes_times: make_changes_times)
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

    let(:make_changes_times) { 2 }

    before do
      watch_run.run(make_changes_times: make_changes_times)
    end

    context 'with `--restart` option' do
      let(:expected_dump_file_content) { "#{restart_signal}\n" }

      context 'with default value' do
        let(:restart_signal) { Gem.win_platform? ? 'KILL' : 'TERM' }
        let(:options) { { restart: true } }
        let(:expected_dump_file_existence) { true }

        if Gem.win_platform?
          pending <<~TEXT
            We can't trap `KILL` signal in the `signal_dumper.rb` on Windows:
            https://bugs.ruby-lang.org/issues/17820
          TEXT
        else
          include_examples 'dump file existence'

          include_examples 'dump file content'
        end
      end

      context 'with custom value' do
        let(:restart_signal) { 'INT' }
        let(:options) { { restart: true, 'restart-signal' => restart_signal } }
        let(:expected_dump_file_existence) { true }

        if Gem.win_platform?
          pending <<~TEXT
            We can't send non-`KILL` signal to the spawned process on Windows:
            https://bugs.ruby-lang.org/issues/17820
          TEXT
        else
          include_examples 'dump file existence'

          include_examples 'dump file content'
        end
      end
    end
  end
end
