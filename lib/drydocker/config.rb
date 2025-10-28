# frozen_string_literal: true

require "logger"
require "shellwords"

module Drydocker
  # Configuration file reader
  class Config
    attr_reader :name, :command, :image, :entrypoint, \
                :path, :verbose, :logger

    def self.default_config
      {
        name: nil,
        image: "silarsis/drydocker",
        command: "rspec spec",
        entrypoint: nil,
        path: `pwd`.strip,
        verbose: false
      }
    end

    def initialize(params = {})
      config = Config.default_config.merge(params)
      @image = config[:image]
      @name = config[:name] || name_from_image
      @entrypoint = config[:entrypoint]
      @command = config[:command]
      @path = config[:path]
      @logger = Logger.new(STDERR)
      @logger.level = Logger::DEBUG if config[:verbose]
    end

    private

    def name_from_image
      "#{image.gsub(/[\/:]/, "-")}-test"
    end
  end
end
