import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:tealium/common.dart';
import 'package:tealium/tealium.dart';
import 'package:tealium_example/tealium_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final traceIdValue = TextEditingController();
  String result = '';

  // MARK: Tealium Configuration

  var config = TealiumConfig(
      'tealiummobile',
      'demo',
      TealiumEnvironment.dev,
      [Collectors.AppData, Collectors.Lifecycle],
      [Dispatchers.RemoteCommands, Dispatchers.TagManagement],
      consentPolicy: ConsentPolicy.GDPR,
      useRemoteLibrarySettings: true,
      batchingEnabled: false,
      visitorServiceEnabled: true,
      consentExpiry: ConsentExpiry(5, TimeUnit.MINUTES));

  @override
  void initState() {
    super.initState();
  }

  ListView _listView() {
    // MARK: Initialize Tealium

    Tealium.initialize(config).then((value) => {
          developer.log('Tealium Initialized'),
          Tealium.setConsentStatus(ConsentStatus.consented),
          Tealium.setConsentExpiryListener(
              () => developer.log('Consent Expired')),
          Tealium.setVisitorServiceListener(
              (profile) => _logVisitorProfile(profile)),
          Tealium.addRemoteCommand(
              'json-test', (payload) => {
                _logRemoteCommand('JSON Test', payload)
              })
        });

    return new ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Padding(padding: EdgeInsets.all(3.5)),
        TextField(
          controller: traceIdValue,
          autocorrect: true,
          decoration: InputDecoration(hintText: 'Enter Trace Id'),
        ),
        TealiumButton(
          title: 'Join Trace',
          onPressed: _joinTrace,
        ),
        TealiumButton(
          title: 'Leave Trace',
          onPressed: () => Tealium.leaveTrace(),
        ),
        TealiumButton(
            title: 'Track Event',
            onPressed: () => Tealium.track(
                TealiumEvent('Some Event', {'button_click': 'test'}))),
        TealiumButton(
            title: 'Track View',
            onPressed: () => Tealium.track(
                TealiumView('Some View', {'screen_view': 'tester'}))),
        TealiumButton(
            title: 'Add Data',
            onPressed: () =>
                Tealium.addToDataLayer({'hello': 'world'}, Expiry.session)),
        TealiumButton(
            title: 'Get Data',
            onPressed: () => Tealium.getFromDataLayer('hello').then(
                (value) => developer.log('Value From Data Layer: $value'))),
        TealiumButton(
            title: 'Remove Data',
            onPressed: () => Tealium.removeFromDataLayer(['hello'])),
        TealiumButton(
            title: 'Set Consent',
            onPressed: () => Tealium.setConsentStatus(ConsentStatus.consented)),
        TealiumButton(
            title: 'Get Consent',
            onPressed: () => Tealium.getConsentStatus()
                .then((status) => developer.log('Consent Status: $status'))),
        TealiumButton(
            title: 'Set Consent Categories',
            onPressed: () => _setRandomConsentCategories()),
        TealiumButton(
            title: 'Get Consent Categories',
            onPressed: () => Tealium.getConsentCategories().then((categories) =>
                developer.log('Consent Categories: ' + categories.join(",")))),
        TealiumButton(
            title: 'Add Remote Command',
            onPressed: () => Tealium.addRemoteCommand(
                'example', (payload) => _logRemoteCommand('Example', payload))),
        TealiumButton(
            title: 'Remove Remote Command',
            onPressed: () => Tealium.removeRemoteCommand('hello')),
        TealiumButton(
            title: 'Get Visitor Id',
            onPressed: () => Tealium.getVisitorId()
                .then((visitorId) => developer.log('Visitor Id: $visitorId'))),
        TealiumButton(
            title: 'Terminate Tealium',
            onPressed: () => Tealium.terminateInstance()),
      ],
    );
  }

  void _logVisitorProfile(dynamic profile) {
    var encodedData = json.encode(profile);
    var converted = json.decode(encodedData);
    developer.log('=========Visitor Service Response=========');
    developer
        .log('Audiences: ' + JsonEncoder().convert(converted['audiences']));
    developer.log('Visit Tallies: ' +
        JsonEncoder().convert(converted['currentVisit']['tallies']));
    developer.log('Badges: ' + JsonEncoder().convert(converted['badges']));
  }

  void _logRemoteCommand(String name, dynamic payload) {
    developer.log('=========$name Remote Command Response=========');
    developer.log(JsonEncoder().convert(payload));
  }

  void _setRandomConsentCategories() {
    List<ConsentCategories> list = [
      ConsentCategories.affiliates,
      ConsentCategories.analytics,
      ConsentCategories.bigData,
      ConsentCategories.cdp,
      ConsentCategories.cookieMatch,
      ConsentCategories.crm,
      ConsentCategories.displayAds,
      ConsentCategories.email,
      ConsentCategories.engagement,
      ConsentCategories.misc,
      ConsentCategories.mobile,
      ConsentCategories.monitoring,
      ConsentCategories.personalization,
      ConsentCategories.social
    ];
    list = _shuffleCategories(list)!;
    Tealium.setConsentCategories(list.sublist(0, 3));
  }

  List<ConsentCategories>? _shuffleCategories(List<ConsentCategories> items) {
    var random = new Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
      return items;
    }
  }

  _joinTrace() {
    setState(() {
      result = traceIdValue.text;
      Tealium.joinTrace(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('TealiumFlutterPluginExample'),
          ),
          body: _listView()),
    );
  }
}
