import 'package:flutter/material.dart';
import 'package:ltest/map.dart';
import 'package:ltest/postList.dart';
import 'package:ltest/Loginpage.dart';
import 'UserPage.dart';
import 'addPost.dart';

class unloginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구름 배송',
      home: unloginMainPage(),
    );
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
    const MainPost(), // 홈 탭
    const mapScreenState(), // 배송현황 탭
    UserPage(), // 마이페이지 탭
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('구름 배송'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostForm()),
              );
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              // TODO: 신고 기능 실행 코드 작성
            },
            icon: Icon(Icons.report),
          ),
          IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const loginScreen()),
                );
              },
              icon: Icon(Icons.login)
          )
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
    // TODO: 게시글 목록을 가져와서 출력하는 코드 작성
    return Center(child: Text('게시글 목록'));
  }
}

/*
합배송 제안
  합배송 물품 비슷한 지역&시간대네 묶어버려서 추천하기 (디비 내에서)
의뢰글 추천순

최종에는 데이터 핸들링하는 거도 보여주는 게 (데이터 1000개, 2000개 동시성 제어)
*/