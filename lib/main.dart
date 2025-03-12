import 'package:flutter/material.dart';
import 'package:social_media/pages/home_page.dart';
import 'package:social_media/pages/sign_up_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Social Media", home: SignUpPage());
  }
}
