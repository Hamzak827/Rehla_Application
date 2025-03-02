import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserText extends StatefulWidget {
  const UserText({
    Key? key,
    required this.value,
    required this.onPressed,
  }) : super(key: key);

  final String value;
  final void Function(String) onPressed;

  @override
  _UserTextState createState() => _UserTextState();
}

class _UserTextState extends State<UserText> {
  ImageProvider<Object>? _profileImage;

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
  }

  @override
  void dispose() {
    // Ensure to cancel any asynchronous operations
    // Typically, you cancel subscriptions, timers, or async tasks here
    super.dispose();
  }

  Future<void> fetchProfileImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        String? imageUrl = snapshot.get('image_url') as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          if (mounted) { // Check if the widget is still mounted
            setState(() {
              _profileImage = NetworkImage(imageUrl);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _profileImage = const AssetImage('assets/avatar.png');
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _profileImage = const AssetImage('assets/avatar.png');
          });
        }
      }
    } catch (e) {
      print('Error fetching profile image: $e');
      if (mounted) {
        setState(() {
          _profileImage = const AssetImage('assets/avatar.png');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 18,
              backgroundImage: _profileImage,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: InkWell(
            onTap: () {
              widget.onPressed(widget.value);
            },
            child: Icon(
              Icons.edit_outlined,
              color: isDarkTheme ? Colors.white : Colors.black,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
