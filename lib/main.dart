import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Welcomepage.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  void _handleSignIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Successfully signed in with user: ${userCredential.user}");

      // Show a success toast message
      Fluttertoast.showToast(
        msg: "Login successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.green,
      );

      // Navigate to the Welcome User page after a successful login
      if (userCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(
              userCredential.user!.email ?? 'Guest',
            ),
          ),
        );
      }
    } catch (e) {
      print("Error signing in: $e");
      // Handle the sign-in error here.
    }
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential googleUserCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print(
          "Successfully signed in with Google user: ${googleUserCredential.user}");

      // Show a success toast message
      Fluttertoast.showToast(
        msg: "Google Sign-In successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.green,
      );

      // Navigate to the Welcome User page after a successful Google Sign-In
      if (googleUserCredential.user != null) {
        print("Navigating to WelcomePage");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(
              googleUserCredential.user!.email ?? 'Guest',
            ),
          ),
        );
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      // Handle the Google sign-in error here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: Text('Sign In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleGoogleSignIn,
              child: Text('Sign In with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
