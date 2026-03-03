// Copyright (c) 2019, iMeshAcademy authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// From: https://pub.dev/packages/eventify - Updated for sound safety https://dart.dev/null-safety
import 'event.dart';
import 'listener.dart';

typedef EventCallback = void Function(EmittedEvent ev, Object context);

class EventEmitter {
  final Map<String, Set<EventListener>> _listeners =
      Map<String, Set<EventListener>>();

  /// API to register for notification.
  /// It is mandatory to pass event name and callback parameters.
  EventListener on(String event, Object context, EventCallback? callback) {
    if (null == callback) {
      throw ArgumentError.notNull("callback");
    }

    // Check if the particular listener is there in the listeners collection
    // Return the listener instance, if already registered.
    EventListener? listener;

    Set<EventListener> subs =
        _listeners.putIfAbsent(event, () => Set<EventListener>());

    // Create new element.
    listener = EventListener(event, context, callback, () {
      subs.remove(listener);
      if (subs.isEmpty) {
        _listeners.remove(listener?.eventName);
      }
    });
    subs.add(listener);

    return listener;
  }

  /// Remove event listener from emitter.
  /// This will unsubscribe the caller from the emitter from any future events.
  /// Listener should be a valid instance.
  void off(EventListener listener) {
    // Check if the listner has a valid callback for cancelling the subscription.
    // if (null != listener.cancel) {
    listener.cancel(); // Use the callback to cancel the subscription.
    // }
  }

  /// Unsubscribe from getting any future events from emitter.
  /// This mechanism uses event name and callback to unsubscribe from all possible events.
  void removeListener(String eventName, EventCallback? callback) {
    if (null == callback) {
      throw ArgumentError.notNull("callback");
    }

    // Check if listeners have the specific event already registered.
    // if so, then check for the callback registration.

    if (_listeners.containsKey(eventName)) {
      Set<EventListener>? subs = _listeners[eventName];
      subs?.removeWhere((element) =>
          element.eventName == eventName && element.callback == callback);
    }
  }

  /// API to emit events.
  /// event is a required parameter.
  /// If sender information is sent, it will be used to intimate user about it.
  void emit(String event, [Object? sender, Object? data]) {
    if (_listeners.containsKey(event)) {
      EmittedEvent ev = EmittedEvent(event, data, sender);
      List<EventListener>? sublist = _listeners[event]?.toList();
      sublist?.forEach((item) {
        if (ev.handled) {
          return;
        }
        item.callback(ev, item.context);
      });
    }
  }

  /// Clear all subscribers from the cache.
  void clear() {
    _listeners.clear();
  }

  /// Remove all listeners which matches with the callback provided.
  /// It is possible to register for multiple events with a single callback.
  /// This mechanism makesure that all event registrations would be cancelled which matches the callback.
  void removeAllByCallback(EventCallback callback) {
    _listeners.forEach((key, lst) {
      lst.removeWhere((item) => item.callback == callback);
    });
  }

  /// Use this mechanism to remove all subscription for a particular event.
  /// Caution : This will remove all the listeners from multiple files or classes or modules.
  /// Think twice before calling this API and make sure you know what you are doing!!!
  void removeAllByEvent(String event) {
    _listeners.removeWhere((key, val) => key == event);
  }

  /// Get the unique count of events registered in the emitter.
  int get count => _listeners.length;

  /// Get the list of subscribers for a particular event.
  int getListenersCount(String event) =>
      _listeners.containsKey(event) ? _listeners[event]!.length : 0;
}
