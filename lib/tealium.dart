import 'dart:async';

import 'package:flutter/services.dart';

class Tealium {
  static const MethodChannel _channel =
      const MethodChannel('tealium');

  /// Initialize Tealium instance with minimum necessities
  ///
  static initialize(String account,
      String profile,
      String environment,
      String iosDatasource,
      String androidDatasource,
      [String instance = "MAIN",
        bool isLifecycleEnabled = true]) async {
    _channel.invokeMethod('initialize', {'account' : account,
      'profile' : profile,
      'environment' : environment,
      'iosDatasource' : iosDatasource,
      'androidDatasouce' : androidDatasource,
      'instance' :instance,
      'isLifecycleEnabled' : isLifecycleEnabled });
  }

  /// Initialize Tealium instance and enable Consent Manager
  ///
  static initializeWithConsentManager(String account,
      String profile,
      String environment,
      String iosDatasource,
      String androidDatasource,
      [String instance = "MAIN",
        bool isLifecycleEnabled = true]) {
    _channel.invokeMethod('initializeWithConsentManager', {'account': account,
      'profile' : profile,
      'environment' : environment,
      'iosDatasource' : iosDatasource,
      'androidDatasource' : androidDatasource,
      'instance' : instance,
      'isLifecycleEnabled' : isLifecycleEnabled});
  }

  /// Initialize a custom Tealium instance
  static initializeCustom(String account,
      String profile,
      String environment,
      String iosDatasource,
      String androidDatasource,
      String instance,
      bool isLifecycleEnabled,
      String overridePublishSettingsUrl,
      String overrideTagManagementUrl,
      String enableVdataCollectEndpointUrl,
      bool enableConsentManager) {
    _channel.invokeMethod('initializeCustom', {'account': account,
      'profile' : profile,
      'environment' : environment,
      'iosDatasource' : iosDatasource,
      'androidDatasource' : androidDatasource,
      'instance' : instance,
      'isLifecycleEnabled' : isLifecycleEnabled,
      'overridePublishSettingsUrl' : overridePublishSettingsUrl,
      'overrideTagManagementUrl' : overrideTagManagementUrl,
      'enableConsentManager' : enableConsentManager});
  }

  /// Track event - requires a string event name and optional data map
  static trackEvent(String eventName, [Map<String, dynamic> data]) {
    _channel.invokeMethod('trackEvent', {'eventName' : eventName, 'data' : data});
  }

  ///Track event for specific tealium instance - requires tealium instance name, event name, and optional data map
  static trackEventForInstance(String instance, String eventName, [Map<String, dynamic> data]) {
    _channel.invokeMethod('trackEventForInstance', {'instance': instance, 'eventName': eventName, 'data' : data});
  }

  ///Track view - requires string screen view name and optional data map
  static trackView(String viewName, [Map<String, dynamic> data]) {
    _channel.invokeMethod('trackView', {'viewName' : viewName, 'data': data});
  }

  ///Track View for specific tealium instance - requires string tealium instance name, string screen view name, and optional data map
  static trackViewForInstance(String instance, String viewName, [Map<String, dynamic> data]) {
    _channel.invokeMethod('trackViewForInstance', {'instance': instance, 'viewName': viewName, 'data' : data});
  }

  ///Set volatile data - requires data map
  static setVolatileData(Map<String, dynamic> data) {
    _channel.invokeMethod('setVolatileData', {'data' : data});
  }

  ///Set volatile data for specific tealium instance - requires string tealium instance name and data map
  static setVolatileDataForInstance(String instance, Map<String, dynamic> data) {
    _channel.invokeMethod('setVolatileDataForInstance', {'instance': instance, 'data' : data});
  }

  ///Set persistent data - requires data map
  static setPersistentData(Map<String, dynamic> data) {
    _channel.invokeMethod('setPersistentData', {'data' : data});
  }

  ///Set persistent data for specific tealium instance - requires string tealium instance name and data map
  static setPersistentDataForInstance(String instance, Map<String, dynamic> data) {
    _channel.invokeMethod('setPersistentDataForInstance', {'instance': instance, 'data' : data});
  }

  ///Remove volatile data - requires list with string key names
  static removeVolatileData(List<String> keys) {
    _channel.invokeMethod('removeVolatileData', {'keys' : keys});
  }

  ///Remove volatile data for specific tealium instance - requires string tealium instance name and list with string key names
  static removeVolatileDataForInstance(String instance, List<String> keys) {
    _channel.invokeMethod('removeVolatileDataForInstance', {'instance': instance, 'keys' : keys});
  }

  ///Remove persistent data - requires list with string key names
  static removePersistentData(List<String> keys) {
    _channel.invokeMethod('removePersistentData', {'keys' : keys});
  }

  ///Remove persistent data for specific tealium instance - requires string tealium instance name and list with string key names
  static removePersistentDataForInstance(String instance, List<String> keys) {
    _channel.invokeMethod('removePersistentDataForInstance', {'instance': instance, 'keys' : keys});
  }

  ///Retrieve volatile data - requires string key name
  static  getVolatileData(String key) async{
    return await _channel.invokeMethod('getVolatileData', {'key' : key});
  }

  ///Retrieve volatile data for specific tealium instance - requires string tealium instance name and string key name
  static getVolatileDataForInstance(String instance, String key) async{
    return await _channel.invokeMethod('getVolatileDataForInstance', {'instance': instance, 'key' : key});
  }

  ///Retrieve persistent data - requires string key name
  static getPersistentData(String key) async{
    return await _channel.invokeMethod('getPersistentData', {'key' : key});
  }

  ///Retrieve persistent data for specific tealium instance - requires string tealium instance name and string key name
  static getPersistentDataForInstance(String instance, String key) async{
    return await _channel.invokeMethod('getPersistentDataForInstance', {'instance': instance, 'key' : key});
  }

  ///Retrieve visitor id
  static getVisitorId() async{
    final String visitorId = await _channel.invokeMethod('getVisitorId');
    return visitorId;
  }

  ///Retrieve visitor id for specific tealium instance - requires string tealium instance name
  static getVisitorIdForInstance(String instance) async{
    final String visitorId = await _channel.invokeMethod('getVisitorIdForInstance', {'instance': instance});
    return visitorId;
  }

  ///Retrieve consent status for user
  static getUserConsentStatus() async{
    final String userConsentStatus = await _channel.invokeMethod('getUserConsentStatus');
    return userConsentStatus;
  }

  ///Retrieve consent status for user for a specific tealium instance - requires string tealium instance name
  static getUserConsentStatusForInstance(String instance) async{
    final String userConsentStatus = await _channel.invokeMethod('getUserConsentStatusForInstance', {'instance': instance});
    return userConsentStatus;
  }

  ///Set constent status for user - requires int consent status
  static setUserConsentStatus(int userConsentStatus) {
    _channel.invokeMethod('setUserConsentStatus', {'userConsentStatus' : userConsentStatus});
  }

  ///Set constent status for user for specific tealium instance - requires string tealium instance name and int consent status
  static setUserConsentStatusForInstance(String instance, int userConsentStatus) {
    _channel.invokeMethod('setUserConsentStatusForInstance', {'instance': instance, 'userConsentStatus' : userConsentStatus});
  }

  ///Retrieve consent categories for user
  static getUserConsentCategories() async{
    final List categories = await _channel.invokeMethod('getUserConsentCategories');
    return categories;
  }

  ///Retrieve consent categories for user for specific tealium instance - requires tealium instance name
  static getUserConsentCategoriesForInstance(String instance) async{
    final List categories = await _channel.invokeMethod('getUserConsentCategories');
    return categories;
  }

  ///Set consent categories for user - requires list of string categories
  static setUserConsentCategories(List<String> categories) {
    _channel.invokeMethod('setUserConsentCategories', {'categories' : categories});
  }

  ///Set consent categories for user for specific tealium instance - requires string tealium instance name and list of string categories
  static setUserConsentCategoriesForInstance(String instance, List<String> categories) {
    _channel.invokeMethod('setUserConsentCategoriesForInstance', {'instance': instance, 'categories' : categories});
  }

  ///Reset user's consent preferences
  static resetUserConsentPreferences() {
    _channel.invokeMethod('resetUserConsentPreferences');
  }

  ///Reset user's consent preferences for specific tealium instance - requires string tealium instance name
  static resetUserConsentPreferencesForInstance(String instance) {
    _channel.invokeMethod('resetUserConsentPreferences', {'instance' : instance});
  }

  ///Set consent logging - requires bool
  static setConsentLoggingEnabled(bool isConsentLoggingEnabled) {
    _channel.invokeMethod('setConsentLoggingEnabled', {'isConsentLoggingEnabled' : isConsentLoggingEnabled});
  }

  ///Set consent logging for specific tealium instance - requires string tealium instance name and bool
  static setConsentLoggingEnabledForInstance(String instance, bool isConsentLoggingEnabled) {
    _channel.invokeMethod('setConsentLoggingEnabledForInstance', {'instance': instance, 'isConsentLoggingEnabled' : isConsentLoggingEnabled});
  }

  ///Retrieve consent logging preference
  static isConsentLoggingEnabled() async{
    final bool isConsentLoggingEnabled = await _channel.invokeMethod('isConsentLoggingEnabled');
    return isConsentLoggingEnabled;
  }

  ///Retrieve consent logging preference for specific tealium instance - requires string tealium instance name
  static isConsentLoggingEnabledForInstance(String instance) async{
    final bool isConsentLoggingEnabled = await _channel.invokeMethod('isConsentLoggingEnabledForInstance', {'instance': instance});
    return isConsentLoggingEnabled;
  }


}
