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
  late Stream<List<QueryDocumentSnapshot>> _chatRoomsStream;
  late String _currentUser;

  @override
  void initState() {
    super.initState();
    _chatRoomsCollection = _firestore.collection('chatRooms');
    _currentUser = FirebaseAuth.instance.currentUser!.uid;
    _chatRoomsStream = _chatRoomsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .where((doc) => doc['users'].contains(_currentUser))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방 목록'),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _chatRoomsStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data;

          if (chatRooms == null || chatRooms.isEmpty) {
            return Center(child: Text('채팅방이 없습니다.'));
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (BuildContext context, int index) {
              final chatRoom = chatRooms[index];
              final chatRoomId = chatRoom.id;
              final chatRoomData = chatRoom.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('채팅방 ${index + 1}'),
                onTap: () {
                  _navigateToChatPage(chatRoomId, chatRoomData);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToChatPage(String chatRoomId, Map<String, dynamic> chatRoomData) {
    // 기존에 존재하는 채팅방인지 확인
    if (chatRoomData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatRoomId: chatRoomId,
            chatRoom: chatRoomData,
          ),
        ),
      );
    } else {
      // 기존에 존재하지 않는 채팅방일 경우 새로운 채팅방 생성
      final newChatRoomData = {
        'users': [_currentUser, '상대방 사용자 ID'], // 상대방 사용자 ID를 채팅방 생성 시 함께 추가
        'timestamp': Timestamp.now(),
      };

      _chatRoomsCollection.add(newChatRoomData).then((newChatRoomRef) {
        final newChatRoomId = newChatRoomRef.id;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatRoomId: newChatRoomId,
              chatRoom: newChatRoomData,
            ),
          ),
        );
      }).catchError((error) {
        print('Error creating new chat room: $error');
      });
    }
  }
}

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic>? chatRoom;

  const ChatPage({required this.chatRoomId, this.chatRoom});

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
