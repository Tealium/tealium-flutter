#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tealium_moments_api.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tealium_moments_api'
  s.version          = '3.0.0'
  s.summary          = 'Tealium Moments Api Module for Flutter.'
  s.description      = <<-DESC
Tealium Moments Api Module for Flutter.
                       DESC
  s.homepage         = 'https://github.com/tealium/tealium-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tealium Mobile Team' => 'mobile-team@tealium.com' }
  s.source           = { :path => '.' }
  s.source_files = 'tealium_moments_api/Sources/tealium_moments_api/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'tealium', '~> 4.0'
  s.dependency "tealium-swift/Core", "~> 2.18"
  s.dependency "tealium-swift/MomentsAPI", "~> 2.18"
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
