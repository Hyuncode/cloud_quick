import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Text("location"),
            FutureBuilder(
              future: getCurrentLocation(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasData == false){
                  return CircularProgressIndicator();
                }
                else {
                  return Container(
                    child: Text(snapshot.data.toString()),
                  );
                }
              },
            )
          ],
        ),
      )
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}

Future<List> getCurrentLocation() async {
  double latitude = 0;
  double longitude = 0;

  LocationPermission permission = await Geolocator.checkPermission();
  // print(permission);
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;
  } catch (e) {
    print(e);
  }

  List<double> location = [latitude, longitude];
  return location;
}