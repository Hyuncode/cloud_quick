import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:http/http.dart' as http;
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
  const mapScreenState({Key? key}) : super(key: key);

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
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              List ll = snapshot.data;
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
              } else {
                return Container(
                  child: Text(ll[0].toString()),
                );
              }
            },
          )
        ],
      ),
    ));
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}

  Future<List> getCurrentLocation() async {
  var latitude;
  var longitude;

  const String clientID = "qaji6jjpsa"; // naver client id
  const String id = "pewh3ot76c";
  const String clientSecret =
      "FKgN6yhINBcuXrUDC62ChOAbTevYiVEviRQWTO9g"; // naver secret key
  const String sc = "0CQg5g67uvIrkNEqbeJtLyTazPIm0Rmcy9r0kEAO";

  String url = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?"
      "coords=126.8343943, 37.5604629&"
      "sourcecrs=epsg:4326&"
      "output=json&"
      "orders=roadaddr";
  Map<String, String> naverID = {
    "X-NCP-APIGW-API-KEY-ID": id, // 개인 클라이언트 아이디
    "X-NCP-APIGW-API-KEY": sc // 개인 시크릿 키
  };
  print(url);
  print(naverID);

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
  } catch (e) {
    print(e);
  }
  print(latitude);
  print(longitude);

  http.Response response = await http.get(
    Uri.parse(url),
    headers: naverID
  );
  String locationData = response.body;
  print(locationData);

  var location2 =
  jsonDecode(locationData)["result"][1]['region']['area2']['name'];
  var location1 =
  jsonDecode(locationData)["result"][1]['region']['area1']['name'];
  List<String> location = [location1, location2];
  print(location);

  //return convertLocation(location);
  return location;
}

