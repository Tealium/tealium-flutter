import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tealium_moments_api/common.dart';

class TealiumMomentsApi {

  static const _channel = MethodChannel('tealium_moments_api');

  static void configure(MomentsApiConfig config) {
    try {
      _channel.invokeMethod("configure", config.toMap());
    } catch (error) {
      debugPrint("Failed to configure TealiumMomentsApi: '$error'.");
    }
  }

  static Future<void> fetchEngineResponse({
    required String engineId, 
    required Function(dynamic) callback
  }) async {
    try {
      final dynamic response = await _channel.invokeMethod('fetchEngineResponse', {'engineId': engineId});

      if ((Platform.isAndroid || Platform.isIOS) && response is Map<dynamic,dynamic>) {

        Map<String, dynamic> typedResponse = response.map((key, value) => MapEntry(key.toString(), value));
      
        final engineResponse = EngineResponse.fromJson(typedResponse);

        callback(engineResponse);
      }
      else {
        // all other types of response
        callback(response);
      }

    } on PlatformException catch (error) {
      callback("$error");
    }
  }
}