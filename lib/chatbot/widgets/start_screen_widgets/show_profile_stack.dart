import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Rehla/chatbot/widgets/start_screen_widgets/profile_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';

class ShowProfileStack extends StatefulWidget {
  const ShowProfileStack(
      {super.key,
      required this.networkImage,
      required this.user,
      required this.onPressed});
  final CachedNetworkImageProvider networkImage;
  final User user;
  final void Function() onPressed;

  @override
  State<ShowProfileStack> createState() => _ShowProfileStackState();
}

class _ShowProfileStackState extends State<ShowProfileStack> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color.fromARGB(41, 0, 0, 0),
              border: Border.all(
                  width: 1, color: const Color.fromARGB(70, 255, 255, 255)),
              borderRadius: BorderRadius.circular(32)),
          width: MediaQuery.of(context).size.width - 32,
          height: MediaQuery.of(context).size.height ,
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching user data'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('User data not found'));
              }

              var userData = snapshot.data!.data()!;
              var userName = userData['name'] ?? 'Name not available';
              var userEmail = userData['email'] ?? widget.user.email ?? 'Email not available';

              return Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onPressed,
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      LocalHero(
                        tag: 3,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2)),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 88,
                            foregroundImage: widget.networkImage,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ProfileDetails(name: "Name", value: userName),
                      const SizedBox(
                        height: 20,
                      ),
                      ProfileDetails(name: "Email", value: userEmail),
                      const SizedBox(
                        height: 50,
                      ),
                      
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
