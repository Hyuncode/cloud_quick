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
        .where('users', arrayContains: _currentUser)
        .snapshots()
        .map((snapshot) => snapshot.docs.toList());
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
            return Text('오류 발생: ${snapshot.error}');
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
              final users = chatRoomData['users'] as List<dynamic>;
              final otherUser =
              users.firstWhere((user) => user != _currentUser);
              return ListTile(
                title: Text('상대방: $otherUser'),
                subtitle: Text(chatRoomData['lastMessage']),
                onTap: () {
                  _navigateToChatPage(chatRoomData, chatRoomId);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToChatPage(
      Map<String, dynamic>? chatRoomData, String chatRoomId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');

    final existingChatRoomQuery = chatRoomsRef
        .where('users', arrayContains: currentUser.uid)
        .where('users', arrayContains: chatRoomData?['userId']);
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
        'users': [currentUser.uid, chatRoomData?['userId']],
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
              builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
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
                    final isCurrentUser = senderId == FirebaseAuth.instance.currentUser!.uid;

                    return ListTile(
                      title: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          messageText,
                          style: TextStyle(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(senderId),
                      ),
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
