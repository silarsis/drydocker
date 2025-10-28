# frozen_string_literal: true

require "find"
require "thread"

# Minimal implementation that mimics the public interface used by drydocker.
module Listen
  DEFAULT_INTERVAL = 1.0

  def self.to(*paths, interval: DEFAULT_INTERVAL, &block)
    Listener.new(paths.flatten, interval: interval, &block)
  end

  # Simple polling file system listener.
  class Listener
    def initialize(paths, interval: DEFAULT_INTERVAL, &callback)
      @paths = paths
      @interval = interval
      @callback = callback
      @mutex = Mutex.new
      @running = false
      @snapshot = snapshot
    end

    def start
      @mutex.synchronize do
        return self if @running
        @running = true
      end
      @thread = Thread.new { monitor_changes }
      self
    end

    def stop
      @mutex.synchronize { @running = false }
      @thread&.join
    end

    def join
      @thread&.join
    end

    private

    def monitor_changes
      while running?
        sleep @interval
        handle_changes
      end
    end

    def running?
      @mutex.synchronize { @running }
    end

    def handle_changes
      current = snapshot
      changes = diff(@snapshot, current)
      if changes.values.any? { |list| !list.empty? }
        @callback&.call(changes[:modified], changes[:added], changes[:removed])
      end
      @snapshot = current
    end

    def snapshot
      files = @paths.flat_map do |path|
        if File.directory?(path)
          Find.find(path).select { |candidate| File.file?(candidate) }
        else
          Dir.glob(path)
        end
      end.uniq
      files.each_with_object({}) do |file, memo|
        memo[file] = File.mtime(file) if File.exist?(file)
      end
    end

    def diff(previous, current)
      previous_keys = previous.keys
      current_keys = current.keys
      shared_keys = previous_keys & current_keys

      {
        modified: shared_keys.select { |file| previous[file] != current[file] },
        added: current_keys - previous_keys,
        removed: previous_keys - current_keys
      }
    end
  end
end
