import 'package:flutter/material.dart';

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const homePostPage();
  }
}

class homePostPage extends StatefulWidget {
  const homePostPage({Key? key}) : super(key: key);

  @override
  State<homePostPage> createState() => _homePostPageState();
}

class _homePostPageState extends State<homePostPage> {

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
