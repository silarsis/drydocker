# frozen_string_literal: true

require_relative "test_helper"

class TestDockerfile < Minitest::Test
  def setup
    @contents = File.read(File.expand_path("../Dockerfile", __dir__))
  end

  def test_base_image_is_ruby_32
    assert_includes @contents, "FROM ruby:3.2"
  end

  def test_docker_cli_is_installed
    assert_includes @contents, "apt-get install -y --no-install-recommends docker.io"
  end

  def test_gem_is_built_and_installed
    assert_includes @contents, "bundle exec rake build:gem"
    assert_includes @contents, "bundle exec gem install pkg/drydocker*.gem"
  end

  def test_default_command_runs_drydocker
    assert_includes @contents, 'CMD ["drydocker"]'
  end
end
