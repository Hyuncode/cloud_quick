import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

class mapScreen extends StatelessWidget {
 const mapScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
  return const MaterialApp(
    title: 'mapScreen',
    home: mapScreenState(),
  );
 }
}

class mapScreenState extends StatefulWidget {
  const mapScreenState({Key? key}) : super (key: key);

  @override
  _mapScreenState createState() => _mapScreenState();
}

class _mapScreenState extends State<mapScreenState> {
  Completer<NaverMapController> _controller = Completer();
  MapType _maptype = MapType.Basic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: NaverMap(
            onMapCreated: onMapCreated,
            mapType: _maptype,
          ),
      ),
    );
  }
  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}

/*Future<List> getLocation() async {
  Position position = await d;
} */
