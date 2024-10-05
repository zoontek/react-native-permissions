require 'fileutils'

def log_warning(message)
  puts "[Permissions] #{message}"
end

def setup_permissions(config)
  if config.nil? || !config.is_a?(Array)
    return log_warning("Invalid config argument")
  end

  permissions_frameworks = {
    'AppTrackingTransparency' => ['AdSupport', 'AppTrackingTransparency'],
    'Bluetooth' => ['CoreBluetooth'],
    'Calendars' => ['EventKit'],
    'CalendarsWriteOnly' => ['EventKit'],
    'Camera' => ['AVFoundation'],
    'Contacts' => ['Contacts'],
    'FaceID' => ['LocalAuthentication'],
    'LocationAccuracy' => ['CoreLocation'],
    'LocationAlways' => ['CoreLocation'],
    'LocationWhenInUse' => ['CoreLocation'],
    'MediaLibrary' => ['MediaPlayer'],
    'Microphone' => ['AVFoundation'],
    'Motion' => ['CoreMotion'],
    'Notifications' => ['UserNotifications'],
    'PhotoLibrary' => ['Photos', 'PhotosUI'],
    'PhotoLibraryAddOnly' => ['Photos'],
    'Reminders' => ['EventKit'],
    'Siri' => ['Intents'],
    'SpeechRecognition' => ['Speech'],
    'StoreKit' => ['StoreKit']
  }

  module_dir = File.expand_path('..', __dir__)
  ios_dir = File.join(module_dir, 'ios')
  ios_dirents = Dir.entries(ios_dir).map { |entry| File.join(ios_dir, entry) }

  directories = ios_dirents
    .select { |entry| File.directory?(entry) || entry.end_with?('.xcodeproj') }
    .map { |entry| File.basename(entry) }
    .select { |name| config.include?(name) }

  unknown_permissions = config.reject { |name| directories.include?(name) }

  unless unknown_permissions.empty?
    log_warning("Unknown permissions: #{unknown_permissions.join(', ')}")
  end

  source_files = [
    '"ios/*.{h,mm}"',
    *directories.map { |name| "\"ios/#{name}/*.{h,mm}\"" }
  ].join(', ')

  frameworks = directories
    .reduce([]) do |acc, dir|
    arr = permissions_frameworks[dir]
    arr ? acc.concat(arr) : acc
  end
    .map { |name| "\"#{name}\"" }
    .uniq
    .join(', ')

  podspec_path = File.join(module_dir, 'RNPermissions.podspec')
  podspec = File.read(podspec_path)

  podspec_content = podspec
    .gsub(/(# *)?s\.source_files *=.*/, "s.source_files = #{source_files}")
    .gsub(/(# *)?s\.frameworks *=.*/, "s.frameworks = #{frameworks}")

  File.write(podspec_path, podspec_content)
end
