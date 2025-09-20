import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Auth_pages/login_page.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _supabaseClient = Supabase.instance.client;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _supabaseClient.auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // Handle the case where the user is not signed in.
      return const Center(child: Text('Please sign in to view your profile.'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Center(
              child: Stack(
                alignment: Alignment(0, 0),
                children: [
                  CircleAvatar(radius: 80, backgroundColor: Color(0xCCCBCBCB)),
                  Icon(Icons.person, size: 100),
                ],
              ),
            ),
            SizedBox(height: 40),
            const Text(
              'User Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Display the User ID
            Text(
              'User ID: ${user!.userMetadata?['display_name']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Display the User Email
            Text(
              'Email: ${user!.email ?? "N/A"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await _supabaseClient.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget ybuild(BuildContext context) {
    // TODO: implement ybuild
    throw UnimplementedError();
  }
}
