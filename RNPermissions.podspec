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
  s.source_files = "ios/*.{h,mm}"
  # s.frameworks = <frameworks>
  # s.resource_bundles = <resource_bundles>

  if ENV['RCT_NEW_ARCH_ENABLED'] == "1" then
    install_modules_dependencies(s)
  else
    s.dependency   "React-Core"
  end
end
