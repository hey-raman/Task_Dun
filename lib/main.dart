import 'package:card_wiper/Auth_pages/login_page.dart';
import 'package:card_wiper/pages_main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:supabase_flutter/supabase_flutter.dart";

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dmhhqwmyhedeppalflmi.supabase.co',
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtaGhxd215aGVkZXBwYWxmbG1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyODI2MTYsImV4cCI6MjA3Mzg1ODYxNn0.j48k536IHoPZD0-uTWe_E5mEqRT6oMVWkqG9bzbEB1A",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF2E3440),
          secondary: Color(0xFF5E81AC),
          surface: Color(0xFFF3F3F3),
          onSurface: Color(0xFF2E3440),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Some Error Occurred");
        }

        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (session != null) {
          return SwipeScreen();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
