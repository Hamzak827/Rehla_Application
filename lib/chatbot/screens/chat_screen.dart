import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:Rehla/chatbot/widgets/chat_screen_widgets/gemini_tab_window.dart';
import 'package:Rehla/main.dart';
import 'package:Rehla/theme/theme_manager.dart'; // Assuming you have a theme manager

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.startIndex});
  final int startIndex;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int presentIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.index = widget.startIndex < 1 ? widget.startIndex : 0;
    presentIndex = widget.startIndex;
    _tabController.addListener(() {
      setState(() {
        presentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = themeManager.themeMode == ThemeMode.light;

    return Scaffold(
      drawer: Drawer(
        child: ListView(),
      ),
      appBar: AppBar(
        centerTitle: true,
        title:  Text.rich(TextSpan(children: [
          TextSpan(
              text: "CHATBOT",
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 1.5,
                ),
              )),
         
        ])),
        automaticallyImplyLeading: false,
        
        leading: IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              Navigator.pop(context);
            },
            icon: const Icon(
              size: 20,
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(61,115,127,4),
                Color.fromRGBO(61,115,127,4),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLightTheme
                ? [
                    Color.fromRGBO(206, 199, 191,4),
                    Color.fromRGBO(206, 199, 191,4),
                    Color.fromRGBO(206, 199, 191,4),
                    Color.fromRGBO(206, 199, 191,4),
                    
                  ]
                : [
                    Color.fromARGB(255, 5, 6, 6),
                    Color.fromARGB(255, 8, 9, 9),
                    Color.fromARGB(255, 11, 13, 13),
                    Color.fromARGB(255, 9, 9, 8),
                    Color.fromARGB(255, 10, 10, 10)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: const GeminiTabWindow(),
      ),
    );
  }
}


