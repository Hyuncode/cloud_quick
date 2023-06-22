import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class loginScreen extends StatelessWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const loginScreenState();
  }
}

class loginScreenState extends StatelessWidget {
  const loginScreenState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const _loginScreenState(),
    );
  }
}

class _loginScreenState extends StatelessWidget {
  const _loginScreenState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Authentication(),
    );
  }
}

class Authentication extends StatelessWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SignInScreen(
        providerConfigs: [
          EmailProviderConfiguration()
        ],
    );
  }
}
