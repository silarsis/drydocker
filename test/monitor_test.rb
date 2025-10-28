# frozen_string_literal: true

require_relative "test_helper"
require "drydocker/config"
require "drydocker/monitor"

class TestMonitor < Minitest::Test
  def setup
    @config = Drydocker::Config.new(name: "spec-container")
    @monitor = Drydocker::Monitor.new(@config)
  end

  def test_run_or_start_runs_container_when_missing
    check_cmd = Shellwords.join(["docker", "container", "inspect", @config.name]) + " >/dev/null 2>&1"
    expected_run_cmd = Shellwords.join(
      ["docker", "run", "-it", "-w", "/app"] +
      ["-e", "RUBYOPT", "-e", "SPEC_OPTS", "-e", "RSPEC_OPTS"] +
      ["--name", @config.name] +
      ["-v", "#{@config.path}:/app"] +
      [@config.image] +
      ["sh", "-c", @config.command]
    )
    commands = []
    responses = { check_cmd => false, expected_run_cmd => true }

    @monitor.stub(:system, ->(cmd) { commands << cmd; responses.fetch(cmd) }) do
      @monitor.send(:run_or_start)
    end

    assert_equal [check_cmd, expected_run_cmd], commands
  end

  def test_run_or_start_starts_existing_container
    check_cmd = Shellwords.join(["docker", "container", "inspect", @config.name]) + " >/dev/null 2>&1"
    expected_start_cmd = Shellwords.join(["docker", "start", "-ai", @config.name])
    commands = []
    responses = { check_cmd => true, expected_start_cmd => true }

    @monitor.stub(:system, ->(cmd) { commands << cmd; responses.fetch(cmd) }) do
      @monitor.send(:run_or_start)
    end

    assert_equal [check_cmd, expected_start_cmd], commands
  end

  def test_run_or_start_includes_entrypoint
    config = Drydocker::Config.new(name: "spec-container", entrypoint: "/bin/bash")
    monitor = Drydocker::Monitor.new(config)
    check_cmd = Shellwords.join(["docker", "container", "inspect", config.name]) + " >/dev/null 2>&1"
    expected_run_cmd = Shellwords.join(
      ["docker", "run", "-it", "-w", "/app"] +
      ["-e", "RUBYOPT", "-e", "SPEC_OPTS", "-e", "RSPEC_OPTS"] +
      ["--name", config.name] +
      ["-v", "#{config.path}:/app"] +
      ["--entrypoint", "/bin/bash"] +
      [config.image] +
      ["sh", "-c", config.command]
    )
    commands = []
    responses = { check_cmd => false, expected_run_cmd => true }

    monitor.stub(:system, ->(cmd) { commands << cmd; responses.fetch(cmd) }) do
      monitor.send(:run_or_start)
    end

    assert_equal [check_cmd, expected_run_cmd], commands
  end

  def test_clean_containers_stops_existing_container
    config = Drydocker::Config.new(name: "spec-container")
    monitor = Drydocker::Monitor.new(config)
    check_cmd = Shellwords.join(["docker", "container", "inspect", config.name]) + " >/dev/null 2>&1"
    stop_cmd = Shellwords.join(["docker", "container", "stop", config.name])
    rm_cmd = Shellwords.join(["docker", "container", "rm", config.name])
    commands = []
    responses = { check_cmd => true, stop_cmd => true, rm_cmd => true }

    File.stub(:which, "/usr/bin/docker") do
      monitor.stub(:system, ->(cmd) { commands << cmd; responses.fetch(cmd) }) do
        monitor.clean_containers
      end
    end

    assert_equal [check_cmd, stop_cmd, rm_cmd], commands
  end

  def test_clean_containers_raises_without_docker
    monitor = Drydocker::Monitor.new(@config)

    File.stub(:which, nil) do
      assert_raises RuntimeError do
        monitor.clean_containers
      end
    end
  end
end
