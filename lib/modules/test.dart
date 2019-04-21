import 'package:chaldea/modules/home/gallery.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
void main() {
  var a = {"a": false, "b": true, "c": 1, "d": 0};
  final encoded= json.encode(a);
  final decoded=json.decode(encoded);
  print(encoded);
  print(decoded);
  print(decoded["a"] is bool);
}

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            child: Text("Button 1"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(isInitialRoute: true),
                      builder: (context) => Gallery()));
            },
          ),
          RaisedButton(
            child: Text("Button 2"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(isInitialRoute: true),
                      builder: (context) => Gallery()));
            },
          ),
        ],
      ),
    );
  }
}
