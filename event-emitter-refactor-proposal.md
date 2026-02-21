# Proposal: Replace Custom EventEmitter with Dart Streams

## Current State

We maintain a custom `EventEmitter` system (3 files in `tealium/lib/events/`) based on the `eventify` package, adapted for null safety. It handles communication between the native MethodChannel layer and Dart callbacks for 4 event types: `visitor`, `visitorId`, `remoteCommand`, `consentExpired`.

**Issues:**
- No type safety — all event data flows through `Object?` and is manually cast in a switch statement
- Unused features — event bubbling (`handled` flag) and `context` parameter are never utilized
- Non-standard API — external developers expect `Stream`-based APIs from Dart/Flutter packages

## Proposed Change

Replace `EventEmitter` with `StreamController.broadcast()` from `dart:async`.

**Before:**
```dart
static EventEmitter emitter = EventEmitter();

// Emitting
emitter.emit('TealiumFlutter.VisitorServiceEvent', null, data);

// Listening
emitter.on('TealiumFlutter.VisitorServiceEvent', {}, (ev, ctx) {
  callback(ev.eventData);
});
```

**After:**
```dart
static final _visitorController = StreamController<Map>.broadcast();
static Stream<Map> get onVisitorUpdated => _visitorController.stream;

// Emitting
_visitorController.add(profileData);

// Listening
Tealium.onVisitorUpdated.listen((profile) => ...);
```

## Impact

- **Removes** 3 files (`event.dart`, `event_emitter.dart`, `listener.dart`) and the `EventListenerNames` class
- **Changes** the public listener API in `tealium.dart` (e.g. `setVisitorServiceListener` -> stream-based)
- **No new dependencies** — `dart:async` is part of the Dart SDK
- **Breaking change** for existing consumers of `setVisitorServiceListener`, `setVisitorIdListener`, `setConsentExpiryListener`

## Trade-offs

| | Custom EventEmitter | Dart Streams |
|---|---|---|
| Type safety | `Object?` everywhere | Typed per stream |
| Ecosystem fit | Non-standard | Idiomatic Dart |
| Flutter integration | Manual | `StreamBuilder`, `await for` |
| Maintenance | Own code to maintain | SDK-provided |
| Migration cost | n/a | Breaking API change |

---

## Better long-term solution: EventChannel

The above StreamController change is Dart-only and minimal, but it doesn't address the root issue — we currently use `MethodChannel.invokeMethod("callListener")` from native to push events into Dart. This is an anti-pattern. `MethodChannel` is designed for request/response (Dart calls native, gets a result). For native-to-Dart event streaming, Flutter provides [`EventChannel`](https://docs.flutter.dev/platform-integration/platform-channels#step-5-listen-for-events-on-the-dart-side).

With `EventChannel`, the flow becomes:

```
Native event -> EventSink.success(data) -> Dart Stream -> callbacks
```

No custom EventEmitter, no `"callListener"` hack, no `_methodCallHandler` switch/case.

### Scope of native changes

**Android** — 4 call-sites in `Listeners.kt`:
- Add `StreamHandler` implementation (~15 lines of boilerplate)
- Replace `TealiumPlugin.invokeOnMain(methodChannel, "callListener", data)` with `eventSink?.success(data)`

**iOS** — 5 call-sites across 3 files (`SwiftTealiumPlugin.swift`, `SwiftTealiumPluginExtensions.swift`, `VisitorDelegate.swift`):
- Add `FlutterStreamHandler` implementation (~15 lines of boilerplate)
- Replace `Self.invokeOnMain("callListener", arguments: data)` with `eventSink?(data)`

**Dart** — same as the StreamController change above, but the `Stream` comes directly from `EventChannel` instead of a manually-fed `StreamController`. `MethodChannel` stays for request/response only (initialize, track, getVisitorId, etc.).

One `EventChannel` for all 4 event types, demultiplexed by the existing `emitterName` field on the Dart side.

### Implementation example

**Current flow** — consumer must call a setter, we register a MethodChannel handler, native pushes via `invokeMethod`, Dart demuxes through EventEmitter:

```
Consumer                     Dart (tealium.dart)                          Native
   │                                │                                        │
   ├─ setVisitorServiceListener ──> │                                        │
   │   (callback)                   ├─ _channel.setMethodCallHandler(...)    │
   │                                ├─ emitter.on('...VisitorService', ...)  │
   │                                │                                        │
   │                                │    methodChannel.invokeMethod ─────────┤
   │                                │   <── ("callListener", data)           │ (visitor updated)
   │                                │                                        │
   │                                ├─ _methodCallHandler(call)              │
   │                                ├─ emitter.emit(emitterName, data)       │
   │                                ├─ switch(eventName) { ... }             │
   │                                ├─ json.encode → json.decode → cast      │
   │   callback(eventDataMap)  <────┤                                        │
```

```dart
// Consumer
Tealium.setVisitorServiceListener((profile) => print(profile));

// tealium.dart — registers handler + emitter listener
static void setVisitorServiceListener(Function callback) {
  _listeners[EventListenerNames.visitor] = callback;
  _handleListener(EventListenerNames.visitor);
}

static void _handleListener(String eventName) {
  _channel.setMethodCallHandler(_methodCallHandler);
  emitter.on(eventName, {}, (ev, context) {
    switch (eventName) {
      case EventListenerNames.visitor:
        var encodedData = json.encode(ev.eventData);
        var eventDataMap = json.decode(encodedData);
        // ... cast, remove emitterName key, invoke callback
    }
  });
}
```

**EventChannel flow** — native pushes events into an `EventSink`, Dart gets a `Stream` directly. No setter required, no EventEmitter, no MethodChannel handler:

```
Consumer                     Dart (tealium.dart)                          Native
   │                                │                                        │
   │                                │  EventChannel("tealium/events")        │
   │                                │  ──── stream connected ──────────────> │
   │                                │                                        │
   │                                │    eventSink.success(data) ───────────┤
   │                                │   <── Stream event                     │ (visitor updated)
   │                                │                                        │
   │   stream event             <───┤  (demux by emitterName)                │
```

```dart
// Dart side — setup once during initialize
static final EventChannel _eventChannel = EventChannel('tealium/events');
static Stream<Map>? _onVisitorUpdated;

static Stream<Map> get onVisitorUpdated {
  _onVisitorUpdated ??= _eventChannel
    .receiveBroadcastStream()
    .where((event) => event['emitterName'] == 'TealiumFlutter.VisitorServiceEvent')
    .map((event) {
      final map = Map<String, dynamic>.from(event);
      map.remove('emitterName');
      return map;
    });
  return _onVisitorUpdated!;
}

// Consumer — just listen to a stream
Tealium.onVisitorUpdated.listen((profile) => print(profile));
```

```kotlin
// Android — StreamHandler replaces invokeOnMain("callListener")
class TealiumEventStreamHandler : EventChannel.StreamHandler {
    var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}

// In Listeners.kt — one-line change per call-site
override fun onVisitorUpdated(visitorProfile: VisitorProfile) {
    val map = VisitorProfile.toFriendlyMutableMap(visitorProfile)
    map["emitterName"] = "TealiumFlutter.VisitorServiceEvent"
    streamHandler.eventSink?.success(map)  // was: invokeOnMain(methodChannel, "callListener", map)
}
```

```swift
// iOS — FlutterStreamHandler replaces invokeOnMain("callListener")
class TealiumEventStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

// In VisitorDelegate.swift — one-line change
func didUpdate(visitorProfile: TealiumVisitorProfile) {
    var payload = convert(visitorProfile)
    payload["emitterName"] = "TealiumFlutter.VisitorServiceEvent"
    streamHandler.eventSink?(payload)  // was: invokeOnMain("callListener", arguments: payload)
}
```

### What do the native SDKs use internally?

The native Tealium SDKs do **not** use a unified stream/reactive pattern — they expose events through a mix of traditional mechanisms:

| Event | TealiumSwift (iOS) | Tealium Kotlin (Android) |
|---|---|---|
| Visitor Service | Delegate protocol | Listener interface |
| Visitor ID | Custom reactive observable (`TealiumReplaySubject`) | Listener interface |
| Consent Expiry | Closure callback | Listener interface |
| Remote Commands | Completion handler | Class override (`onInvoke`) |

Only `onVisitorId` on iOS uses a reactive/stream-like pattern. Everything else is traditional callbacks/delegates/listeners. This means there's no opportunity for a direct "stream-to-stream" bridge — the native side will always need to convert from its callback/delegate into whatever transport we use (whether `invokeMethod` or `eventSink`).

EventChannel is still the right choice because it **unifies these 4 different native patterns** into one consistent Dart `Stream` API, and uses the Flutter-intended transport for native-to-Dart events.

### Comparison

| | StreamController (Dart-only) | EventChannel |
|---|---|---|
| MethodChannel misuse | Still present | Eliminated |
| Flutter guidelines | Partially compliant | Fully compliant |
| Native changes required | None | ~20 lines per platform |
| Unifies native patterns | No (still routes through MethodChannel) | Yes (all → EventSink → Stream) |
| Risk | Minimal | Low (mechanical changes) |

---

## Summary: what changes where

### New files

| File | What |
|---|---|
| `tealium/android/.../TealiumEventStreamHandler.kt` | `EventChannel.StreamHandler` — holds `eventSink`, ~15 lines |
| `tealium/ios/Classes/TealiumEventStreamHandler.swift` | `FlutterStreamHandler` — holds `eventSink`, ~15 lines |

### Deleted files

| File | Why |
|---|---|
| `tealium/lib/events/event.dart` | `EmittedEvent` class — unused with streams |
| `tealium/lib/events/event_emitter.dart` | `EventEmitter` class — replaced by EventChannel |
| `tealium/lib/events/listener.dart` | `EventListener` class — replaced by `StreamSubscription` |

### Modified files

**Android:**

| File | Line(s) | Current | New |
|---|---|---|---|
| `TealiumPlugin.kt` | 121 | — | Register `EventChannel("tealium/events")` with `StreamHandler` |
| `TealiumPlugin.kt` | 328-331 | `invokeOnMain()` helper | Can be removed (only used for `"callListener"`) |
| `Listeners.kt` | 21 | `invokeOnMain(methodChannel, "callListener", it.toMap())` | `streamHandler.eventSink?.success(it.toMap())` |
| `Listeners.kt` | 29-34 | `invokeOnMain(methodChannel, "callListener", mapOf(...))` | `streamHandler.eventSink?.success(mapOf(...))` |
| `Listeners.kt` | 43-47 | `invokeOnMain(methodChannel, "callListener", mapOf(...))` | `streamHandler.eventSink?.success(mapOf(...))` |
| `Listeners.kt` | 61 | `invokeOnMain(methodChannel, "callListener", map.toMap())` | `streamHandler.eventSink?.success(map.toMap())` |

**iOS:**

| File | Line(s) | Current | New |
|---|---|---|---|
| `SwiftTealiumPlugin.swift` | 17 | — | Register `FlutterEventChannel(name: "tealium/events")` with `StreamHandler` |
| `SwiftTealiumPlugin.swift` | 116 | `Self.invokeOnMain("callListener", arguments: [...])` | `streamHandler.eventSink?([...])` |
| `SwiftTealiumPlugin.swift` | 252 | `Self.invokeOnMain("callListener", arguments: [...])` | `streamHandler.eventSink?([...])` |
| `SwiftTealiumPluginExtensions.swift` | 26 | `Self.invokeOnMain("callListener", arguments: payload)` | `streamHandler.eventSink?(payload)` |
| `SwiftTealiumPluginExtensions.swift` | 232 | `Self.invokeOnMain("callListener", arguments: payload)` | `streamHandler.eventSink?(payload)` |
| `VisitorDelegate.swift` | 7 | `SwiftTealiumPlugin.invokeOnMain("callListener", arguments: payload)` | `streamHandler.eventSink?(payload)` |
| `SwiftTealiumPlugin.swift` | 273-278 | `invokeOnMain()` helper | Can be removed |

**Dart:**

| File | What changes |
|---|---|
| `tealium/lib/tealium.dart` | Remove: `EventEmitter emitter`, `_methodCallHandler`, `_handleListener`, `_listeners` map. Add: `EventChannel`, typed stream getters (`onVisitorUpdated`, `onVisitorIdUpdated`, `onConsentExpired`, `onRemoteCommand`). Keep: `MethodChannel` for request/response. |
| `tealium/lib/common.dart` | Remove `EventListenerNames` class (emitterName constants stay as internal demux keys) |
| `tealium/example/lib/main.dart` | Replace `setVisitorServiceListener((p) => ...)` with `Tealium.onVisitorUpdated.listen((p) => ...)` etc. |
