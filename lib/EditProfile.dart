// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDisplayScreen extends StatelessWidget {
  final String name;
  final String phone;

  ProfileDisplayScreen(this.name, this.phone);

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
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen(this.user);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve the user's profile data and populate the text fields
    _retrieveProfileData();
  }

  void _retrieveProfileData() {
    if (widget.user != null) {
      // Get the user's UID
      String userUid = widget.user.uid;

      // Create a reference to the user's document in the Firestore 'users' collection
      var userRef = FirebaseFirestore.instance.collection('users').doc(userUid);

      userRef.get().then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          var userData = snapshot.data() as Map<String, dynamic>;
          String name = userData['name'];
          String phone = userData['phone'];
          bool isDeleted = userData['isDeleted'] ?? false;

          setState(() {
            nameController.text = name;
            phoneController.text = phone;

            if (isDeleted) {
              // If the profile is marked as deleted, clear the text fields
              nameController.clear();
              phoneController.clear();
            }
          });
        }
      });
    }
  }

  void _updateProfile() async {
    String newName = nameController.text;
    String newPhone = phoneController.text;

    // Ensure that the user is signed in
    if (widget.user != null) {
      // Get the user's UID
      String userUid = widget.user.uid;

      // Create a reference to the user's document in the Firestore 'users' collection
      var userRef = FirebaseFirestore.instance.collection('users').doc(userUid);

      try {
        await userRef.set({
          'name': newName,
          'phone': newPhone,
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully'),
        ));

        // Update the displayed profile information
        setState(() {
          nameController.text = newName;
          phoneController.text = newPhone;
        });

        // Navigate to the ProfileDisplayScreen and pass the user's name and phone number
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfileDisplayScreen(newName, newPhone), // Pass name and phone
          ),
        );
      } catch (e) {
        print('Error updating profile: $e');
        // Handle the error
      }
    } else {
      // Handle the case where the user is not signed in
    }
  }

  void _deleteProfile() async {
    // Ensure that the user is signed in
    if (widget.user != null) {
      try {
        // Update the isDeleted flag in the database instead of deleting
        String userUid = widget.user.uid;
        var userRef =
            FirebaseFirestore.instance.collection('users').doc(userUid);
        await userRef.update({
          'isDeleted': true, // Set the isDeleted flag to true
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile has been deleted from the app.'),
        ));

        // Navigate back to a previous screen, e.g., the login screen
        Navigator.pop(context);
      } catch (e) {
        print('Error deleting profile: $e');
        // Handle the error
      }
    } else {
      // Handle the case where the user is not signed in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteProfile,
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Set the button color to red
              ),
              child: Text('Delete Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the ProfileDisplayScreen and pass the user's name and phone number
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileDisplayScreen(
                        nameController.text,
                        phoneController.text), // Pass name and phone
                  ),
                );
              },
              child: Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
