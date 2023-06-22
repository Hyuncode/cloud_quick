import 'package:code/addUserInfo.dart';
import 'package:code/logined_main.dart';
import 'unlogined_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //Firtbase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '구름 배송',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final db = FirebaseFirestore.instance.collection('UserInfo');
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return unloginPage();
        }
        return loginPage();
      },
    );
  }
}

/*
합배송 제안
  합배송 물품 비슷한 지역&시간대 묶어서 추천 하기 (디비 내에서)
의뢰글 추천순

최종에는 데이터 핸들링하는 거도 보여주는 게 (데이터 1000개, 2000개 동시성 제어)
*/
