# frozen_string_literal: true

require "listen"
require "ptools"
require "shellwords"

module Drydocker
  # Class to actually run the monitor and tests
  class Monitor
    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def listen
      run_or_start
      listener = Listen.to(config.path) do |modified, added, removed|
        config.logger.info("triggering change: #{modified + added + removed}")
        run_or_start
      end
      listener.start # not blocking
      config.logger.info("now listening")
    end

    def clean_containers
      fail "No docker found" if File.which("docker").nil?
      return unless system(docker_check_cmd)
      config.logger.debug("cleaning up previous containers")
      system(Shellwords.join(["docker", "container", "stop", config.name]))
      system(Shellwords.join(["docker", "container", "rm", config.name]))
    end

    def run_or_start
      system(docker_check_cmd) ? start : run
    end

    private

    def docker_run_cmd
      Shellwords.join(
        docker_cmd +
        env_flags +
        name_opt +
        path_opt +
        entrypoint_opt +
        [config.image] +
        shell_command
      )
    end

    def env_flags
      ["-e", "RUBYOPT", "-e", "SPEC_OPTS", "-e", "RSPEC_OPTS"]
    end

    def docker_start_cmd
      Shellwords.join(["docker", "start", "-ai", config.name])
    end

    def docker_check_cmd
      Shellwords.join(["docker", "container", "inspect", config.name]) + " >/dev/null 2>&1"
    end

    def docker_cmd
      ["docker", "run", "-it", "-w", "/app"]
    end

    def name_opt
      ["--name", config.name]
    end

    def entrypoint_opt
      return [] if config.entrypoint.nil?
      ["--entrypoint", config.entrypoint]
    end

    def path_opt
      ["-v", "#{config.path}:/app"]
    end

    def command
      config.command.nil? ? "" : config.command
    end

    def shell_command
      return [] if command.empty?
      ["sh", "-c", command]
    end

    def run
      config.logger.debug(docker_run_cmd)
      system(docker_run_cmd)
    end

    def start
      config.logger.debug(docker_start_cmd)
      system(docker_start_cmd)
    end
  end
end
