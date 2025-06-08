import 'package:flutter/material.dart';
import '/welcome_page.dart';
import 'recommendation_page.dart';

void main() {
  runApp(SmartDropApp());
}

class SmartDropApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartDrop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Arial'),
      home: WelcomePage(),
      routes: {'/recommendation': (context) => const RecommendationPage()},
    );
  }
}
