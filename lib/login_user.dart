import 'package:flutter/material.dart';
import 'package:ungthoung_app/app_colors.dart';
import 'package:ungthoung_app/app_dashboard.dart';
import 'package:ungthoung_app/signup_user.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  bool ispassword = true;
  final txt = FocusNode();
  void togglePassword() {
    setState(() {
      ispassword = !ispassword;
      if (txt.hasPrimaryFocus) return;
      txt.canRequestFocus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Login User')),
      body: ListView(
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
            child: TextField(
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
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TextField(
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
            height: 55,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AppDashboard()),
                  (route) => false,
                );
              },
              child: Text(
                'LOGIN',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.bgColor),
              ),
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Does not have account?'),
              SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupUser()),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: AppColors.bgColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
