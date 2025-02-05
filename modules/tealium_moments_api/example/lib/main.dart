// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tealium_moments_api/common.dart';
import 'package:tealium_moments_api/tealium_moments_api.dart';
import 'package:tealium/tealium.dart';
import 'package:tealium/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _momentsApiReferrerController =
      TextEditingController();
  final TextEditingController _momentsApiEngineIdController =
      TextEditingController();
  String? _momentsApiReferrer;
  String _momentsApiEngineId = '';
  MomentsApiRegion _currentRegion = MomentsApiRegion.GERMANY;
  MomentsApiRegion _momentsApiRegion = MomentsApiRegion.GERMANY;

  var tealiumConfig = TealiumConfig(
    'tealiummobile',
    'demo',
    TealiumEnvironment.prod,
    [Collectors.AppData, Collectors.Lifecycle],
    [Dispatchers.RemoteCommands, Dispatchers.Collect],
    useRemoteLibrarySettings: true,
    batchingEnabled: false,
    visitorServiceEnabled: true,
  );

  void newTealiumMomentsApiConfig() {
    // MomentsApiConfig config = MomentsApiConfig.withCustomRegion(
    //     "custom",
    //     _momentsApiReferrer);
    MomentsApiConfig config = MomentsApiConfig(
        _momentsApiRegion,
        _momentsApiReferrer);

    TealiumMomentsApi.configure(config);

    // start/restart tealium with new moments api config
    initTealium();
  }

  @override
  void initState() {
    super.initState();
    newTealiumMomentsApiConfig();
  }

  Future<void> initTealium() async {
    await Tealium.initialize(tealiumConfig).then((value) => {
          setConsentStatus(),
          Tealium.getVisitorId().then((value) => _logVisitorId(value)),
          Tealium.setVisitorIdListener((visitorId) => _logVisitorId(visitorId)),
          debugPrint('Tealium Initialized')
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Moments API Plugin Example App'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Text(
                "MomentsAPI Config\nEngineId: $_momentsApiEngineId\nRegion: ${_momentsApiRegion.name}\nReferrer: $_momentsApiReferrer",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              _gap(12),
              Padding(
                padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
                child: TextFormField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: _momentsApiEngineIdController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    hintText: 'Specify an Engine Id',
                    helperText: 'Engine Id must be configured with Tealium account',
                    labelText: "Engine Id",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
                child: TextFormField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: _momentsApiReferrerController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    hintText: 'Specify a referrer URL - Optional',
                    helperText: 'Must match the “Domain Allow List” in Tealium',
                    labelText: "Referrer URL - Optional",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
              ),
              _gap(12),
              DropdownButton<MomentsApiRegion>(
                isDense: true,
                value: _currentRegion,
                onChanged: (MomentsApiRegion? newValue) {
                  setState(() {
                    _currentRegion = newValue!;
                  });
                },
                items: MomentsApiRegion.values.map((MomentsApiRegion region) {
                  return DropdownMenuItem<MomentsApiRegion>(
                      value: region, child: Text(region.name));
                }).toList(),
              ),
              _gap(12),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _momentsApiReferrer = null;
                      _momentsApiEngineId = _momentsApiEngineIdController.text;
                      _momentsApiRegion = _currentRegion;
                      newTealiumMomentsApiConfig();
                    });
                  },
                  child: const Text("Set Moments w/out Referrer")),
              _gap(12),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _momentsApiReferrer = _momentsApiReferrerController.text;
                      _momentsApiEngineId = _momentsApiEngineIdController.text;
                      _momentsApiRegion = _currentRegion;
                      newTealiumMomentsApiConfig();
                    });
                  },
                  child: const Text("Set Moments w/ Referrer")),
              _gap(30),
              const Text("Establish tealium connection"),
              _gap(6),
              const Text("Switch Tealium account & profile in `tealiumConfig` var"),
              _gap(6),
              ElevatedButton(
                  onPressed: () => Tealium.track(
                      TealiumEvent("new event", {"new": "event"})),
                  child: const Text("Send Event")),
              _gap(12),
              ElevatedButton(
                  onPressed: fetchMomentsResponse,
                  child: const Text("Print moments data")),
            ]),
          ),
        ),
      ),
    );
  }

  void fetchMomentsResponse() {
    TealiumMomentsApi.fetchEngineResponse(
      engineId: _momentsApiEngineId,
      callback: (response) {
        if (response is EngineResponse) {
          _logResponseAttributes(response);
        } else if (response is String) {
          debugPrint('Error: $response');
        } else {
          debugPrint('Error: Invalid type returned');
        }
      }
    );
  }

  Future setConsentStatus() async {
    return Tealium.setConsentStatus(ConsentStatus.consented);
  }

  void _logVisitorId(String visitorId) {
    debugPrint('=========Visitor Id Changed=========');
    debugPrint('VisitorId: $visitorId');
  }

  void _logResponseAttributes(EngineResponse response) {
    final allResponseAttributes = StringBuffer("""

<MOMENTS API DATA>

    Audiences: ${response.audiences}
    Badges: ${response.badges}
    Strings: ${response.strings}
    Booleans: ${response.booleans}
    Dates: ${response.dates}
    Numbers: ${response.numbers}

</MOMENTS API DATA>""");

    debugPrint(allResponseAttributes.toString());
  }

  _gap(double height) {
    return SizedBox(height: height);
  }
}
