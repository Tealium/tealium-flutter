Pod::Spec.new do |s|
  s.name = 'tealium'
  s.version = '2.0.3'
  s.summary = 'Tealium Flutter Plugin'
  s.description = <<-DESC
                  A Flutter plugin for the Tealium Swift and Kotlin SDKs.
                  DESC
  s.homepage = 'https://github.com/tealium/tealium-flutter'
  s.license = { :file => '../LICENSE' }
  s.authors = { 'Tealium Mobile Team' => 'mobile-team@tealium.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'Flutter'
  s.dependency 'tealium-swift/Core', '~> 2.6.4'
  s.dependency 'tealium-swift/TagManagement', '~> 2.6.4'
  s.dependency 'tealium-swift/Collect', '~> 2.6.4'
  s.dependency 'tealium-swift/Lifecycle', '~> 2.6.4'
  s.dependency 'tealium-swift/RemoteCommands', '~> 2.6.4'
  s.dependency 'tealium-swift/VisitorService', '~> 2.6.4'
end
