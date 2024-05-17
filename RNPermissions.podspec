require 'json'
package = JSON.parse(File.read('./package.json'))

fabric_enabled = ENV['RCT_NEW_ARCH_ENABLED'] == '1'

Pod::Spec.new do |s|
  s.name                      = "RNPermissions"

  s.version                   = package["version"]
  s.license                   = package["license"]
  s.summary                   = package["description"]
  s.authors                   = package["author"]
  s.homepage                  = package["homepage"]

  s.ios.deployment_target     = "10.0"
  s.tvos.deployment_target    = "11.0"
  s.requires_arc              = true

  s.source                    = { :git => package["repository"]["url"], :tag => s.version }
  s.source_files              = "ios/*.{h,m,mm}"

  if fabric_enabled
    folly_compiler_flags      = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

    s.pod_target_xcconfig     = {
      'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/boost" "$(PODS_ROOT)/boost-for-react-native" "$(PODS_ROOT)/RCT-Folly"',
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    }

    s.platforms               = { ios: '11.0', tvos: '11.0' }
    s.compiler_flags          = folly_compiler_flags + ' -DRCT_NEW_ARCH_ENABLED'

    s.dependency                "React"
    s.dependency                "React-RCTFabric" # This is for fabric component
    s.dependency                "React-Codegen"
    s.dependency                "RCT-Folly"
    s.dependency                "RCTRequired"
    s.dependency                "RCTTypeSafety"
    s.dependency                "ReactCommon/turbomodule/core"
  else
    s.platforms               = { :ios => "9.0", :tvos => "9.0" }

    s.dependency                "React-Core"
  end

end
