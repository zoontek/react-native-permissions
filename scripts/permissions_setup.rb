require 'json'
require 'fileutils'

def pkg_dir(dir)
  pkg_path = File.join(dir, 'package.json')

  if File.exist?(pkg_path)
    dir
  else
    parent_dir = File.expand_path('..', dir)

    if parent_dir != dir
      pkg_dir(parent_dir)
    end
  end
end

def log_warning(message)
  puts "[Permissions] #{message}"
end

def prepare_react_native_permissions!
  config_key = 'reactNativePermissionsIOS'

  module_dir = File.expand_path('..', __dir__)
  root_dir = pkg_dir(Dir.pwd) || Dir.pwd
  pkg_path = File.join(root_dir, 'package.json')
  json_path = File.join(root_dir, "#{config_key}.json")

  config = JSON.parse(File.read(pkg_path))[config_key]

  if !config && File.exist?(json_path)
    text = File.read(json_path)
    config = JSON.parse(text)
  end

  if !config
    return log_warning("No #{config_key} config found")
  end

  unless config.is_a?(Array)
    return log_warning("Invalid #{config_key} config")
  end

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
