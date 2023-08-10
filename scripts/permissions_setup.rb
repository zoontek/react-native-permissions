require 'fileutils'
require 'json'

def colorize(value, color)
  case color
    when :black then "\e[30m" + value.to_s + "\e[0m"
    when :red then "\e[31m" + value.to_s + "\e[0m"
    when :green then "\e[32m" + value.to_s + "\e[0m"
    when :yellow then "\e[33m" + value.to_s + "\e[0m"
    when :blue then "\e[34m" + value.to_s + "\e[0m"
    when :magenta then "\e[35m" + value.to_s + "\e[0m"
    when :cyan then "\e[36m" + value.to_s + "\e[0m"
    when :white then "\e[37m" + value.to_s + "\e[0m"
    else value.to_s
  end
end

def find_project_root_up(from_path)
  parent_path = File.expand_path('..', from_path)
  pkg_path = File.join(parent_path, 'package.json')

  if parent_path == '/'
    puts colorize('Cannot find project root directory.', :red)
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
    puts colorize("No config detected. In order to set up iOS permissions, you first need to add a \"#{config_key}\" array in your package.json.", :red)
    exit(1)
  end

  unless config.is_a?(Array) && !config.empty?
    puts colorize("Invalid \"#{config_key}\" config detected. It must be a non-empty array.", :red)
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
    puts colorize("Unknown iOS permissions: #{unknown_permissions.join(', ')}", :yellow)
  end

  podspec_path = File.join(library_root, 'RNPermissions.podspec')
  podspec = File.read(podspec_path)
  podspec_content = podspec.gsub(/"ios\/\*\.{h,m,mm}".*/, source_files.join(', '))

  File.write(podspec_path, podspec_content)
end
