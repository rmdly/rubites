# frozen_string_literal: true

require 'open3'

module Rubites
  # Runs one level in a child process and compares its output to the expected
  # output.
  class Runner
    TIMEOUT = 5

    Result = Data.define(:state, :output, :error) do
      def passed? = state == :passed

      def failed? = state == :failed

      def errored? = state == :errored

      def timeout? = state == :timeout

      def unauthored? = state == :no_expectation

      def lines
        errored? ? Text.lines(error).reject(&:empty?) : Text.lines(output)
      end
    end

    def initialize
      @lock = Mutex.new
      @pid = nil
    end

    def run(exercise)
      if exercise.expected?
        judge(execute(exercise.path), exercise.expected)
      else
        # A level with no `# Expected output:` is unfinished, reported as its
        # own state so it doesn't look like a failed attempt.
        result(:no_expectation)
      end
    end

    # Thread#kill stops the thread that is waiting but leaves the spawned ruby
    # running, which for a level with an infinite loop means an orphan.
    def cancel
      @lock.synchronize { kill(@pid) }
    end

    private
      def judge((output, error, status), expected)
        case status
        when :timeout then result(:timeout, output: output)
        when false then result(:errored, output: output, error: error)
        else result(matches?(output, expected) ? :passed : :failed, output: output)
        end
      end

      def result(state, output: '', error: nil)
        Result.new(state: state, output: output.to_s, error: error&.to_s)
      end

      def matches?(output, expected)
        normalise(output) == normalise(expected)
      end

      # Trailing whitespace on each line is forgiven, blank lines inside are not.
      def normalise(text)
        Text.lines(text).join("\n").strip
      end

      def execute(path)
        Open3.popen3(RbConfig.ruby, path) do |input, out, err, process|
          input.close
          @lock.synchronize { @pid = process.pid }
          collect(out, err, process)
        end
      rescue StandardError => e
        ['', e.message, false]
      end

      # Drained on threads so a level with a lot of output cannot fill the pipe
      # and deadlock.
      def collect(out, err, process)
        output = Thread.new { out.read }
        errors = Thread.new { err.read }

        if process.join(TIMEOUT)
          [output.value, errors.value, process.value.success?]
        else
          kill(process.pid)
          process.join
          [output.value, errors.value, :timeout]
        end
      ensure
        @lock.synchronize { @pid = nil }
      end

      def kill(pid)
        Process.kill('KILL', pid) if pid
      rescue Errno::ESRCH
        nil
      end
  end
end
