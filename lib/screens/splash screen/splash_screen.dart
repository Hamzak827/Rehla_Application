import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Rehla/component/navigation_bar.dart';
import 'package:Rehla/component/admin_navigation_bar.dart';
import 'package:Rehla/login_signup/signup_view.dart';
import 'package:Rehla/model/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((snapshot) {
        if (snapshot.exists) {
          UserModel userModel = UserModel.fromSnapshot(snapshot);
          if (userModel.isAdmin) {
            Timer(
              const Duration(seconds: 2),
              () => Navigator.of(context).pushReplacementNamed(AdminNavigationBars.routeName),
            );
          } else {
            Timer(
              const Duration(seconds: 2),
              () => Navigator.of(context).pushReplacementNamed(NavigationBars.routeName),
            );
          }
        } else {
          Timer(
            const Duration(seconds: 2),
            () => Navigator.of(context).pushReplacementNamed(SignUpView.routeName),
          );
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
        Navigator.of(context).pushReplacementNamed(SignUpView.routeName);
      });
    } else {
      Timer(
        const Duration(seconds: 1),
        () => Navigator.of(context).pushReplacementNamed(SignUpView.routeName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/1024.png",
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            LoadingAnimationWidget.threeRotatingDots(
              color: const Color.fromARGB(255, 14, 14, 14), // Customize the color
              size:30, // Customize the size
            ),
            SizedBox(height: 10),
             Text(
      "Rehla",
      style: GoogleFonts.lato(
        fontSize: 28,       // Customize the font size
        fontWeight: FontWeight.bold,  // Customize the font weight
        color: Color.fromRGBO(61,115,127,4),  // Customize the color
      ),
    ),
          ],
        ),
      ),
    );
  }
}
