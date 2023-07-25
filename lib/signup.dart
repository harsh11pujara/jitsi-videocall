import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  Signup({Key? key}) : super(key: key);

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70,),
            const Text(
              "Create an Account",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 80,
            ),
            TextField(
              controller: name,
              decoration: const InputDecoration(label: Text("Name"), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 40,
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(label: Text("Email"), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 40,
            ),
            TextField(
              controller: pass,
              decoration: const InputDecoration(label: Text("Password"), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim())
                      .then((value) async {
                    Map<String, dynamic> userData = {
                      "name": name.text.trim(),
                      "email": email.text.trim(),
                      "online": false,
                      "uid": value.user!.uid.toString(),
                      "fmcToken" : await messaging.getToken()
                    };

                    await FirebaseFirestore.instance.collection("Users").doc(value.user!.uid.toString()).set(userData);
                  });
                },
                child: const Text("Signup"))
          ],
        ),
      ),
    ));
  }
}
