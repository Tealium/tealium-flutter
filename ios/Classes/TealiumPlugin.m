#import "TealiumPlugin.h"

NSString *tealiumInternalInstanceName;

@implementation TealiumPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"tealium"
                  binaryMessenger:[registrar messenger]];
    TealiumPlugin *instance = [[TealiumPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"initialize" isEqualToString:call.method]) {
        [self initialize:call result:result];

    } else if ([@"initializeWithConsentManager" isEqualToString:call.method]) {
        [self initializeWithConsentManager:call result:result];

    } else if ([@"initializeCustom" isEqualToString:call.method]) {
        [self initializeCustom:call result:result];

    } else if ([@"trackEvent" isEqualToString:call.method]) {
        [self trackEvent:call result:result];

    } else if ([@"trackEventForInstance" isEqualToString:call.method]) {
        [self trackEventForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"trackView" isEqualToString:call.method]) {
        [self trackView:call result:result];

    } else if ([@"trackViewForInstance" isEqualToString:call.method]) {
        [self trackEventForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"setVolatileData" isEqualToString:call.method]) {
        [self setVolatileData:call result:result];

    } else if ([@"setVolatileDataForInstance" isEqualToString:call.method]) {
        [self setVolatileDataForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"setPersistentData" isEqualToString:call.method]) {
        [self setPersistentData:call result:result];

    } else if ([@"setPersistentDataForInstance" isEqualToString:call.method]) {
        [self setPersistentDataForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"removeVolatileData" isEqualToString:call.method]) {
        [self removeVolatileData:call result:result];

    } else if ([@"removeVolatileDataForInstance" isEqualToString:call.method]) {
        [self removeVolatileDataForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"removePersistentData" isEqualToString:call.method]) {
        [self removePersistentData:call result:result];

    } else if ([@"removePersistentDataForInstance" isEqualToString:call.method]) {
        [self removeVolatileDataForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"getVolatileData" isEqualToString:call.method]) {
        [self getVolatileData:call result:result];

    } else if ([@"getVolatileDataForInstance" isEqualToString:call.method]) {
        [self getVolatileDataForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"getPersistentData" isEqualToString:call.method]) {
        [self getPersistentData:call result:result];

    } else if ([@"getPersistentDataForInstance" isEqualToString:call.method]) {
        [self getPersistentDataForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"getVisitorId" isEqualToString:call.method]) {
        [self getVisitorId:result];

    } else if ([@"getVisitorIdForInstance" isEqualToString:call.method]) {
        [self getVisitorIdForInstance:call.arguments[@"instance"] result:result];

    } else if ([@"getUserConsentStatus" isEqualToString:call.method]) {
        [self getUserConsentStatus:result];

    } else if ([@"getUserConsentStatusForInstance" isEqualToString:call.method]) {
        [self getUserConsentStatusForInstance:call.arguments[@"instance"] result:result];

    } else if ([@"setUserConsentStatus" isEqualToString:call.method]) {
        [self setUserConsentStatus:call result:result];

    } else if ([@"setUserConsentStatusForInstance" isEqualToString:call.method]) {
        [self setUserConsentStatusForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"getUserConsentCategories" isEqualToString:call.method]) {
        [self getUserConsentCategories:result];

    } else if ([@"getUserConsentCategoriesForInstance" isEqualToString:call.method]) {
        [self getUserConsentCategoriesForInstance:call.arguments[@"instance"] result:result];

    } else if ([@"setUserConsentCategories" isEqualToString:call.method]) {
        [self setUserConsentCategories:call result:result];

    } else if ([@"setUserConsentCategoriesForInstance" isEqualToString:call.method]) {
        [self setUserConsentCategoriesForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"resetUserConsentPreferences" isEqualToString:call.method]) {
        [self resetUserConsentPreferences];

    } else if ([@"resentUserConsentPreferencesForInstance" isEqualToString:call.method]) {
        [self resetUserConsentPreferencesForInstance:call.arguments[@"instance"]];

    } else if ([@"setConsentLoggingEnabled" isEqualToString:call.method]) {
        [self setConsentLoggingEnabled:call result:result];

    } else if ([@"setConsentLoggingEnabledForInstance" isEqualToString:call.method]) {
        [self setConsentLoggingEnabledForInstance:call.arguments[@"instance"] call:call result:result];

    } else if ([@"isConsentLoggingEnabled" isEqualToString:call.method]) {
        [self isConsentLoggingEnabled:result];

    } else if ([@"isConsentLoggingEnabledForInstance" isEqualToString:call.method]) {
        [self isConsentLoggingEnabledForInstance:call.arguments[@"instance"] result:result];

    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initialize:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *account = call.arguments[@"account"];
    NSString *profile = call.arguments[@"profile"];
    NSString *environment = call.arguments[@"environment"];
    NSString *iosDatasource = call.arguments[@"iosDatasource"];
    NSString *instance = call.arguments[@"instance"];
    NSString *isLifecycleEnabled = call.arguments[@"isLifecycleEnabled"];

    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:account
                                                                           profile:profile
                                                                       environment:environment
                                                                        datasource:iosDatasource];
    [configuration setAutotrackingLifecycleEnabled:isLifecycleEnabled];
    tealiumInternalInstanceName = instance;
    [Tealium newInstanceForKey:tealiumInternalInstanceName configuration:configuration];
}

- (void)initializeWithConsentManager:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *account = call.arguments[@"account"];
    NSString *profile = call.arguments[@"profile"];
    NSString *environment = call.arguments[@"environment"];
    NSString *iosDatasource = call.arguments[@"iosDatasource"];
    NSString *instance = call.arguments[@"instance"];
    NSString *isLifecycleEnabled = call.arguments[@"isLifecycleEnabled"];

    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:account
                                                                           profile:profile
                                                                       environment:environment
                                                                        datasource:iosDatasource];
    [configuration setAutotrackingLifecycleEnabled:isLifecycleEnabled];
    configuration.enableConsentManager = YES;
    tealiumInternalInstanceName = instance;
    [Tealium newInstanceForKey:tealiumInternalInstanceName configuration:configuration];
}

- (void)initializeCustom:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *account = call.arguments[@"account"];
    NSString *profile = call.arguments[@"profile"];
    NSString *environment = call.arguments[@"environment"];
    NSString *iosDatasource = call.arguments[@"iosDatasource"];
    NSString *instance = call.arguments[@"instance"];
    NSString *isLifecycleEnabled = call.arguments[@"isLifecycleEnabled"];
    NSString *overridePublisthSettingsUrl = call.arguments[@"overridePublishSettingsUrl"];
    NSString *overrideTagManagementUrl = call.arguments[@"overrideTagManagementUrl"];
    BOOL enableConsentManager = call.arguments[@"enableConsentManager"];

    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:account
                                                                           profile:profile
                                                                       environment:environment
                                                                        datasource:iosDatasource];
    tealiumInternalInstanceName = instance;
    [configuration setAutotrackingLifecycleEnabled:isLifecycleEnabled];
    if (overridePublisthSettingsUrl != [NSNull null]) {
        configuration.overridePublishSettingsURL = overridePublisthSettingsUrl;
    }
    if (overrideTagManagementUrl != [NSNull null]) {
        configuration.overrideTagManagementURL = overrideTagManagementUrl;
    }

    if (enableConsentManager) {
        configuration.enableConsentManager = YES;
    }

    [Tealium newInstanceForKey:tealiumInternalInstanceName configuration:configuration];
}

- (void)trackEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self trackEventForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)trackEventForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *eventName = call.arguments[@"eventName"];
    NSDictionary *data = call.arguments[@"data"];

    if (data == [NSNull null]) {
        data = nil;
    }
    Tealium *tealium = [Tealium instanceForKey:instance];
    [tealium trackEventWithTitle:eventName dataSources:data];
}

- (void)trackView:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self trackViewForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)trackViewForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *eventName = call.arguments[@"viewName"];
    NSDictionary *data = call.arguments[@"data"];
    if (data == [NSNull null]) {
        data = nil;
    }
    Tealium *tealium = [Tealium instanceForKey:instance];
    [tealium trackViewWithTitle:eventName dataSources:data];
}

- (void)setVolatileData:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self setVolatileDataForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)setVolatileDataForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *data = call.arguments[@"data"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [tealium addVolatileDataSources:data];
}

- (void)setPersistentData:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self setPersistentDataForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)setPersistentDataForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *data = call.arguments[@"data"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [tealium addPersistentDataSources:data];
}

- (void)removeVolatileData:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self removeVolatileDataForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)removeVolatileDataForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *keys = call.arguments[@"keys"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [tealium removeVolatileDataSourcesForKeys:keys];
}

- (void)removePersistentData:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self removePersistentDataForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)removePersistentDataForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *keys = call.arguments[@"keys"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [tealium removePersistentDataSourcesForKeys:keys];
}

- (void)getVolatileData:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self getVolatileDataForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)getVolatileDataForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *key = call.arguments[@"key"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    id value = [tealium volatileDataSourcesCopy][key];
    result(value);
}

- (void)getPersistentData:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self getPersistentDataForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)getPersistentDataForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *key = call.arguments[@"key"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    id value = [tealium persistentDataSourcesCopy][key];
    result(value);
}

- (void)getVisitorId:(FlutterResult)result {
    [self getVisitorIdForInstance:tealiumInternalInstanceName result:result];
}

- (void)getVisitorIdForInstance:(NSString *)instance result:(FlutterResult)result {
    Tealium *tealium = [Tealium instanceForKey:instance];
    result([tealium visitorIDCopy]);
}

- (void)getUserConsentStatus:(FlutterResult)result {
    [self getUserConsentStatusForInstance:tealiumInternalInstanceName result:result];
}

- (void)getUserConsentStatusForInstance:(NSString *)instance result:(FlutterResult)result {
    Tealium *tealium = [Tealium instanceForKey:instance];
    [TEALConsentManager consentStatusString:[[tealium consentManager] userConsentStatus]];
    result([TEALConsentManager consentStatusString:[[tealium consentManager] userConsentStatus]]);
}

- (void)setUserConsentStatus:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self setUserConsentStatusForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)setUserConsentStatusForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *userConsentStatus = (NSNumber *) call.arguments[@"userConsentStatus"];
    NSInteger user = [userConsentStatus integerValue];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [[tealium consentManager] setUserConsentStatus:user];
}

- (void)getUserConsentCategories:(FlutterResult)result {
    [self getUserConsentCategoriesForInstance:tealiumInternalInstanceName result:result];
}

- (void)getUserConsentCategoriesForInstance:(NSString *)instance result:(FlutterResult)result {
    Tealium *tealium = [Tealium instanceForKey:instance];
    result([[tealium consentManager] userConsentCategories]);
}

- (void)setUserConsentCategories:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self setUserConsentCategoriesForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)setUserConsentCategoriesForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *categories = call.arguments[@"categories"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [[tealium consentManager] setUserConsentCategories:categories];
}

- (void)resetUserConsentPreferences {
    [self resetUserConsentPreferencesForInstance:tealiumInternalInstanceName];
}

- (void)resetUserConsentPreferencesForInstance:(NSString *)instance {
    Tealium *tealium = [Tealium instanceForKey:instance];
    [[tealium consentManager] resetUserConsentPreferences];
}

- (void)setConsentLoggingEnabled:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self setConsentLoggingEnabledForInstance:tealiumInternalInstanceName call:call result:result];
}

- (void)setConsentLoggingEnabledForInstance:(NSString *)instance call:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = call.arguments[@"isConsentLoggingEnabled"];
    Tealium *tealium = [Tealium instanceForKey:instance];
    [[tealium consentManager] setConsentLoggingEnabled:enable];
}

- (void)isConsentLoggingEnabled:(FlutterResult)result {
    [self isConsentLoggingEnabledForInstance:tealiumInternalInstanceName result:result];
}

- (void)isConsentLoggingEnabledForInstance:(NSString *)instance result:(FlutterResult)result {
    Tealium *tealium = [Tealium instanceForKey:instance];
    [[tealium consentManager] isConsentLoggingEnabled];
}

@end
