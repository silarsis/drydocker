# frozen_string_literal: true

require_relative "test_helper"
require "drydocker/config"

class TestConfig < Minitest::Test
  def test_default_configuration
    config = Drydocker::Config.new

    assert_equal "silarsis/drydocker", config.image
    assert_equal "silarsis-drydocker-test", config.name
    refute config.instance_variable_get(:@logger).nil?
  end

  def test_command_is_preserved
    config = Drydocker::Config.new(command: "bundle exec rspec")

    assert_equal "bundle exec rspec", config.command
  end

  def test_entrypoint_is_optional
    config = Drydocker::Config.new

    assert_nil config.entrypoint
  end
end
