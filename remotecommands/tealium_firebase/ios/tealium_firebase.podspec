#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tealium_firebase.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tealium_firebase'
  s.version          = '1.0.0'
  s.summary          = 'Tealium for Firebase and Flutter.'
  s.description      = <<-DESC
        Tealium for Firebase and Flutter.
                       DESC
  s.homepage = 'https://github.com/tealium/tealium-flutter'
  s.license = { :file => '../LICENSE' }
  s.authors = { 'Tealium Mobile Team' => 'mobile-team@tealium.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386, arm64' }
  s.swift_version = '5.0'
  s.static_framework = true

  s.dependency 'Flutter'
  s.dependency 'tealium'
  s.dependency "tealium-swift/Core", "~> 2.6"
  s.dependency "TealiumFirebase", "~> 3.0"
end
