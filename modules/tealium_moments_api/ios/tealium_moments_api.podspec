#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tealium_moments_api.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tealium_moments_api'
  s.version          = '1.0.0'
  s.summary          = 'Tealium Moments Api Module for Flutter.'
  s.description      = <<-DESC
Tealium Moments Api Module for Flutter.
                       DESC
  s.homepage         = 'https://github.com/tealium/tealium-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tealium Mobile Team' => 'mobile-team@tealium.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'tealium', '~> 2.5'
  s.dependency "tealium-swift/Core", "~> 2.14"
  s.dependency "tealium-swift/MomentsAPI", "~> 2.14"
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'tealium_moments_api_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
