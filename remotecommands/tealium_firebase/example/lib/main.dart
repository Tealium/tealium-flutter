import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

  
  }

  ListView _listView() {
    // MARK: Initialize Tealium

    var config = TealiumConfig(
        'services-james',
        'lib-mobile',
        TealiumEnvironment.dev,
        [Collectors.AppData],
        [Dispatchers.RemoteCommands],
        batchingEnabled: false,
        consentExpiry: ConsentExpiry(5, TimeUnit.MINUTES),
        remoteCommands: [
          RemoteCommand(TealiumFirebase.commandName, path: "firebase.json")
        ]);

    Tealium.initialize(config).then((value) => {
          developer.log('Tealium Initialized'),
          Tealium.setConsentStatus(ConsentStatus.consented),
          Tealium.setConsentExpiryListener(
              () => developer.log('Consent Expired')),
          Tealium.setVisitorServiceListener(
              (profile) => developer.log(profile)),
          Tealium.addCustomRemoteCommand('hello-world', _logRemoteCommand),
          Tealium.track(TealiumEvent("init", {}))
        });

    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Padding(padding: EdgeInsets.all(3.5)),
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
    developer.log(JsonEncoder().convert(payload));
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
