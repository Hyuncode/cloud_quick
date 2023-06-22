import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class addUser extends StatefulWidget {
  const addUser({Key? key}) : super(key: key);

  @override
  State<addUser> createState() => _addUserState();
}

class _addUserState extends State<addUser> {
  final _nicknameController = TextEditingController();

  void submitUser() async{
    CollectionReference fireuser =
    FirebaseFirestore.instance.collection('UserInfo');
    final user = FirebaseAuth.instance.currentUser;

    try{
      await fireuser.add({
        'Nickname' : _nicknameController.text,
        'UID' : user?.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("등록 완료")),
      );
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("등록 실패")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            Text("개인 정보 입력"),
            SizedBox(height: 10,),
            TextFormField(
              decoration: InputDecoration(
                labelText: "닉네임",
                border: OutlineInputBorder(),
              ),
              controller: _nicknameController,
            ),
            ElevatedButton(
                onPressed: (){
                  submitUser();
                  Navigator.pop(context);
                },
                child: Text("정보 등록")
            ),
          ],
        ),
      ),
    );
  }
}
