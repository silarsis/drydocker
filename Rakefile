# encoding: utf-8

PACKAGE_NAME = "drydocker"

require "rubygems"
require "bundler"
require "fileutils"

# Monkey patch to add an "unindent" method for heredocs
class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by { |l|l.length } }/, "")
  end
end

def version
  Drydocker::VERSION
end

def image_name
  "silarsis/drydocker"
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "rake"
require "drydocker/version"

require "rdoc/task"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "drydocker #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

desc "Run the minitest suite"
task :test do
  $LOAD_PATH.unshift File.expand_path("test")
  $LOAD_PATH.unshift File.expand_path("lib")
  Dir.glob("test/**/*_test.rb").sort.each { |file| require_relative file }
end

task default: :test

desc "Build gem and dockerfile"
task build: ["build:gem", "build:docker"]

namespace :build do
  desc "Build the gem"
  task :gem do
    FileUtils.mkdir_p("pkg/")
    system("gem build drydocker.gemspec")
    FileUtils.mv(Dir.glob("*.gem"), "pkg/")
  end

  desc "Build the Docker container"
  task :docker do
    system("docker build -t #{image_name}:#{version} .")
    system("docker tag #{image_name}:#{version} #{image_name}:latest")
  end
end

namespace :release do
  task :create_credentials do
    # This is for CI environments like wercker (well, it's for wercker)
    unless ENV["RUBYGEMS_API_KEY"].nil?
      credfile = File.expand_path("~/.gem/credentials")
      unless File.exist? credfile
        umask = File.umask 0177
        File.write(credfile, <<-EOF.unindent
          ---
          :rubygems_api_key: #{ENV["RUBYGEMS_API_KEY"]}
          EOF
        )
        File.umask umask
      end
    end
    `git config --global user.email kevin@littlejohn.id.au` if `git config user.email`.empty?
    `git config --global user.name "Kevin Littlejohn"` if `git config user.name`.empty?
    `git config --global push.default current` if `git config push.default`.empty?
    `git config --global github.user silarsis` if `git config github.user`.empty?
  end

  desc "Release the Docker container"
  task :docker do
    system("docker push #{image_name}:#{version}")
  end

  desc "Release the gem"
  task :gem do
    system("gem push pkg/#{PACKAGE_NAME}-#{version}.gem")
  end
end
