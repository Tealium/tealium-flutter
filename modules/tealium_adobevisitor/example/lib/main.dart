import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:tealium_adobevisitor/tealium_adobevisitor.dart';

import 'tealium_button.dart';
import 'package:tealium_adobevisitor/common.dart';
import 'package:tealium/common.dart';
import 'package:tealium/tealium.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _adobeOrgIdController =
      TextEditingController();
  var _adobeOrgSet = false;
  AdobeVisitor? _adobeVisitor;

  final _knownIdController = TextEditingController();
  final _dataProviderIdController = TextEditingController();
  final _authStateController = TextEditingController();
  var _linkEcidReady = false;

  final _urlController = TextEditingController(text: "https://mysite.com/");
  var _decoratedUrl = "";

  @override
  void initState() {
    super.initState();

    _knownIdController.addListener(_validateLinkSettings);
    _dataProviderIdController.addListener(_validateLinkSettings);
  }

  void initializeTealium(String adobeOrgId) {
    if (adobeOrgId == "") return;

    TealiumAdobeVisitor.configure(AdobeVisitorConfig(adobeOrgId));
    var config = TealiumConfig(
      'tealiummobile',
      'demo',
      TealiumEnvironment.dev,
      [Collectors.AppData],
      [Dispatchers.Collect],
      batchingEnabled: false,
    );

    Tealium.initialize(config).then((value) => {
          developer.log('Tealium Initialized'),
          setState(() {
            _adobeOrgSet = true;
          }),
          _fetchAdobeVisitor()
        });
  }

  Padding _listView() {
    // MARK: Initialize Tealium

    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            const Padding(padding: EdgeInsets.all(8)),
            TextField(
              controller: _adobeOrgIdController,
              autocorrect: true,
              decoration:
                  const InputDecoration(hintText: 'Enter a valid AdobeOrgId'),
            ),
            TealiumButton(
                title: 'Initialize Tealium',
                onPressed: () => initializeTealium(_adobeOrgIdController.text)),
            TealiumButton(
                disabled: !_adobeOrgSet,
                title: 'Get Adobe Visitor',
                onPressed: () => _fetchAdobeVisitor()),
            TealiumButton(
                disabled: !_adobeOrgSet,
                title: 'Reset Visitor',
                onPressed: () => _resetVisitor()),
            const Padding(padding: EdgeInsets.all(8)),
            TextField(
              enabled: _adobeOrgSet,
              controller: _urlController,
              autocorrect: true,
              decoration:
                  const InputDecoration(hintText: 'Enter a url to decorate.'),
            ),
            TealiumButton(
                disabled: !_adobeOrgSet,
                title: 'Decorate Url',
                onPressed: () => TealiumAdobeVisitor.decorateUrl(_urlController.text).then((value) => setState(() => {
                  _decoratedUrl = value as String
                }))),
            Visibility(visible: _decoratedUrl.isNotEmpty, child: Text(_decoratedUrl)),
            const Padding(padding: EdgeInsets.all(8)),
            TextField(
              enabled: _adobeOrgSet,
              controller: _knownIdController,
              autocorrect: true,
              decoration:
                  const InputDecoration(hintText: 'Enter a known Id to link.'),
            ),
            TextField(
              enabled: _adobeOrgSet,
              controller: _dataProviderIdController,
              autocorrect: true,
              decoration:
                  const InputDecoration(hintText: 'Enter the dataProviderId.'),
            ),
            TextField(
              enabled: _adobeOrgSet,
              controller: _authStateController,
              autocorrect: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: '(Optional) Enter the authState.'),
            ),
            TealiumButton(
                disabled: !_linkEcidReady,
                title: 'Link known Id',
                onPressed: () => TealiumAdobeVisitor.linkEcidToKnownIdentifier(
                    _knownIdController.text,
                    _dataProviderIdController.text,
                    int.tryParse(_authStateController.text))
                  .then((visitor) => _setAdobeVisitor(visitor))),
            const Padding(padding: EdgeInsets.all(8)),
            const Padding(
              padding: EdgeInsets.all(4),
              child: Text("Visitor:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            Text(_adobeVisitor != null
                ? const JsonEncoder.withIndent("    ").convert(_adobeVisitor)
                : "No visitor retrieved yet.")
          ],
        ));
  }

  void _fetchAdobeVisitor() {
    TealiumAdobeVisitor.getAdobeVisitor().then((visitor) => {
          _log(visitor),
          _setAdobeVisitor(visitor)
        });
  }

  void _resetVisitor() {
    TealiumAdobeVisitor.resetVisitor(); 
    _fetchAdobeVisitor();
  }

  void _setAdobeVisitor(AdobeVisitor? adobeVisitor) {
setState(() {
            _adobeVisitor = adobeVisitor;
          });
  }

  void _validateLinkSettings() {
    setState(() {
      _linkEcidReady = _knownIdController.text != "" 
                          && _dataProviderIdController.text != "";
    });
  }

  void _log(dynamic payload) {
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
