import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

class RequestPostList extends StatelessWidget {
  const RequestPostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RequestList();
  }
}

class RequestList extends StatefulWidget {
  const RequestList({Key? key}) : super(key: key);

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  final Stream<QuerySnapshot> collectionStream =
  FirebaseFirestore.instance.collection('list').snapshots();
  final CollectionReference postList =
  FirebaseFirestore.instance.collection('list');
  final Query db_r = FirebaseFirestore.instance
      .collection('list')
      .where("postOption", isEqualTo: "의뢰");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: db_r.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('오류 발생: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('로딩 중...');
          }
          return ListView(
            children: snapshot.data!.docs.map((QueryDocumentSnapshot document) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostPage(document)),
                  );
                },
                child: ListTile(
                  title: Text(document['postTitle']),
                  subtitle: Text(document['content']),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class PerformPostList extends StatelessWidget {
  const PerformPostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PerformList(
      startPosition: '',
      endPosition: '',
    );
  }
}

class PerformList extends StatefulWidget {
  final String startPosition;
  final String endPosition;

  const PerformList({
    Key? key,
    required this.startPosition,
    required this.endPosition,
  }) : super(key: key);

  @override
  State<PerformList> createState() => _PerformListState();
}

class _PerformListState extends State<PerformList> {
  final Stream<QuerySnapshot> collectionStream =
  FirebaseFirestore.instance.collection('list').snapshots();
  final CollectionReference postList =
  FirebaseFirestore.instance.collection('list');

  final Query db_p = FirebaseFirestore.instance
      .collection('list')
      .where("postOption", isEqualTo: "배송");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: db_p.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("로딩 중...");
          }
          return ListView(
            children: snapshot.data!.docs.map((QueryDocumentSnapshot document) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostPage(document)),
                  );
                },
                child: ListTile(
                  title: Text(document['postTitle']),
                  subtitle: Text(document['content']),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class MainPost extends StatefulWidget {
  const MainPost({Key? key}) : super(key: key);

  @override
  State<MainPost> createState() => _MainPostState();
}

class _MainPostState extends State<MainPost> {
  final CollectionReference main_db =
  FirebaseFirestore.instance.collection('list');
  late String startPosition = "";
  late String endPosition = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('메인 게시물'),
      ),*/
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                startPosition = value;
              });
            },
            decoration: const InputDecoration(
              labelText: '출발지',
            ),
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                endPosition = value;
              });
            },
            decoration: const InputDecoration(
              labelText: '도착지',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerformList(
                    startPosition: startPosition,
                    endPosition: endPosition,
                  ),
                ),
              );
            },
            child: const Text('검색'),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: main_db
                      .where("postStart", isEqualTo: startPosition)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('오류 발생: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('로딩 중...');
                    }
                    return ListView(
                      children: snapshot.data!.docs
                          .map((QueryDocumentSnapshot document) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PostPage(document)),
                            );
                          },
                          child: ListTile(
                            title: Text(document['postTitle']),
                            subtitle: Text(document['content']),
                          ),
                        );
                      }).toList(),
                    );
                  }))
        ],
      ),
    );
  }
}

class PostPage extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const PostPage(this.document);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document['postTitle']),
      ),
      body: Column(
        children: [
          Text(widget.document['content']),
          ElevatedButton(
            onPressed: () {
              _createChatRoom(widget.document['userId']);
            },
            child: const Text('채팅하기'),
          ),
        ],
      ),
    );
  }

  void _createChatRoom(String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');

    // 채팅방 생성
    final chatRoom = {
      'users': [currentUser.uid, userId],
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    };

    chatRoomsRef.add(chatRoom).then((value) {
      // 채팅방 생성 후, 채팅 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatRoomId: value.id,
            chatRoom: chatRoom,
          ),
        ),
      );
    }).catchError((error) {
      // 오류 처리 로직
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방 생성에 실패했습니다: $error')),
      );
    });
  }
}