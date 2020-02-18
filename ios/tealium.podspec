#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'tealium'
  s.version          = '0.0.2'
  s.summary          = 'A Tealium Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://tealium.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tealium Mobile Team' => 'integrations.device@tealium.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'TealiumIOS', '<= 5.6.6'
  s.dependency 'TealiumIOSLifecycle', '<= 5.6.6'

  s.ios.deployment_target = '9.0'
  s.static_framework = true
end

