import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formatted_text/formatted_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ModelText extends StatelessWidget {
  const ModelText({Key? key, required this.text, required this.imgAddress}) : super(key: key);

  final String text;
  final String imgAddress;

  @override
  Widget build(BuildContext context) {
    // Determine current theme brightness
    final Brightness brightness = Theme.of(context).brightness;

    Widget showLogo = CircleAvatar(
      backgroundColor: Color.fromRGBO(61, 115, 127, 4),
      child: Image.asset(
        "assets/chatbot.png",
        width: 26,
        height: 26,
      ),
    );

    if (imgAddress == "assets/chatbot.png") {
      showLogo = CircleAvatar(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
        foregroundImage: AssetImage(imgAddress),
        radius: 20,
      );
    }

    Widget content = Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                width: i != 2
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 2,
                height: 12,
              ),
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adjusted padding here to align with UserText widget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: showLogo,
          ),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            constraints: const BoxConstraints(minHeight: 150),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(right: 4, left: 4, top: 12, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: brightness == Brightness.dark
                  ? Colors.white // Set background color for dark theme
                  : Color.fromARGB(255, 10, 9, 9), // Set background color for light theme
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: text.isEmpty
                      ? content
                      : FormattedText(
                          text,
                          formatters: [
                            FormattedTextFormatter(
                              patternChars: '!!!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: brightness == Brightness.dark
                                    ? Colors.black // Set text color for dark theme
                                    : Colors.white, // Set text color for light theme
                              ),
                            ),
                            const FormattedTextFormatter(
                              patternChars: '**',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FormattedTextFormatter(
                              patternChars: '```',
                              style: GoogleFonts.spaceMono(),
                            ),
                            FormattedTextFormatter(
                              patternChars: '`',
                              style: GoogleFonts.spaceMono(),
                            ),
                          ],
                          style: TextStyle(
                            color: brightness == Brightness.dark
                                ? Colors.black // Set text color for dark theme
                                : Colors.white, // Set text color for light theme
                            fontWeight: FontWeight.w500, // Set fontWeight
                            fontSize: 15, // Set fontSize
                          ),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: text.replaceAll("**", "").replaceAll("```", "")),
                        );
                      },
                      icon:  Icon(
                        Icons.copy,
                        color: brightness == Brightness.dark
                            ? Colors.black // Set icon color for dark theme
                            : Colors.white, // Set icon color for light theme
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
