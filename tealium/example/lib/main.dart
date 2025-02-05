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
  static final visitorIdentityKey = "visitor_identity";
  final traceIdValue = TextEditingController();
  final userIdValue = TextEditingController();
  String result = '';
  String currentVisitorId = '';

  // MARK: Tealium Configuration

  var config = TealiumConfig(
      'tealiummobile',
      'demo',
      TealiumEnvironment.dev,
      [Collectors.AppData, Collectors.Lifecycle],
      [Dispatchers.RemoteCommands, Dispatchers.Collect],
      consentPolicy: ConsentPolicy.GDPR,
      useRemoteLibrarySettings: true,
      batchingEnabled: false,
      visitorServiceEnabled: true,
      consentExpiry: ConsentExpiry(5, TimeUnit.MINUTES),
      visitorIdentityKey: visitorIdentityKey);

  @override
  void initState() {
    // MARK: Initialize Tealium
    Tealium.initialize(config).then((value) => {
          developer.log('Tealium Initialized'),
          Tealium.setConsentStatus(ConsentStatus.consented),
          Tealium.setConsentExpiryListener(
              () => developer.log('Consent Expired')),
          Tealium.setVisitorServiceListener(
              (profile) => _logVisitorProfile(profile)),
          Tealium.getVisitorId().then((value) => _logVisitorId(value)),
          Tealium.setVisitorIdListener((visitorId) => _logVisitorId(visitorId)),
          Tealium.addCustomRemoteCommand('json-test',
              (payload) => {_logRemoteCommand('JSON Test', payload)}),
          Tealium.getFromDataLayer(visitorIdentityKey)
              .then((value) => setState(() {
                    userIdValue.text = value;
                  })),
        });
    super.initState();
  }

  ListView _listView() {
    return new ListView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(5),
      children: <Widget>[
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
            onPressed: () => Tealium.addCustomRemoteCommand(
                'example', (payload) => _logRemoteCommand('Example', payload))),
        TealiumButton(
            title: 'Remove Remote Command',
            onPressed: () => Tealium.removeRemoteCommand('json-test')),
        TealiumButton(
            title: 'Get Visitor Id',
            onPressed: () => Tealium.getVisitorId()
                .then((visitorId) => developer.log('Visitor Id: $visitorId'))),
        TealiumButton(
            title: 'Gather Track Data',
            onPressed: () => Tealium.gatherTrackData()
                .then((data) => developer.log('Gather track Data: $data'))),
        TealiumButton(
            title: 'Terminate Tealium',
            onPressed: () => Tealium.terminateInstance()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Identity:'),
            Padding(padding: EdgeInsets.all(3)),
            Expanded(
                child: TextField(
              controller: userIdValue,
              autocorrect: true,
              decoration: InputDecoration(hintText: 'Enter an Identity'),
            ))
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text('Current Visitor ID: $currentVisitorId',
              textAlign: TextAlign.center),
        ),
        TealiumButton(
          title: 'Set Identity',
          onPressed: _setIdentity,
        ),
        TealiumButton(
          title: 'Reset Visitor Id',
          onPressed: () => Tealium.resetVisitorId(),
        ),
        TealiumButton(
          title: 'Clear Stored Visitor Ids',
          onPressed: () => Tealium.clearStoredVisitorIds(),
        ),
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

  void _logVisitorId(String visitorId) {
    developer.log('=========Visitor Id Changed =========');
    developer.log('VisitorId: ' + visitorId);
    setState(() {
      currentVisitorId = visitorId;
    });
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
    list.shuffle();
    Tealium.setConsentCategories(list.sublist(0, 3));
  }

  _joinTrace() {
    setState(() {
      result = traceIdValue.text;
      Tealium.joinTrace(result);
    });
  }

  _setIdentity() {
    var identity = userIdValue.text;
    Tealium.addToDataLayer({visitorIdentityKey: identity}, Expiry.forever);
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
