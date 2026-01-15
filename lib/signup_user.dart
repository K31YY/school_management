import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/app_colors.dart';

class SignupUser extends StatefulWidget {
  const SignupUser({super.key});

  @override
  State<SignupUser> createState() => _SignupUserState();
}

class _SignupUserState extends State<SignupUser> {
  bool ispassword = true;
  final txt = FocusNode();
  void togglePassword() {
    setState(() {
      ispassword = !ispassword;
      if (txt.hasPrimaryFocus) return;
      txt.canRequestFocus = false;
    });
  }

  final _keyForm = GlobalKey<FormState>();
  TextEditingController controllerFullname = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirm = TextEditingController();

  Future<void> singupUser(
    String fullname,
    String email,
    String password,
  ) async {
    try {
      EasyLoading.show(status: 'Loading...');
      await Future.delayed(Duration(seconds: 1));
      // create user with Email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid;

      // save user info with Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fullname': fullname,
        'email': email,
        'createdAt': DateTime.now(),
      });
      EasyLoading.showSuccess('Added user successfully');
      Navigator.pop(context);
      if (!mounted) return;
    } catch (ex) {
      EasyLoading.showError('Error: $ex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Signup User')),
      body: Form(
        key: _keyForm,
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(10, 30, 10, 20),
              child: Image.asset(
                'assets/images/logo.png',
                width: 600,
                height: 300,
              ),
            ),
            SizedBox(height: 35),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
                controller: controllerFullname,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.blue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.account_circle),
                  prefixIconColor: Colors.black,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email is invaild!';
                  }
                  return null;
                },
                controller: controllerEmail,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.blue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.account_circle),
                  prefixIconColor: Colors.black,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                controller: controllerPassword,
                obscureText: ispassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.blue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.lock),
                  prefixIconColor: Colors.black,
                  suffixIcon: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: GestureDetector(
                      onTap: togglePassword,
                      child: Icon(
                        // condition ? expr1 : expr2;
                        ispassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter confirm password';
                  }
                  if (value != controllerPassword.text.trim()) {
                    return 'Password not match!';
                  }
                  return null;
                },
                controller: controllerConfirm,
                obscureText: ispassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.blue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.lock),
                  prefixIconColor: Colors.black,
                  suffixIcon: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: GestureDetector(
                      onTap: togglePassword,
                      child: Icon(
                        // condition ? expr1 : expr2;
                        ispassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 55,
              margin: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (_keyForm.currentState!.validate()) {
                    String fullname = controllerFullname.text;
                    String email = controllerEmail.text;
                    String password = controllerPassword.text.trim();
                    singupUser(fullname, email, password);
                  }
                },
                child: Text(
                  'SING UP',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
