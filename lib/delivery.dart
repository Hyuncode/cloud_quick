import 'package:code/Loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';

// 현재 위치 좌표 가져오기
Future<List> getlocation() async{
  var latitude;
  var longitude;

  LocationPermission permission = await Geolocator.checkPermission();
  if(permission == LocationPermission.denied){
    permission = await Geolocator.requestPermission();
  }
  try{
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;
  } catch(e) {
    print(e);
  }
  List<double> location = [latitude, longitude];
  return location;
}

//배송 목록 화면
class deliverPage extends StatefulWidget {
  const deliverPage({Key? key}) : super(key: key);

  @override
  State<deliverPage> createState() => _deliverPageState();
}

class _deliverPageState extends State<deliverPage> {
  final user = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final Query deliveryData = FirebaseFirestore.instance
        .collection("delivery").where("request_uid", isEqualTo: user);
    final delivererData = FirebaseFirestore.instance
    .collection("delivery").where("deliver_uid", isEqualTo: user);

    return  Scaffold(
      body: Column(
        children: <Widget>[
          Text("의뢰 목록"),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: deliveryData.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                return const Text("loading...");
               }
                return ListView(
                  children:
                  snapshot.data!.docs.map((QueryDocumentSnapshot document){
                     return GestureDetector(
                        onTap: (){
                        Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => deliveryPage(document),
                           )
                        );
                        },
                       child: ListTile(
                         title: Text(document["request_uid"]),
                      ),
                    );
                  }).toList(),
                );
                },
              )
          ),
          Text("베송 목록"),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: delivererData.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Text("loading...");
                  }
                  return ListView(
                    children:
                    snapshot.data!.docs.map((QueryDocumentSnapshot document){
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => delivererPage(document),
                              )
                          );
                        },
                        child: ListTile(
                          title: Text(document["deliver_uid"]),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
          ),
        ],
      ),
    );
  }
}

// 배송 의뢰 화면
class deliveryPage extends StatefulWidget {
  final QueryDocumentSnapshot document;
  const deliveryPage(this.document);

  @override
  State<deliveryPage> createState() => _deliveryPageState();
}

class _deliveryPageState extends State<deliveryPage> {

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final postdata = db.collection('list').doc(widget.document['postID']);

    var curr_lat = widget.document["curr_lat"];
    var curr_lon = widget.document["curr_lon"];
    var end_lat = widget.document["end_lat"];
    var end_lon = widget.document["end_lon"];
    var start_lat = widget.document["start_lat"];
    var start_lon = widget.document["start_lon"];

    var distance = Distance();
    final distance_meter =
      distance(LatLng(curr_lat, curr_lon), LatLng(end_lat, end_lon));
    final alldistance =
        distance(LatLng(start_lat, start_lon), LatLng(end_lat, end_lon));
    var percent = ((alldistance - distance_meter)/alldistance);

    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: postdata.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                  return ListTile(
                    onTap: (){

                    },
                    title: Text(snapshot.data!["postTitle"]),
                    subtitle: Text(snapshot.data!["content"]),
                  );
                }
            ),
            Text("남은 거리 : $distance_meter m"),
            SizedBox(height: 10,),
            LinearPercentIndicator(
              percent: percent,
              backgroundColor: Colors.black26,
              progressColor: Colors.lightBlueAccent,
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: (){
                if(widget.document["locationCheck"] == true){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return const AlertDialog(content: Text('이미 인증 요청이 진행 중 입니다.'),);
                      }
                  );
                } else {
                  final data = FirebaseFirestore.instance;
                  data.collection("delivery").doc(widget.document.id)
                      .update({"locationCheck": true});
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return const AlertDialog(content: Text("위치 인증이 요청되었습니다."),);
                      }
                  );
                }
                },
              child: const Text("위치 요청")
            ),
            SizedBox(height: 5,),
            ElevatedButton(
                onPressed: (){

                },
                child: Text("배송 완료"),
            )
          ],
        ),
      ),
    );
  }
}

//배송 수행 화면
class delivererPage extends StatefulWidget {
  final QueryDocumentSnapshot document;
  const delivererPage(this.document);

  @override
  State<delivererPage> createState() => _delivererPageState();
}

class _delivererPageState extends State<delivererPage> {
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final postdata = db.collection('list').doc(widget.document['postID']);

    var curr_lat = widget.document["curr_lat"];
    var curr_lon = widget.document["curr_lon"];
    var end_lat = widget.document["end_lat"];
    var end_lon = widget.document["end_lon"];

    var distance = Distance();
    final distance_meter =
    distance(LatLng(curr_lat, curr_lon), LatLng(end_lat, end_lon));

    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<DocumentSnapshot>(
                stream: postdata.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                  return ListTile(
                    onTap: (){

                    },
                    title: Text(snapshot.data!["postTitle"]),
                    subtitle: Text(snapshot.data!["content"]),
                  );
                }
            ),
            Text("현재 위치 : $curr_lat, $curr_lon"),
            Text("남은 거리 : $distance_meter m"),
            FutureBuilder(
                future: getlocation(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.hasData == false){
                    return CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                        onPressed: (){
                          if(widget.document["locationCheck"] == false) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                return const AlertDialog(content: Text("인증 요청이 없습니다."));
                                });
                          } else {
                            final database = FirebaseFirestore.instance
                                .collection('delivery').doc(widget.document.id);
                            List list = snapshot.data;
                            database.
                                update({
                              'locationCheck': false,
                              'curr_lat' : list[0],
                              'curr_lon' : list[1]
                            },);
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return const AlertDialog(content: Text("위치 인증이 완료되었습니다."));
                            });
                          }
                        },
                        child: const Text("위치 인증"));
                  }
                }
            ),
          ],
        ),
      ),
    );
  }
}

class unloginedDelivery extends StatefulWidget {
  const unloginedDelivery({Key? key}) : super(key: key);

  @override
  State<unloginedDelivery> createState() => _unloginedDeliveryState();
}

class _unloginedDeliveryState extends State<unloginedDelivery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 300,
            ),
            Container(
              height: 50,
              child: Text("로그인 후 이용하세요"),
            ),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const loginScreen()),
                  );
                },
                child: Text("로그인 하기")
            ),
          ],
        ),
      ),
    );
  }
}

