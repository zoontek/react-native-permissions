Pod::Spec.new do |s|
  s.name                      = "Simplified-RNPermissions"
  s.dependency                  "React"

  s.version                   = 1.0
  s.license                   = "MIT"
  s.summary                   = "Simplified version of RN-Permissions"
  s.authors                   = "Mathieu Acthernoene <zoontek@gmail.com> and simplified by me Guilherme Guimarães<heaven_@live.jp>"
  s.homepage                  = "https://github.com/celtaheaven/react-native-permissions.git"

  s.platform                  = :ios, "9.0"
  s.ios.deployment_target     = "9.0"
  s.tvos.deployment_target    = "11.0"
  s.requires_arc              = true

  s.source                    = { :git => "https://github.com/celtaheaven/react-native-permissions.git", :tag => s.version }
  s.source_files              = "ios/**/*.{h,m}"
end