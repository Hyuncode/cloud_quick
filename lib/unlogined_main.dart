import 'package:flutter/material.dart';
import 'postList.dart';
import 'loginPage.dart';
import 'userPage.dart';
import 'addPost.dart';

class UnloginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구름 배송',
      home: UnloginMainPage(),
    );
  }
}

class UnloginMainPage extends StatefulWidget {
  @override
  _UnloginMainPageState createState() => _UnloginMainPageState();
}

class _UnloginMainPageState extends State<UnloginMainPage> {
  int _selectedIndex = 2; // 홈 탭이 기본으로 선택되도록 초기값 설정

  final List<Widget> _widgetOptions = <Widget>[
    const RequestPostList(), // 의뢰 탭
    const RequestPostList(), // 배송 탭
    PostListPage(), // 홈 탭
    Center(child: Text('배송현황')), // 배송현황 탭
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const loginScreen()),
              );
            },
            icon: Icon(Icons.login),
          ),
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
