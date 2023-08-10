require 'fileutils'
require 'json'

def log_warning(message)
  puts "\e[31m#{message}\e[0m"
end

def log_error(message)
  puts "\e[33m#{message}\e[0m"
end

def find_project_root_up(from_path)
  parent_path = File.expand_path('..', from_path)
  pkg_path = File.join(parent_path, 'package.json')

  if parent_path == '/'
    log_error('Cannot find project root directory.')
    exit(1)
  elsif File.exist?(pkg_path)
    return parent_path
  else
    return find_project_root_up(parent_path)
  end
end

def prepare_react_native_permissions!
  library_root = File.expand_path('..', __dir__)
  project_root = find_project_root_up(library_root)

  config_key = 'reactNativePermissionsIOS'

  pkg_path = File.join(project_root, 'package.json')
  config = JSON.parse(File.read(pkg_path))[config_key]
  json_path = File.join(project_root, "#{config_key}.json")

  if config.nil? && File.exist?(json_path)
    text = File.read(json_path)
    config = JSON.parse(text)
  end

  if config.nil?
    log_error("No config detected. In order to set up iOS permissions, you first need to add a \"#{config_key}\" array in your package.json.")
    exit(1)
  end

  unless config.is_a?(Array) && !config.empty?
    log_error("Invalid \"#{config_key}\" config detected. It must be a non-empty array.")
    exit(1)
  end

  ios_dir_path = File.join(library_root, 'ios')
  ios_dir_files = Dir.entries(ios_dir_path).map { |entry| File.join(ios_dir_path, entry) }

  directories = ios_dir_files
    .select { |entry| File.directory?(entry) || entry.end_with?('.xcodeproj') }
    .map { |entry| File.basename(entry) }
    .select { |name| config.include?(name) }

  source_files = [
    '"ios/*.{h,m,mm}"',
    *directories.map { |name| "\"ios/#{name}/*.{h,m,mm}\"" }
  ]

  unknown_permissions = config
    .reject { |name| directories.include?(name) }
    .map { |name| "\"#{name}\"" }

  unless unknown_permissions.empty?
    log_warning("Unknown iOS permissions: #{unknown_permissions.join(', ')}")
  end

  podspec_path = File.join(library_root, 'RNPermissions.podspec')
  podspec = File.read(podspec_path)
  podspec_content = podspec.gsub(/"ios\/\*\.{h,m,mm}".*/, source_files.join(', '))

  File.write(podspec_path, podspec_content)
end
