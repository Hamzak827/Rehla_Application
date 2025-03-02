// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Rehla/login_signup/login_view.dart';
import 'package:Rehla/screens/profile/profile_edit_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isExpanded = false; // Track dropdown expansion state

  // Sample data for FYP group members and project description
  final List<Map<String, String>> fypGroupMembers = [
    {'name': 'Hamza Khalel', 'role': 'Developer'},
    {'name': 'Usman Abbas', 'role': 'Developer'},
    {'name': 'Safi ur Rehman', 'role': 'Developer'},
  ];

  String fypDescription = 'This FYP project focuses on developing a Flutter application for tourism.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(61, 115, 127, 4),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'P R O F I L E',
            style: GoogleFonts.lato(
              color: themeManager.themeMode == ThemeMode.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 26,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  color: themeManager.themeMode == ThemeMode.light
                      ? Colors.white
                      : Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              var data = snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipOval(
                                              clipBehavior: Clip.hardEdge,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  // Use Navigator to show a full-screen image page
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Scaffold(
                                                        backgroundColor:
                                                            Colors.grey,
                                                        body: Center(
                                                          child: Hero(
                                                              tag:
                                                                  'user-avatar',
                                                              child: data['image_url'] !=
                                                                      ""
                                                                  ? Image
                                                                      .network(
                                                                      data[
                                                                          'image_url'],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.asset(
                                                                      "assets/avatar.png",
                                                                      height:
                                                                          100,
                                                                      width:
                                                                          100,
                                                                    )),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Hero(
                                                    tag: 'user-avatar',
                                                    child: data!['image_url'] !=
                                                            ""
                                                        ? Image.network(
                                                            data['image_url'],
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.asset(
                                                            "assets/avatar.png",
                                                            height: 100,
                                                            width: 100,
                                                          )),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -12,
                                              right: -15,
                                              child: IconButton(
                                                onPressed: () async {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          ProfileEditScreen
                                                              .routeName);
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.black,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(1),
                                              child: Text(
                                                data['name'],
                                                style: GoogleFonts.lato(
                                                    fontSize: 25),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 2, bottom: 5),
                                              child: Text(
                                                data['email'],
                                                style: TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded; // Toggle dropdown
                    });
                  },
                  child: Card(
                    color: themeManager.themeMode == ThemeMode.light
                        ? Colors.white
                        : Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Details',
                                style: GoogleFonts.lato(fontSize: 18),
                              ),
                              Icon(
                                _isExpanded
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              )
                            ],
                          ),
                          if (_isExpanded) // Show content if expanded
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  fypDescription,
                                  style: GoogleFonts.lato(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                ...fypGroupMembers.map((member) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      '${member['name']} - ${member['role']}',
                                      style: GoogleFonts.lato(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Card(
                  color: themeManager.themeMode == ThemeMode.light
                      ? Colors.white
                      : Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '  Dark Mode',
                          style: GoogleFonts.lato(fontSize: 18),
                        ),
                        Switch(
                            value: themeManager.themeMode == ThemeMode.dark,
                            onChanged: (value) async {
                              setState(() {
                                themeManager.toggleTheme(value);
                              });
                            })
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                    style: ButtonStyle(
                        textStyle: MaterialStatePropertyAll(
                            GoogleFonts.lato(fontSize: 20)),
                        fixedSize: const MaterialStatePropertyAll(
                          Size(230, 50),
                        )),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context)
                          .pushReplacementNamed(LoginView.routeName);
                    },
                    child: const Text(
                      'Log Out',
                    ))
              ],
            ),
          ),
        ));
  }
}

