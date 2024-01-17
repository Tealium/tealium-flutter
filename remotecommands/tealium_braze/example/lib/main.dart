import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tealium_braze/tealium_braze.dart';

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
  static String defaultUserId() {
    if (Platform.isAndroid) {
      return "TestFlutterAndroidUser";
    } else if (Platform.isIOS) {
      // iOS-specific code
      return "TestFlutterIosUser";
    }
    return "";
  }

  final userIdValue = TextEditingController(text: defaultUserId());
  final customEventValue = TextEditingController(text: "custom event");
  final userAttributeValue = TextEditingController();
  SubscriptionType? _subscriptionStatus;

  @override
  void initState() {
    super.initState();
    initTealium();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initTealium() async {
    var config = TealiumConfig(
        'tealiummobile',
        'braze-tag',
        TealiumEnvironment.dev,
        [Collectors.AppData],
        [Dispatchers.RemoteCommands],
        loglevel: LogLevel.DEV,
        batchingEnabled: false,
        consentExpiry: ConsentExpiry(5, TimeUnit.MINUTES),
        remoteCommands: [
          RemoteCommand(TealiumBraze.commandName, path: "braze.json")
        ]);

    Tealium.initialize(config).then((value) => {
          developer.log('Tealium Initialized'),
          Tealium.setConsentStatus(ConsentStatus.consented),
          Tealium.track(TealiumEvent("launch", {}))
        });
  }

  ListView _listView() {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(8.0),
      children: <Widget>[
        const Padding(padding: EdgeInsets.all(3.5)),
        // Events Section
        Text("Events",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center),
        LabelledTextBox("Event", customEventValue,
            hint: "Enter a custom event"),
        TealiumButton(
            title: 'Track Custom Event', onPressed: _trackCustomEvent),
        TealiumButton(title: 'Track Purchase', onPressed: _trackPurchase),

        const TealiumDivider(),

        // User Section
        Text("User",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center),
        LabelledTextBox("Identity", userIdValue, hint: "Enter an Identity"),
        TealiumButton(title: 'User Login', onPressed: _identifyUser),
        LabelledTextBox("Attribute", userAttributeValue,
            hint: "Enter a custom attribute"),
        TealiumButton(
            title: 'Set Custom Attribute', onPressed: _setCustomAttribute),

        const TealiumDivider(),

        // Subscription Section
        Text("Email/Push Subscription",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center),
        RadioListTile(
            title: Text(SubscriptionType.optedIn.name),
            value: SubscriptionType.optedIn,
            groupValue: _subscriptionStatus,
            onChanged: _updateSubscription),
        RadioListTile(
            title: Text(SubscriptionType.unsubscribed.name),
            value: SubscriptionType.unsubscribed,
            groupValue: _subscriptionStatus,
            onChanged: _updateSubscription),
        RadioListTile(
            title: Text(SubscriptionType.subscribed.name),
            value: SubscriptionType.subscribed,
            groupValue: _subscriptionStatus,
            onChanged: _updateSubscription)
      ],
    );
  }

  void _identifyUser() {
    var userId = userIdValue.text;
    if (userId == "") return;

    Tealium.track(TealiumView("user_login", {"customer_id": userId}));
  }

  void _trackCustomEvent() {
    var customEvent = customEventValue.text;
    if (customEvent == "") return;

    Tealium.track(TealiumView("log_custom_event", {"event_name": customEvent}));
  }

  void _trackPurchase() {
    Tealium.track(TealiumView("purchase", {
      "product_id": ["SKU-123", "SKU-456"],
      "product_name": ["Product 123", "Product 456"],
      "product_category": ["clothes", "shoes"],
      "product_quantity": [1, 2],
      "product_price": [10.0, 5.0],
      "order_currency": "USD",
      "order_total": 20.0,
      "order_id": "ORD-${_generateOrderId()}",
    }));
  }

  void _setCustomAttribute() {
    var userAttribute = userAttributeValue.text;
    if (userAttribute == "") return;

    Tealium.track(TealiumView("custom_attribute", {"pet": userAttribute}));
  }

  void _updateSubscription(SubscriptionType? subscriptionType) {
    setState(() {
      _subscriptionStatus = subscriptionType;
    });
    if (subscriptionType == null) return;

    Tealium.track(TealiumEvent("setengagement", {
      "email_subscription": subscriptionType.name,
      "push_subscription": subscriptionType.name
    }));
  }

  String _generateOrderId() {
    var rand = Random();
    return rand.nextInt(99999999).toString();
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

enum SubscriptionType { optedIn, unsubscribed, subscribed }

class TealiumDivider extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const TealiumDivider({super.key, this.padding = const EdgeInsets.all(8.0)});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: const Divider(
          height: 20,
          thickness: 2,
          indent: 10,
          endIndent: 10,
          color: Colors.blueGrey,
        ));
  }
}

class LabelledTextBox extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  const LabelledTextBox(this.label, this.controller,
      {super.key, this.hint = ""});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:'),
        const Padding(padding: EdgeInsets.all(3)),
        Expanded(
            child: TextField(
          controller: controller,
          autocorrect: true,
          decoration: InputDecoration(hintText: hint),
        ))
      ],
    );
  }
}
