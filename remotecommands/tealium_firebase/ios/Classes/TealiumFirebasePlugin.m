#import "TealiumFirebasePlugin.h"
#if __has_include(<tealium_firebase/tealium_firebase-Swift.h>)
#import <tealium_firebase/tealium_firebase-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tealium_firebase-Swift.h"
#endif

@implementation TealiumFirebasePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTealiumFirebasePlugin registerWithRegistrar:registrar];
}
@end
