import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageCursor extends StatefulWidget {
  final List<Map<String, String>> places;

  ImageCursor({required this.places});

  @override
  _ImageCursorState createState() => _ImageCursorState();
}

class _ImageCursorState extends State<ImageCursor> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.places.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.places[index]['url']!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  widget.places[_currentPage]['name']!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.7),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.places.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
