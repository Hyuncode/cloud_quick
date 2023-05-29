import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> chatRoom;

  const ChatPage({required this.chatRoomId, required this.chatRoom});

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
    final List<String> users = widget.chatRoom['users'].cast<String>();
    if (users[0] == _currentUser) {
      return users[1];
    } else {
      return users[0];
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final timestamp = Timestamp.now();
    final users = widget.chatRoom['users'];
    _messagesCollection.add({
      'text': text,
      'chatRoomId': widget.chatRoomId,
      'users': users,
      'timestamp': timestamp,
    });
  }
}
