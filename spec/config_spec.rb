require "spec_helper"
require "drydocker/config"
require "shellwords"

# Tests for the main module
module Drydocker
  describe Config do
    context "with basic configuration" do
      let(:config) { Config.new }
      specify { expect(config.name).to eq "silarsis-drydocker-test" }
      specify { expect(config.entrypoint).to be_nil }
      specify { expect(config.image).to eq "silarsis/drydocker" }
      specify { expect(config.command).to eq "rspec spec".shellescape }
    end
    context "with provide value for" do
      context "name" do
        let(:config) { Config.new(name: "args-test") }
        specify { expect(config.name).to eq "args-test" }
      end
      context "command" do
        let(:config) { Config.new(command: "args-test") }
        specify { expect(config.command).to eq "args-test" }
      end
      context "image" do
        let(:config) { Config.new(image: "args-test") }
        specify { expect(config.image).to eq "args-test" }
      end
      context "image (longform)" do
        let(:config) { Config.new(image: "reg.me.com/ns/container:tag") }
        specify { expect(config.image).to eq "reg.me.com/ns/container:tag" }
      end
      context "entrypoint" do
        let(:config) { Config.new(entrypoint: "args-test") }
        specify { expect(config.entrypoint).to eq "args-test" }
      end
      context "path" do
        let(:config) { Config.new(path: "args-test") }
        specify { expect(config.path).to eq "args-test" }
      end
    end
  end
end
