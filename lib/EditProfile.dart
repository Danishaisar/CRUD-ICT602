import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDisplayScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String course; // New field for the course

  ProfileDisplayScreen(this.name, this.phone, this.course);

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
            Text('Course: $course'), // Display the course information
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
  TextEditingController courseController =
      TextEditingController(); // New controller for the course

  @override
  void initState() {
    super.initState();
    // Retrieve the user's profile data and populate the text fields
    _retrieveProfileData();
  }

  void _retrieveProfileData() {
    if (widget.user != null) {
      String userUid = widget.user.uid;
      var userRef = FirebaseFirestore.instance.collection('users').doc(userUid);

      userRef.get().then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          var userData = snapshot.data() as Map<String, dynamic>;
          String name = userData['name'];
          String phone = userData['phone'];
          String course = userData['course'] ??
              ''; // Retrieve course and provide default value if null
          bool isDeleted = userData['isDeleted'] ?? false;

          setState(() {
            nameController.text = name;
            phoneController.text = phone;
            courseController.text = course;

            if (isDeleted) {
              nameController.clear();
              phoneController.clear();
              courseController.clear();
            }
          });
        }
      });
    }
  }

  void _updateProfile() async {
    String newName = nameController.text;
    String newPhone = phoneController.text;
    String newCourse = courseController.text; // Get the course

    if (widget.user != null) {
      String userUid = widget.user.uid;
      var userRef = FirebaseFirestore.instance.collection('users').doc(userUid);

      try {
        await userRef.set({
          'name': newName,
          'phone': newPhone,
          'course': newCourse, // Save the course in Firestore
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully'),
        ));

        setState(() {
          nameController.text = newName;
          phoneController.text = newPhone;
          courseController.text = newCourse;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfileDisplayScreen(newName, newPhone, newCourse),
          ),
        );
      } catch (e) {
        print('Error updating profile: $e');
      }
    } else {
      // Handle the case where the user is not signed in
    }
  }

  void _deleteProfile() async {
    if (widget.user != null) {
      try {
        String userUid = widget.user.uid;
        var userRef =
            FirebaseFirestore.instance.collection('users').doc(userUid);
        await userRef.update({
          'isDeleted': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile has been deleted from the app.'),
        ));

        Navigator.pop(context);
      } catch (e) {
        print('Error deleting profile: $e');
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
            TextField(
              controller: courseController,
              decoration: InputDecoration(
                  labelText: 'Course'), // New TextField for the course
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
                primary: Colors.red,
              ),
              child: Text('Delete Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileDisplayScreen(
                        nameController.text,
                        phoneController.text,
                        courseController.text), // Pass name, phone, and course
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
