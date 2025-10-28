# frozen_string_literal: true

class << File
  def which(cmd)
    return if cmd.nil? || cmd.empty?

    exts = ENV.fetch("PATHEXT", "").split(File::PATH_SEPARATOR)
    exts = [""] if exts.empty?
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        candidate = File.join(path, "#{cmd}#{ext}")
        return candidate if File.executable?(candidate) && !File.directory?(candidate)
      end
    end
    nil
  end
end
