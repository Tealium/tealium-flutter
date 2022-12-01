#import "TealiumPlugin.h"
#if __has_include(<tealium/tealium-Swift.h>)
#import <tealium/tealium-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tealium-Swift.h"
#endif

@implementation TealiumPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTealiumPlugin registerWithRegistrar:registrar];
}
@end
