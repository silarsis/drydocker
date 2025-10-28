# frozen_string_literal: true

require_relative "test_helper"
require "listen"
require "tmpdir"
require "timeout"

class TestListen < Minitest::Test
  def test_listener_detects_file_changes
    Dir.mktmpdir do |dir|
      file = File.join(dir, "sample.txt")
      File.write(file, "initial")

      events = Queue.new
      listener = Listen.to(dir, interval: 0.1) do |modified, added, removed|
        events << [modified, added, removed]
      end
      listener.start

      File.write(file, "updated")
      wait_for_event(events)

      listener.stop

      modified, added, removed = events.pop
      assert_includes modified, file
      assert_empty added
      assert_empty removed
    end
  end

  private

  def wait_for_event(queue)
    Timeout.timeout(5) do
      sleep 0.1 while queue.empty?
    end
  end
end
