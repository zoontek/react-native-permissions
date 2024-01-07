require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNPermissions"

  s.version      = package["version"]
  s.license      = package["license"]
  s.summary      = package["description"]
  s.author       = package["author"]
  s.homepage     = package["homepage"]

  s.platforms  = { :ios => "12.4", :tvos => "12.4" }
  s.requires_arc = true

  s.source       = { :git => package["repository"]["url"], :tag => s.version }
  s.source_files = "ios/*.{h,m,mm}", "ios/StoreKit/*.{h,m,mm}", "ios/FaceID/*.{h,m,mm}", "ios/Calendars/*.{h,m,mm}", "ios/LocationAlways/*.{h,m,mm}", "ios/PhotoLibraryAddOnly/*.{h,m,mm}", "ios/Microphone/*.{h,m,mm}", "ios/SpeechRecognition/*.{h,m,mm}", "ios/LocationWhenInUse/*.{h,m,mm}", "ios/PhotoLibrary/*.{h,m,mm}", "ios/Camera/*.{h,m,mm}", "ios/Contacts/*.{h,m,mm}", "ios/Motion/*.{h,m,mm}", "ios/CalendarsWriteOnly/*.{h,m,mm}", "ios/AppTrackingTransparency/*.{h,m,mm}", "ios/LocationAccuracy/*.{h,m,mm}", "ios/Bluetooth/*.{h,m,mm}", "ios/MediaLibrary/*.{h,m,mm}", "ios/Notifications/*.{h,m,mm}", "ios/Reminders/*.{h,m,mm}"

  if ENV['RCT_NEW_ARCH_ENABLED'] == "1" then
    install_modules_dependencies(s)
  else
    s.dependency   "React-Core"
  end
end
