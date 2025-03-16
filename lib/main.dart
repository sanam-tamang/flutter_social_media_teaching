import 'package:flutter/material.dart';
import 'package:social_media/pages/home_page.dart';
import 'package:social_media/pages/sign_in_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://kkshpkallnttjcdwrpta.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtrc2hwa2FsbG50dGpjZHdycHRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3NDY5NzMsImV4cCI6MjA1NzMyMjk3M30.zIKd8-3LpL5CrCVkXC2I9ttdhkKdtmtBhiQ7w4Nn60g",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Social Media",
      home:
          Supabase.instance.client.auth.currentUser != null
              ? HomePage()
              : SignInPage(),
    );
  }
}
