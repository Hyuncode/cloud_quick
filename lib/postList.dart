import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RequestPostList(),
    );
  }
}

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
            children:
            snapshot.data!.docs.map((QueryDocumentSnapshot document) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(document),
                    ),
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
            children:
            snapshot.data!.docs.map((QueryDocumentSnapshot document) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(document),
                    ),
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
                            builder: (context) => PostPage(document),
                          ),
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
          ),
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

  void _createChatRoom(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');

    final existingChatRoomQuery =
    chatRoomsRef.where('users', arrayContains: [currentUser.uid, userId]);
    final existingChatRoomSnapshot = await existingChatRoomQuery.get();

    if (existingChatRoomSnapshot.docs.isNotEmpty) {
      final existingChatRoom = existingChatRoomSnapshot.docs.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatRoomId: existingChatRoom.id,
            chatRoom: existingChatRoom.data() as Map<String, dynamic>,
          ),
        ),
      );
    } else {
      final chatRoom = {
        'users': [currentUser.uid, userId],
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
      };

      chatRoomsRef.add(chatRoom).then((value) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방 생성에 실패했습니다: $error')),
        );
      });
    }
  }
}

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> chatRoom;

  const ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.chatRoom,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _messagesCollection;
  late Stream<List<QueryDocumentSnapshot>> _messagesStream;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messagesCollection =
        _firestore.collection('chatRooms/${widget.chatRoomId}/messages');
    _messagesStream = _messagesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.toList());
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _messagesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data;

                if (messages == null || messages.isEmpty) {
                  return Center(child: Text('메세지가 없습니다.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index];
                    final messageText = message['text'].toString();
                    final senderId = message['senderId'].toString();
                    final isCurrentUser =
                        senderId == FirebaseAuth.instance.currentUser!.uid;

                    return ListTile(
                      title: Text(
                        messageText,
                        style: TextStyle(
                          fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(senderId),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메세지 입력',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      _messagesCollection.add({
        'text': messageText,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': Timestamp.now(),
      });
      _messageController.clear();
    }
  }
}
