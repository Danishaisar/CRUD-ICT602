import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EditProfile.dart';

class WelcomePage extends StatelessWidget {
  final String email;

  WelcomePage(this.email);

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danish App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, $email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _handleSignOut(context);
              },
              child: Text('Logout'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(currentUser),
                    ),
                  );
                } else {
                  // Handle the case where the current user is null, e.g., show an error message.
                }
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
