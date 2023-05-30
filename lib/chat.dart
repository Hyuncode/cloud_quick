import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomListPage extends StatefulWidget {
  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _chatRoomsCollection;
  late Stream<QuerySnapshot> _chatRoomsStream;
  late String _currentUser;

  @override
  void initState() {
    super.initState();
    _chatRoomsCollection = _firestore.collection('chatRooms');
    _currentUser = FirebaseAuth.instance.currentUser!.uid;
    _chatRoomsStream = _chatRoomsCollection
        .where('users', arrayContains: _currentUser)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatRoomsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.data!.size == 0) {
                return Center(child: Text('채팅방이 없습니다.'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.size,
                itemBuilder: (BuildContext context, int index) {
                  final chatRoom = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text('채팅방 ${index + 1}'),
                    subtitle: Text(_getChatPartner(chatRoom)),
                    onTap: () {
                      _navigateToChatPage(chatRoom.id, Map<String, dynamic>.from(chatRoom.data()! as Map));
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }

  String _getChatPartner(DocumentSnapshot chatRoom) {
    final List<String> users = chatRoom['users'].cast<String>();
    users.remove(_currentUser);
    return users[0];
  }

  void _navigateToChatPage(String chatRoomId, Map<String, dynamic> chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(chatRoomId: chatRoomId),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic>? chatRoom; // chatRoom 매개변수는 선택적으로 설정

  const ChatPage({required this.chatRoomId, this.chatRoom}); // chatRoom 매개변수는 선택적으로 설정

  @override
  _ChatPageState createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _messagesCollection;
  late Query _messagesQuery;
  late Stream<QuerySnapshot> _messagesStream;
  late String _currentUser;

  @override
  void initState() {
    super.initState();
    _messagesCollection = _firestore.collection('messages');
    _currentUser = FirebaseAuth.instance.currentUser!.uid;
    _messagesQuery = _messagesCollection
        .where('chatRoomId', isEqualTo: widget.chatRoomId)
        .orderBy('timestamp', descending: true);
    _messagesStream = _messagesQuery.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.size,
                      itemBuilder: (BuildContext context, int index) {
                        final message = snapshot.data!.docs[index];
                        return ListTile(
                          title: Text(message['text']),
                          subtitle: Text(_getChatPartner(message)),
                          trailing: Text(
                            DateTime.fromMillisecondsSinceEpoch(message['timestamp'].millisecondsSinceEpoch).toString(),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getChatPartner(QueryDocumentSnapshot message) {
    final List<String> users = message['users'].cast<String>();
    if (users[0] == _currentUser) {
      return users[1];
    } else {
      return users[0];
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final timestamp = Timestamp.now();
    _messagesCollection.add({
      'text': text,
      'chatRoomId': widget.chatRoomId,
      'users': [_currentUser, _getChatPartnerFromId(widget.chatRoomId)],
      'timestamp': timestamp,
    });
  }

  String _getChatPartnerFromId(String chatRoomId) {
    final List<String> roomUsers = chatRoomId.split('_');
    roomUsers.remove(_currentUser);
    return roomUsers[0];
  }
}

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
      home: ChatRoomListPage(),
    );
  }
}
