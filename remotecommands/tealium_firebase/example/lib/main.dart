import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tealium_firebase/tealium_firebase.dart';

import 'dart:developer' as developer;
import 'package:tealium/common.dart';
import 'package:tealium/tealium.dart';
import 'tealium_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static TealiumConfig get _config => TealiumConfig(
      'tealiummobile',
      'demo',
      TealiumEnvironment.dev,
      [Collectors.AppData],
      [Dispatchers.RemoteCommands],
      batchingEnabled: false,
      consentExpiry: ConsentExpiry(5, TimeUnit.MINUTES),
      remoteCommands: [
        RemoteCommand(TealiumFirebase.commandName, path: "firebase.json")
      ]);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    await Tealium.initialize(_config);
    if (!mounted) return;
    developer.log('Tealium Initialized');
    await Tealium.setConsentStatus(ConsentStatus.consented);
    await Tealium.setConsentExpiryListener(
        () => developer.log('Consent Expired'));
    Tealium.setVisitorServiceListener(
        (profile) => developer.log(profile));
    await Tealium.addCustomRemoteCommand('hello-world', _logRemoteCommand);
    await Tealium.track(TealiumEvent("init", {}));
  }

  ListView _listView() {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        const Padding(padding: EdgeInsets.all(3.5)),
        TealiumButton(
            title: 'Track Screen View',
            onPressed: () => Tealium.track(TealiumView("screen_view", {
              "screen_class": "com.tealium.flutter.Screen",
              "screen_name": "Main Screen"
            })
          )
        ),
        TealiumButton(
            title: 'Track Purchase',
            onPressed: () => Tealium.track(TealiumView("purchase", {
              "product_id": ["SKU-123", "SKU-456"],
              "product_name": ["Product 123", "Product 456"],
              "product_category": ["clothes", "shoes"],
              // "product_quantity": [1, 2],
              // "product_price": [10.0, 5.0],
              "order_currency": "USD",
              "order_total": 20.0,
              "order_id": "ORD-${_generateOrderId()}",
            })
          )
        ),
      ],
    );
  }

  String _generateOrderId() {
    var rand = Random();
    return rand.nextInt(99999999).toString();
  }

  void _logRemoteCommand(String name, dynamic payload) {
    developer.log('=========$name Remote Command Response=========');
    developer.log(const JsonEncoder().convert(payload));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _listView(),
      ),
    );
  }
}
