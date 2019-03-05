require 'json'
package = JSON.parse(File.read('./package.json'))

Pod::Spec.new do |s|
  s.name                   = "RNPermissions"

  s.version                = package["version"]
  s.license                = package["license"]
  s.description            = package["description"]
  s.summary                = package["description"]
  s.authors                = package["author"]
  s.homepage               = package["homepage"]

  s.default_subspec        = "Core"
  s.requires_arc           = true
  s.pod_target_xcconfig    = { "CLANG_CXX_LANGUAGE_STANDARD" => "c++14" }
  s.platforms              = { :ios => "9.0", :tvos => "9.2" }

  s.source                 = { :git => "#{s.homepage}.git", :tag => s.version }
  s.source_files           = "ios/*.{h,m}"

  s.subspec "Core" do |ss|
    s.dependency             "React/Core"
    ss.source_files        = "ios/*.{h,m}"
  end

  s.subspec "BluetoothPeripheral" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/BluetoothPeripheral/*.{h,m}"
  end

  s.subspec "Calendars" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Calendars/*.{h,m}"
  end

  s.subspec "Camera" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Camera/*.{h,m}"
  end

  s.subspec "Contacts" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Contacts/*.{h,m}"
  end

  s.subspec "FaceID" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/FaceID/*.{h,m}"
  end

  s.subspec "LocationAlways" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/LocationAlways/*.{h,m}"
  end

  s.subspec "LocationWhenInUse" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/LocationWhenInUse/*.{h,m}"
  end

  s.subspec "MediaLibrary" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/MediaLibrary/*.{h,m}"
  end

  s.subspec "Microphone" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Microphone/*.{h,m}"
  end

  s.subspec "Motion" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Motion/*.{h,m}"
  end

  s.subspec "Notifications" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Notifications/*.{h,m}"
  end

  s.subspec "PhotoLibrary" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/PhotoLibrary/*.{h,m}"
  end

  s.subspec "Reminders" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Reminders/*.{h,m}"
  end

  s.subspec "Siri" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/Siri/*.{h,m}"
  end

  s.subspec "SpeechRecognition" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/SpeechRecognition/*.{h,m}"
  end

  s.subspec "StoreKit" do |ss|
    ss.dependency            "RNPermissions/Core"
    ss.source_files        = "ios/PermissionHandlers/StoreKit/*.{h,m}"
  end
end
