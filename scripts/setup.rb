require 'fileutils'

def log_warning(message)
  puts "[Permissions] #{message}"
end

def setup_permissions(config)
  if config.nil? || !config.is_a?(Array)
    return log_warning("Invalid config argument")
  end

  module_dir = File.expand_path('..', __dir__)
  ios_dir = File.join(module_dir, 'ios')
  ios_dirents = Dir.entries(ios_dir).map { |entry| File.join(ios_dir, entry) }

  directories = ios_dirents
    .select { |entry| File.directory?(entry) || entry.end_with?('.xcodeproj') }
    .map { |entry| File.basename(entry) }
    .select { |name| config.include?(name) }

  source_files = [
    '"ios/*.{h,m,mm}"',
    *directories.map { |name| "\"ios/#{name}/*.{h,m,mm}\"" }
  ]

  unknown_permissions = config.reject { |name| directories.include?(name) }

  unless unknown_permissions.empty?
    log_warning("Unknown permissions: #{unknown_permissions.join(', ')}")
  end

  podspec_path = File.join(module_dir, 'RNPermissions.podspec')
  podspec = File.read(podspec_path)
  podspec_content = podspec.gsub(/"ios\/\*\.{h,m,mm}".*/, source_files.join(', '))

  File.write(podspec_path, podspec_content)
end
