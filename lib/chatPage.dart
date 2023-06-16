import 'package:flutter/material.dart';

class chatPage extends StatelessWidget {
  const chatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'chating',
      home: chatPageState(),
    );
  }
}

class chatPageState extends StatefulWidget {
  const chatPageState({Key? key}) : super(key: key);

  @override
  State<chatPageState> createState() => _chatPageStateState();
}

class _chatPageStateState extends State<chatPageState> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

