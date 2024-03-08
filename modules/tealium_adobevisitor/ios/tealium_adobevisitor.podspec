#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tealium_adobevisitor.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tealium_adobevisitor'
  s.version          = '1.1.0'
  s.summary          = 'Tealium for Adobe Visitor Module and Flutter.'
  s.description      = <<-DESC
  Tealium for Adobe Visitor Module and Flutter.
                       DESC
  s.homepage         = 'https://github.com/tealium/tealium-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tealium Mobile Team' => 'mobile-team@tealium.com'  }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'Flutter'
  s.dependency 'tealium', '~> 2.5'
  s.dependency 'tealium-swift/Core', '~> 2.12'
  s.dependency 'TealiumAdobeVisitorAPI', '~> 1.2'
end
