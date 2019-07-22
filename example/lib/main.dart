import 'package:flutter/material.dart';

import 'package:tealium/tealium.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //Sample - minimum initialization for Tealium instance
  //var teal = Tealium.initialize("tealiummobile", "android", "dev", null, null);

  //Sample - initialize Tealium + enable Consent Manager
  //var teal = Tealium.initializeWithConsentManager("tealiummobile", "android", "dev", null, null);

  //Sample - custom Tealium initialization
  var teal = Tealium.initializeCustom("tealiummobile", "android", "dev", null, null,
        "main", true, null, null, null, true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ButtonTheme(
              minWidth: 250.0,
              child: RaisedButton(
                  child: Text("Track Event"),
                  onPressed: () {
                    Tealium.trackEvent("event button click");
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Track View"),
                  onPressed: () {
                    Tealium.trackView("View button click");
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Get Visitor ID"),
                  onPressed: () async {
                    String data = await Tealium.getVisitorId();
                    print("Visitor ID: $data");
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Set Volatile Data"),
                  onPressed: () {
                    Tealium.setVolatileData({
                      "volatile_var": "volatile_val",
                      "volatile_var2": ["vol1", "vol2", "vol3"]
                    });
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Set Persistent Data"),
                  onPressed: () {
                    Tealium.setPersistentData({
                      "persistent_var": "persistent_val",
                      "persistent_var2": ["per1", "per2", "per3"]
                    });
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Print Volatile data: volatile_var"),
                  onPressed: () async {
                    var data = await Tealium.getVolatileData("volatile_var");
                    print("Volatile data retrieved: $data");
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Print Persistent data: persistent_var2"),
                  onPressed: () async {
                    var data =
                        await Tealium.getPersistentData("persistent_var2");
                    print("Persistent data retrieved: $data");
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Remove Volatile Data"),
                  onPressed: () {
                    Tealium.removeVolatileData(
                        ["volatile_var", "volatile_var"]);
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Remove Persistent Data"),
                  onPressed: () {
                    Tealium.removePersistentData(
                        ["persistent_var", "persistent_var2"]);
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Consent Manager: Consented Status"),
                  onPressed: () {
                    Tealium.setUserConsentStatus(1);
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Consent Manager: Not Consented Status"),
                  onPressed: () {
                    Tealium.setUserConsentStatus(2);
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Consent Manager: Partial Consent"),
                  onPressed: () {
                    Tealium.setUserConsentCategories(
                        ["email", "personalization"]);
                    Tealium.getUserConsentCategories();
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Get Consent Status"),
                  onPressed: () async {
                    String data = await Tealium.getUserConsentStatus();
                    print("Current Consent status is: $data");
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Get Consent Categories"),
                  onPressed: () async {
                    List data = await Tealium.getUserConsentCategories();
                    if (data != null) {
                      for (var x = 0; x < data.length; x++) {
                        print(data[x]);
                      }
                    } else {
                      print(data);
                    }
                  }),
            ),
            ButtonTheme(
              minWidth: 300.0,
              child: RaisedButton(
                  child: Text("Consent Manager: Reset Preferences"),
                  onPressed: () {
                    Tealium.resetUserConsentPreferences();
                  }),
            )
          ],
        )),
      ),
    );
  }
}
