import 'package:flutter/services.dart';
import 'package:tealium_adobevisitor/common.dart';


class TealiumAdobeVisitor {

  static const _channel = MethodChannel('tealium_adobevisitor');

  static void configure(AdobeVisitorConfig config) {
    _channel.invokeMethod("configure", {
      "adobeVisitorOrgId": config.adobeVisitorOrgId,
      "adobeVisitorRetries": config.adobeVisitorRetries,
      "adobeVisitorDataProviderId": config.adobeVisitorDataProviderId,
      "adobeVisitorAuthState": config.adobeVisitorAuthState?.intValue,
      "adobeVisitorExistingEcid": config.adobeVisitorExistingEcid,
      "adobeVisitorCustomVisitorId": config.adobeVisitorCustomVisitorId,
    });
  }

  static Future<AdobeVisitor?> getAdobeVisitor() async {
    var visitorMap = await _channel.invokeMethod("getAdobeVisitor");

    return adobeVisitorFromMap(visitorMap);
  }

  static void resetVisitor() {
    _channel.invokeMethod("resetVisitor");
  }

  static Future<String?> decorateUrl(String url) async {
    return _channel.invokeMethod("decorateUrl", { "url": url });
  }

  static Future<Map<Object?, Object?>?> getUrlParameters() async {
    return _channel.invokeMethod("getUrlParameters");
  }

  static Future<AdobeVisitor?> linkEcidToKnownIdentifier(String knownId, String adobeDataProviderId, AuthState? authState) async {
    var visitorMap = await _channel.invokeMethod("linkEcidToKnownIdentifier", { 
        "knownId": knownId, 
        "adobeDataProviderId" : adobeDataProviderId, 
        "authState" : authState?.intValue
      });

    return adobeVisitorFromMap(visitorMap);
  }

  static AdobeVisitor? adobeVisitorFromMap(Map<Object?, Object?>? map) {
    if (map == null) return null;
    
    return AdobeVisitor(
        map["experienceCloudId"] as String, 
        map["idSyncTtl"] as int, 
        map["region"] as int, 
        map["blob"] as String, 
        map["nextRefresh"] as int 
      );
  }
}
