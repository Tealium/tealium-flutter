library tealium;

import 'package:flutter/services.dart';
import 'dart:convert';
import 'common.dart';
import 'events/event_emitter.dart';

class Tealium {
  static const String plugin_name = 'Tealium-Flutter';
  static const String plugin_version = '2.0.3';
  static const MethodChannel _channel = const MethodChannel('tealium');
  static EventEmitter emitter = new EventEmitter();
  static Map<String, Function> _remoteCommands = new Map();
  static Map<String, Function> _listeners = new Map();

  /// Initializes Tealium with a [TealiumConfig] object
  ///
  /// [Future<bool>] upon success or failure
  static Future<bool> initialize(TealiumConfig config) async {
    if (config.dispatchers
        .toString()
        .contains(Dispatchers.RemoteCommands.toString())) {
      _handleListener(EventListenerNames.remoteCommand);
    }
    var initialized = await _channel.invokeMethod('initialize', {
      'account': config.account,
      'profile': config.profile,
      'environment': config.environment,
      'collectors': config.collectors,
      'dispatchers': config.dispatchers,
      'dataSource': config.dataSource,
      'customVisitorId': config.customVisitorId,
      'memoryReportingEnabled': config.memoryReportingEnabled,
      'overrideCollectURL': config.overrideCollectURL,
      'overrideCollectProfile': config.overrideCollectProfile,
      'overrideCollectBatchURL': config.overrideCollectBatchURL,
      'overrideCollectDomain': config.overrideCollectDomain,
      'overrideLibrarySettingsURL': config.overrideLibrarySettingsURL,
      'overrideTagManagementURL': config.overrideTagManagementURL,
      'deepLinkTrackingEnabled': config.deepLinkTrackingEnabled,
      'qrTraceEnabled': config.qrTraceEnabled,
      'logLevel': config.logLevel,
      'consentLoggingEnabled': config.consentLoggingEnabled,
      'consentPolicy': config.consentPolicy,
      'consentExpiry': config.consentExpiry,
      'batchingEnabled': config.batchingEnabled,
      'lifecycleAutotrackingEnabled': config.lifecycleAutotrackingEnabled,
      'useRemoteLibrarySettings': config.useRemoteLibrarySettings,
      'visitorServiceEnabled': config.visitorServiceEnabled
    });

    if (initialized) {
      addToDataLayer(
          {'plugin_name': plugin_name, 'plugin_version': plugin_version},
          Expiry.forever);
    }

    return initialized;
  }

  /// Tracks a [TealiumDispatch]
  ///
  /// Accepts a [TealiumView] or [TealiumEvent] type
  static track(TealiumDispatch dispatch) {
    if (dispatch is TealiumView) {
      _channel.invokeMethod('track', {
        'viewName': dispatch.viewName,
        'dataLayer': dispatch.dataLayer,
        'type': 'view'
      });
    } else if (dispatch is TealiumEvent)
      _channel.invokeMethod('track', {
        'eventName': dispatch.eventName,
        'dataLayer': dispatch.dataLayer,
        'type': 'event'
      });
  }

  /// Disables the Tealium instance and all tracking
  static terminateInstance() {
    _channel.invokeMethod('terminateInstance');
  }

  /// Adds a key value pair to the data layer with a specified [Expiry]
  static addToDataLayer(Map<String, Object> data, Expiry expiry) {
    _channel.invokeMethod(
        'addToDataLayer', {'data': data, 'expiry': expiry.toString()});
  }

  /// Removes a List of keys from the data layer
  static removeFromDataLayer(List<String> keys) {
    _channel.invokeMethod('removeFromDataLayer', {'keys': keys});
  }

  /// Retrieves a value from the data layer for a specified key
  ///
  /// [Furture<dynamic>] the value for the key specified if it exists
  static Future<dynamic> getFromDataLayer(String key) async {
    return await _channel.invokeMethod('getFromDataLayer', {'key': key});
  }

  /// Adds a [RemoteCommand] to the [RemoteCommands] Dispatcher
  static addRemoteCommand(String id, Function callback) async {
    if (!_remoteCommands.containsKey(id)) {
      _remoteCommands[id] = callback;
      return await _channel.invokeMethod('addRemoteCommand', {'id': id});
    }
  }

  /// Removes a [RemoteCommand] from the [RemoteCommands] Dispatcher
  static removeRemoteCommand(String id) {
    _remoteCommands.remove(id);
    _channel.invokeMethod('removeRemoteCommand', {'id': id});
  }

  static setConsentStatus(ConsentStatus status) {
    _channel.invokeMethod('setConsentStatus', {'status': status.toString()});
  }

  /// Retrieves the current user [ConsentStatus]
  ///
  /// [Future<String>] [ConsentStatus]
  static Future<String> getConsentStatus() async {
    return await _channel.invokeMethod('getConsentStatus');
  }

  /// Sets a List of [ConsentCategories] for the user
  static setConsentCategories(List<ConsentCategories> categories) {
    var categoriesList = categories.map((item) => item.toString()).toList();
    _channel
        .invokeMethod('setConsentCategories', {'categories': categoriesList});
  }

  /// Retrieves the current [ConsentCategories] for which the user is consented
  ///
  /// [Future<List<dynamic>>] A List of [ConsentCategories]
  static Future<List<dynamic>> getConsentCategories() async {
    return await _channel.invokeMethod('getConsentCategories');
  }

  /// Joins a trace session for a given id
  static joinTrace(String id) {
    _channel.invokeMethod('joinTrace', {'id': id});
  }

  /// Leaves the current trace session
  static leaveTrace() {
    _channel.invokeMethod('leaveTrace');
  }

  /// Retrieves the visitor id for the user
  static Future<String> getVisitorId() async {
    return await _channel.invokeMethod('getVisitorId');
  }

  /// Sets the callback for the [VisitorService] update
  static setVisitorServiceListener(Function callback) {
    _listeners[EventListenerNames.visitor] = callback;
    _handleListener(EventListenerNames.visitor);
  }

  /// Sets the callback for when the user [ConsentExpiry] has expired
  static setConsentExpiryListener(Function callback) async {
    _listeners[EventListenerNames.consentExpired] = callback;
    _handleListener(EventListenerNames.consentExpired);
    return await _channel.invokeMethod('setConsentExpiryListener');
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method.toString() == 'callListener') {
      emitter.emit(
          call.arguments[EventListenerNames.name], null, call.arguments);
    }
  }

  static _handleListener(String eventName) {
    _channel.setMethodCallHandler(_methodCallHandler);
    emitter.on(eventName, {}, (ev, context) {
      switch (eventName) {
        case EventListenerNames.remoteCommand:
          var encodedData = json.encode(ev.eventData);
          var eventDataMap = json.decode(encodedData);
          eventDataMap as Map;
          eventDataMap.remove(EventListenerNames.name);
          var commandID = eventDataMap['command_id'];
          if (commandID != null) {
            Function callback = _remoteCommands[commandID] as Function;
            callback(eventDataMap);
          }
          break;
        case EventListenerNames.consentExpired:
          Function callback = _listeners[EventListenerNames.consentExpired] =
              _listeners[EventListenerNames.consentExpired] as Function;
          callback();
          break;
        case EventListenerNames.visitor:
          var encodedData = json.encode(ev.eventData);
          var eventDataMap = json.decode(encodedData);
          eventDataMap as Map;
          eventDataMap.remove(EventListenerNames.name);
          Function callback = _listeners[EventListenerNames.visitor] =
              _listeners[EventListenerNames.visitor] as Function;
          callback(eventDataMap);
          break;
        default:
          break;
      }
    });
  }
}
