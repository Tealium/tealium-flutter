library tealium;

import 'package:flutter/services.dart';
import 'common.dart';
import 'events/event_emitter.dart';

class Tealium {
  static const String pluginName = 'Tealium-Flutter';
  static const String pluginVersion = '3.0.0';
  static const MethodChannel _channel = MethodChannel('tealium');
  static EventEmitter emitter = EventEmitter();
  static final Map<String, Function> _remoteCommands = Map();
  static final Map<String, Function> _listeners = Map();

  /// Initializes Tealium with a [TealiumConfig] object
  ///
  /// Throws a [PlatformException] on failure.
  static Future<void> initialize(TealiumConfig config) async {
    if (config.dispatchers
        .toString()
        .contains(Dispatchers.RemoteCommands.toString())) {
      _handleListener(EventListenerNames.remoteCommand);
    }
    config.remoteCommands?.forEach((command) {
      var callback = command.callback;
      if (callback != null) {
        _addRemoteCommandListener(command.id, callback);
      }
    });

    await _channel.invokeMethod('initialize', {
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
      'visitorServiceEnabled': config.visitorServiceEnabled,
      'sessionCountingEnabled': config.sessionCountingEnabled,
      'test': "test",
      'remoteCommands': config.remoteCommands
          ?.map((e) => {
                "id": e.id,
                "url": e.url,
                "path": e.path,
              })
          .toList(),
      'visitorIdentityKey': config.visitorIdentityKey
    });

    await addToDataLayer(
        {'plugin_name': pluginName, 'plugin_version': pluginVersion},
        Expiry.forever);
  }

  /// Tracks a [TealiumDispatch]
  ///
  /// Accepts a [TealiumView] or [TealiumEvent] type
  static Future<void> track(TealiumDispatch dispatch) async {
    if (dispatch is TealiumView) {
      await _channel.invokeMethod('track', {
        'viewName': dispatch.viewName,
        'dataLayer': dispatch.dataLayer,
        'type': 'view'
      });
    } else if (dispatch is TealiumEvent) {
      await _channel.invokeMethod('track', {
        'eventName': dispatch.eventName,
        'dataLayer': dispatch.dataLayer,
        'type': 'event'
      });
    }
  }

  /// Disables the Tealium instance and all tracking
  static Future<void> terminateInstance() async {
    await _channel.invokeMethod('terminateInstance');
  }

  /// Adds a key value pair to the data layer with a specified [Expiry]
  static Future<void> addToDataLayer(
      Map<String, Object> data, Expiry expiry,) async {
    await _channel.invokeMethod(
        'addToDataLayer', {'data': data, 'expiry': expiry.toString()});
  }

  /// Removes a List of keys from the data layer
  static Future<void> removeFromDataLayer(List<String> keys) async {
    await _channel.invokeMethod('removeFromDataLayer', {'keys': keys});
  }

  /// Retrieves a value from the data layer for a specified key
  ///
  /// [Furture<dynamic>] the value for the key specified if it exists
  static Future<dynamic> getFromDataLayer(String key) async {
    return await _channel.invokeMethod('getFromDataLayer', {'key': key});
  }

  /// Adds a [RemoteCommand] to the [RemoteCommands] Dispatcher
  static Future<void> addCustomRemoteCommand(
    String id,
    Function callback,
  ) async {
    await addRemoteCommand(RemoteCommand(
      id,
      callback: callback,
      path: null,
      url: null,
    ));
  }

  /// Adds a [RemoteCommand] to the [RemoteCommands] Dispatcher
  static Future<void> addRemoteCommand(RemoteCommand remoteCommand) async {
    if (!_remoteCommands.containsKey(remoteCommand.id)) {
      final callback = remoteCommand.callback;
      if (callback != null) {
        _addRemoteCommandListener(remoteCommand.id, callback);
      }

      await _channel.invokeMethod('addRemoteCommand', {
        'id': remoteCommand.id,
        'path': remoteCommand.path,
        'url': remoteCommand.url,
      });
    }
  }

  /// Removes a [RemoteCommand] from the [RemoteCommands] Dispatcher
  static Future<void> removeRemoteCommand(String id) async {
    _remoteCommands.remove(id);
    await _channel.invokeMethod('removeRemoteCommand', {'id': id});
  }

  static void _addRemoteCommandListener(String id, Function callback) {
    _remoteCommands[id] = callback;
  }

  static Future<void> setConsentStatus(ConsentStatus status) async {
    await _channel
        .invokeMethod('setConsentStatus', {'status': status.toString()});
  }

  /// Retrieves the current user [ConsentStatus]
  ///
  /// [Future<String>] [ConsentStatus]
  static Future<String> getConsentStatus() async {
    return await _channel.invokeMethod('getConsentStatus');
  }

  /// Sets a List of [ConsentCategories] for the user
  static Future<void> setConsentCategories(
      List<ConsentCategories> categories,) async {
    var categoriesList = categories.map((item) => item.toString()).toList();
    await _channel
        .invokeMethod('setConsentCategories', {'categories': categoriesList});
  }

  /// Retrieves the current [ConsentCategories] for which the user is consented
  ///
  /// [Future<List<dynamic>>] A List of [ConsentCategories]
  static Future<List<dynamic>> getConsentCategories() async {
    return await _channel.invokeMethod('getConsentCategories');
  }

  /// Joins a trace session for a given id
  static Future<void> joinTrace(String id) async {
    await _channel.invokeMethod('joinTrace', {'id': id});
  }

  /// Leaves the current trace session
  static Future<void> leaveTrace() async {
    await _channel.invokeMethod('leaveTrace');
  }

  /// Retrieves the visitor id for the user
  static Future<String> getVisitorId() async {
    return await _channel.invokeMethod('getVisitorId');
  }

  /// Resets the visitor id for the user
  static Future<void> resetVisitorId() async {
    await _channel.invokeMethod('resetVisitorId');
  }

  /// Clears all stored visitor ids.
  static Future<void> clearStoredVisitorIds() async {
    await _channel.invokeMethod('clearStoredVisitorIds');
  }

  /// Sets the callback for the [VisitorService] update
  static void setVisitorServiceListener(Function callback) {
    _listeners[EventListenerNames.visitor] = callback;
    _handleListener(EventListenerNames.visitor);
  }

  /// Sets the callback for the Visitor Id update
  static void setVisitorIdListener(Function callback) {
    _listeners[EventListenerNames.visitorId] = callback;
    _handleListener(EventListenerNames.visitorId);
  }

  /// Sets the callback for when the user [ConsentExpiry] has expired
  static Future<void> setConsentExpiryListener(Function callback) async {
    _listeners[EventListenerNames.consentExpired] = callback;
    _handleListener(EventListenerNames.consentExpired);
    await _channel.invokeMethod('setConsentExpiryListener');
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method.toString() == 'callListener') {
      emitter.emit(
          call.arguments[EventListenerNames.name], null, call.arguments);
    }
  }

  /// Retrieves the tracking data from collectors and DataLayer
  ///
  /// [Future<Map<dynamic, dynamic>>] The gathered data
  static Future<Map<dynamic, dynamic>> gatherTrackData() async {
    return await _channel.invokeMethod('gatherTrackData');
  }

  static Map<String, dynamic> _extractEventData(dynamic eventData) {
    return Map<String, dynamic>.from(eventData as Map)
      ..remove(EventListenerNames.name);
  }

  static void _handleListener(String eventName) {
    _channel.setMethodCallHandler(_methodCallHandler);
    emitter.on(eventName, {}, (ev, context) {
      switch (eventName) {
        case EventListenerNames.remoteCommand:
          final eventDataMap = _extractEventData(ev.eventData);
          final commandID = eventDataMap['command_id'];
          if (commandID != null) {
            _remoteCommands[commandID]?.call(eventDataMap);
          }
          break;
        case EventListenerNames.consentExpired:
          _listeners[EventListenerNames.consentExpired]?.call();
          break;
        case EventListenerNames.visitor:
          final eventDataMap = _extractEventData(ev.eventData);
          _listeners[EventListenerNames.visitor]?.call(eventDataMap);
          break;
        case EventListenerNames.visitorId:
          final eventDataMap = _extractEventData(ev.eventData);
          final visitorId = eventDataMap['visitorId'];
          if (visitorId != null) {
            _listeners[EventListenerNames.visitorId]?.call(visitorId);
          }
          break;
        default:
          break;
      }
    });
  }
}
