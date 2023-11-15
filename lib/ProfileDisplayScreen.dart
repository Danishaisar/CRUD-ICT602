import 'package:flutter/material.dart';

class ProfileDisplayScreen extends StatelessWidget {
  final String name;
  final String phone;
  final Function navigateToWelcomePage;

  ProfileDisplayScreen(this.name, this.phone, this.navigateToWelcomePage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: $name'),
            Text('Phone Number: $phone'),
            ElevatedButton(
              onPressed: () {
                navigateToWelcomePage(); // Call the callback function to navigate back to WelcomePage
              },
              child: Text('Back To Welcome'),
            ),
          ],
        ),
      ),
    );
  }
}
