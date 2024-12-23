import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_data_app/LoginScreen.dart';
import 'package:watch_data_app/user_auth.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool isLoading = false;

  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> signUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        try {
          await firestore.collection('WatchUsersDB').doc(user.uid).set({
            'name': username.text, // Ensure this is a valid string
            'email': user.email, // Ensure email is not null
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          print("Data added successfully");

          // If successful, navigate to the next screen
          Get.offAll(Wrapper());
        } catch (e) {
          print("Error storing data in Firestore: $e");
        }
      } else {
        print('User creation failed, user is null');
      }
    } catch (e) {
      print('Error during sign up: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    border: border,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: border,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: password,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: border,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  child: const Text('Sign in with Email'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: (){Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );},
                  child: const Text('go to login'),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
