#import "TealiumAdobeVisitorPlugin.h"
#if __has_include(<tealium_adobevisitor/tealium_adobevisitor-Swift.h>)
#import <tealium_adobevisitor/tealium_adobevisitor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tealium_adobevisitor-Swift.h"
#endif

@implementation TealiumAdobeVisitorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTealiumAdobeVisitorPlugin registerWithRegistrar:registrar];
}
@end
