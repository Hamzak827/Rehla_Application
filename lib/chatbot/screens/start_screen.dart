import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_hero/local_hero.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:Rehla/chatbot/provider/image_provider.dart';
import 'package:Rehla/chatbot/screens/chat_screen.dart';
import 'package:Rehla/chatbot/widgets/start_screen_widgets/display_container.dart';
import 'package:Rehla/chatbot/widgets/start_screen_widgets/show_profile_stack.dart';

class StartScreen extends ConsumerStatefulWidget {
  static const routeName = '/start-screen';

  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen>
    with SingleTickerProviderStateMixin {
  final User user = FirebaseAuth.instance.currentUser!;
  int time = int.parse(DateFormat.H().format(DateTime.now()));
  bool showProfileDetails = false;

  late String greet;
  String displayName = 'Loading...'; // Initialize with a default value
  ImageProvider<Object>? profileImageProvider;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Fetch user profile data on initState
  }

  void fetchUserProfile() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        displayName = snapshot.get('name');
        String? imageUrl = snapshot.get('image_url');
        profileImageProvider = (imageUrl != null
            ? CachedNetworkImageProvider(imageUrl)
            : AssetImage('assets/avatar.png')) as ImageProvider<Object>?; // Default image if no URL
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine greeting based on time
    if (time >= 6 && time < 12) {
      greet = "Good\nMorning,\n";
    } else if (time >= 12 && time < 18) {
      greet = "Good\nAfternoon,\n";
    } else if (time >= 18 && time < 20) {
      greet = "Good\nEvening,\n";
    } else {
      greet = "Good\nTo See You,\n";
    }

    return Scaffold(
      body: LocalHeroScope(
        duration: const Duration(milliseconds: 230),
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(61, 115, 127, 4),
                Color.fromRGBO(61, 115, 127, 4),
                Color.fromRGBO(61, 115, 127, 4),
                Color.fromRGBO(61, 115, 127, 4),
                Color.fromRGBO(61, 115, 127, 4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 125,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            greet,
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !showProfileDetails,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextButton(
                                style: TextButton.styleFrom(),
                                onPressed: () async {
                                  setState(() {
                                    showProfileDetails = true;
                                  });
                                },
                                child: LocalHero(
                                  tag: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 33,
                                      foregroundImage: profileImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 68,
                      child: DefaultTextStyle(
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 170, 185, 141),
                          ),
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TyperAnimatedText(
                              "Hey, $displayName", // Display name from Firestore
                              textStyle: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 170, 185, 141),
                                ),
                              ),
                            ),
                            TyperAnimatedText(
                                "Ready to explore destinations?"),
                            TyperAnimatedText(
                                "Ask me about local attractions!"),
                            TyperAnimatedText("Let's plan your itinerary"),
                            TyperAnimatedText("Discover hidden gems today!"),
                            TyperAnimatedText(
                                "Let's find something amazing today"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SizedBox(height: 20),
                    DisplayContainer(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) =>
                                const ChatScreen(startIndex: 0),
                          ),
                        );
                      },
                      imageAddress: "assets/chatbot.png",
                      name: "Chatbot",
                      title: "Start Message!\nChatbot",
                      desc:
                          "Ask away! Chatbot, ready to answer\nyour questions and assist you.",
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showProfileDetails,
                child: Positioned(
                  top: 185,
                  bottom: 0,
                  child: ShowProfileStack(
                    networkImage: profileImageProvider != null &&
                            profileImageProvider is CachedNetworkImageProvider
                        ? profileImageProvider as CachedNetworkImageProvider
                        : CachedNetworkImageProvider(
                            'assets/avatar.png'), // Provide a default URL or handle this case appropriately
                    user: user,
                    onPressed: () {
                      setState(() {
                        showProfileDetails = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

