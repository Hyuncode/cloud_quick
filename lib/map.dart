import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
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
  double latitude = 0;
  double longitude = 0;

  LocationPermission permission = await Geolocator.checkPermission();
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
  return convertLocation(location);
}

Future<List> convertLocation(List location) async {
  String lat = location[0].toString();
  String lon = location[1].toString();

  final String clientID = "qaji6jjpsa"; // naver client id
  final String clientSecret =
      "FKgN6yhINBcuXrUDC62ChOAbTevYiVEviRQWTO9g"; // naver secret key
  String url = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?"
      "coords=126.8343943, 37.5604629&"
      "sourcecrs=epsg:4326&"
      "output=json&"
      "orders=roadaddr";

  Map<String, String> naverID = {
    "X-NCP-APIGW-API-KEY-ID": "qaji6jjpsa",
    // 개인 클라이언트 아이디
    "X-NCP-APIGW-API-KEY": "FKgN6yhINBcuXrUDC62ChOAbTevYiVEviRQWTO9g"
    // 개인 시크릿 키
  };

  print(lon);
  print(lat);
  /*
  Response response = await get(
    Uri.parse(
      "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=$lon,$lat&sourcecers=epsg:4326&output=json"
    ),
    headers: naverID);
   */
  Response response = await get(
    Uri.parse(url),
    headers: {
      "X-NCP-APIGW-API-KEY-ID": clientID,
      "X-NCP-APIGW-API-KEY": clientSecret,
    },
  );
  print(response.statusCode);
  String locationData = response.body;
  print(locationData);

  var locationGu =
      jsonDecode(locationData)["result"][1]['region']['area2']['name'];
  var locationSi =
      jsonDecode(locationData)["result"][1]['region']['area1']['name'];

  List<String> convertedData = [locationSi, locationGu];
  return convertedData;
}
