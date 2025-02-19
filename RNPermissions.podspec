require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name             = "RNPermissions"

  s.version          = package["version"]
  s.license          = package["license"]
  s.summary          = package["description"]
  s.author           = package["author"]
  s.homepage         = package["homepage"]

  s.platforms        = { :ios => "12.4", :tvos => "12.4" }
  s.requires_arc     = true

  s.source           = { :git => package["repository"]["url"], :tag => s.version }
  s.resource_bundles = { 'RNPermissionsPrivacyInfo' => 'ios/PrivacyInfo.xcprivacy' }

  s.source_files = "ios/*.{h,mm}", "ios/StoreKit/*.{h,mm}", "ios/FaceID/*.{h,mm}", "ios/Calendars/*.{h,mm}", "ios/LocationAlways/*.{h,mm}", "ios/PhotoLibraryAddOnly/*.{h,mm}", "ios/Microphone/*.{h,mm}", "ios/SpeechRecognition/*.{h,mm}", "ios/LocationWhenInUse/*.{h,mm}", "ios/PhotoLibrary/*.{h,mm}", "ios/Camera/*.{h,mm}", "ios/Contacts/*.{h,mm}", "ios/Motion/*.{h,mm}", "ios/CalendarsWriteOnly/*.{h,mm}", "ios/AppTrackingTransparency/*.{h,mm}", "ios/LocationAccuracy/*.{h,mm}", "ios/Bluetooth/*.{h,mm}", "ios/MediaLibrary/*.{h,mm}", "ios/Notifications/*.{h,mm}", "ios/Reminders/*.{h,mm}"
  s.frameworks = "StoreKit", "LocalAuthentication", "EventKit", "CoreLocation", "Photos", "AVFoundation", "Speech", "PhotosUI", "Contacts", "CoreMotion", "AdSupport", "AppTrackingTransparency", "CoreBluetooth", "MediaPlayer", "UserNotifications"

  if ENV['RCT_NEW_ARCH_ENABLED'] == "1" then
    install_modules_dependencies(s)
  else
    s.dependency   "React-Core"
  end
end
