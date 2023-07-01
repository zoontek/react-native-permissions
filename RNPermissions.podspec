require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNPermissions"

  s.version      = package["version"]
  s.license      = package["license"]
  s.summary      = package["description"]
  s.author       = package["author"]
  s.homepage     = package["homepage"]

  s.requires_arc = true

  s.source       = { :git => package["repository"]["url"], :tag => s.version }
  s.source_files = "ios/*.{h,m,mm}"

  if ENV['RCT_NEW_ARCH_ENABLED'] == "1" then
    install_modules_dependencies(s)
    s.platforms  = { :ios => "12.4", :tvos => "12.4" }
  else
    s.dependency   "React-Core"
    s.platforms  = { :ios => "10.0", :tvos => "11.0" }
  end
end
