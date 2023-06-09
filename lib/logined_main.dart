import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/delivery.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map.dart';
import 'postList.dart';
import 'UserPage.dart';
import 'addPost.dart';
import 'chat.dart';
import 'addUserInfo.dart';

class loginPage extends StatelessWidget {
  final db = FirebaseFirestore.instance.collection('UserInfo');
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: db.where("UID", isEqualTo: user?.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            return unloginMainPage();
          }
          return addUser();
        }
    );
    /*return MaterialApp(
      title: '구름 배송',
      home: unloginMainPage(),
    );*/
  }
}

class unloginMainPage extends StatefulWidget {
  @override
  _unloginMainPageState createState() => _unloginMainPageState();
}

class _unloginMainPageState extends State<unloginMainPage> {
  int _selectedIndex = 2; // 홈 탭이 기본으로 선택되도록 초기값 설정

  final List<Widget> _widgetOptions = <Widget>[
    const RequestPostList(), // 의뢰 탭
    const PerformPostList(), // 배송 탭
    const MainPost(), // 홈탭
    const deliverPage(),
    UserPage(), // 마이페이지 탭
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final user = FirebaseAuth.instance.currentUser;

  /*Future<List<dynamic>> getniclData() async{
    final nick = FirebaseFirestore.instance.
    collection("UserInfo").where('UID', isEqualTo: user?.uid);
    final data = nick.get();
    List db = [];
    db.add(data);
    return db;
}*/

  @override
  Widget build(BuildContext context) {
    /*Future<List> db = getniclData();
    if (db == null) {
      return addUser();
    }*/
    return Scaffold(
      appBar: AppBar(
        title: const Text('구름 배송'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostForm()),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              // TODO: 신고 기능 실행 코드 작성
            },
            icon: const Icon(Icons.report),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomListPage(),
                ),
              );
            },
            icon: const Icon(Icons.chat),
          ),
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '의뢰',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '배송',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Colors.black),
            label: '배송현황',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}

class PostListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('게시글 목록'));
  }
}
