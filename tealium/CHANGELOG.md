## 2.X 

[Full documentation](https://docs.tealium.com/platforms/flutter/install/)

### 2.4.1 (Jan 2024)
* Fix: Remote Commands with local mappings incorrectly set as `.webview`

### 2.4.0 (Apr 2023)
* Visitor Service (Android)
    - Fixed a case where event tracking would be delayed whilst fetching an updated visitor profile.
* Lifecycle (Android)
    - Fixed a case where the initial launch event is not sent until the first wake/sleep is triggered.
* Kotlin dependencies updated

### 2.3.0 (Jan 2023)
* `OptionalModule` added to support adding of additional modules
* Adobe Visitor API module support

### 2.2.0 (Jan 2023)
* Support for Visitor Switching
    - New config key: `visitorIdentityKey`
    - New methods: `resetVisitorId()` and `clearStoredVisitorIds()`
    - New Visitor Id Updated listener: `setVisitorIdListener((visitorId) => { /* */ })`
* Tealium Swift/Kotlin SDK Dependency updates

### 2.1.0 (Sep 2022)
* Support for packaged Remote Commands
* Fix for RemoteCommands callback not being executed
* Breaking change - new `addRemoteCommand` method added to accept more flexible implementation. Previous method renamed to `addCustomRemoteCommand`

### 2.0.3 (June 2022)
* Kotlin dependency upgraded to 1.4.1.
* Swift dependency upgraded to 2.6.4.
* Increaseed iOS min version to 11.0.
* Added `overrideCollectProfile` and `sessionCountingEnabled` keys to the config.
* Added `gatherTrackData` method to tealium instance.
* Kotlin: Fixed lifecycle that was being initialized even if not added to the config.

### 2.0.2 (November 2021)
* Updated kotlin and swift tealium dependency versions.

### 2.0.1 (August 2021)
* Kotlin 
* Changed collectors to include TimeCollector by default in keeping with Swift.
* Updated Kotlin SDK dependencies
* Fix - LogLevel configuration was being ignored

### 2.0.0 (April 2021)
* Initial release. Updated the plugin to use the Kotlin and Swift libraries.

## 1.X 

### 1.2.0 (February 2020)
* Added support for Remote Commands
* Underlying Tealium libraries updated to versions 5.7.0 (Android) and 5.6.6 (iOS) 

### 1.0.1 (August 2019)
* Update documentation link

### 1.0.0 (July 2019)
* Initial release
    - Tealium and TealiumLifecycle support for Android and iOS
