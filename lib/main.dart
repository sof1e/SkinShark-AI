import 'package:flutter/material.dart';
import 'package:firstapp/screens/welcome_screen.dart';

void main() {
  runApp(DermaScopeAIApp());
}

class DermaScopeAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermaScopre-AI',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
