import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class requestpostList extends StatelessWidget { //의뢰 리스트
  const requestpostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const requestList();
  }
}

class requestList extends StatefulWidget {
  const requestList({Key? key}) : super(key: key);

  @override
  State<requestList> createState() => _requestListState();
}

class _requestListState extends State<requestList> {
  Stream collectionStream =
      FirebaseFirestore.instance.collection('list').snapshots();
  CollectionReference postList = FirebaseFirestore.instance.collection('list');
  final db_r = FirebaseFirestore.instance
      .collection('list')
      .where("postOption", isEqualTo: "의뢰");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: db_r.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          return ListView(
            children: snapshot.data!.docs.map((QueryDocumentSnapshot document) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => postPage(document)),
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

class perfompostList extends StatelessWidget { //배송 리스트
  const perfompostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const performList();
  }
}

class performList extends StatefulWidget {
  const performList({Key? key}) : super(key: key);

  @override
  State<performList> createState() => _performListState();
}

class _performListState extends State<performList> {
  Stream collectionStream =
      FirebaseFirestore.instance.collection('list').snapshots();
  CollectionReference postList = FirebaseFirestore.instance.collection('list');

  final db_p = FirebaseFirestore.instance
      .collection('list')
      .where("postOption", isEqualTo: "배송");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: db_p.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("loading...");
            }
            return ListView(
              children:
                  snapshot.data!.docs.map((QueryDocumentSnapshot document) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => postPage(document)),
                    );
                  },
                  child: ListTile(
                    title: Text(document['postTitle']),
                    subtitle: Text(document['content']),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}

class mainPost extends StatefulWidget {
  const mainPost({Key? key}) : super(key: key);

  @override
  State<mainPost> createState() => _mainPostState();
}

class _mainPostState extends State<mainPost> {
  CollectionReference main_db = FirebaseFirestore.instance.collection('list');
  String startPosition = '';
  String endPosition = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(

      ),
    );
  }
}


class postPage extends StatefulWidget {
  final QueryDocumentSnapshot document;
  const postPage(this.document);

  @override
  State<postPage> createState() => _postPageState();
}

class _postPageState extends State<postPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document['postTitle']),
      ),
      body: Column(
        children: [
          Text(widget.document['content']),
        ],
      ),
    );
  }
}
