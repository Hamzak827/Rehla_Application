import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../screens/bookings/book_tour_screen.dart';
import '../screens/tours/overview_screen.dart';
import 'description.dart';

class ScrollSheet extends StatelessWidget {
  final TabController tabController;
  final String id;
  final List<int> date;
  final int duration;
  final List famousPoints;
  final List famousResturant;
  final List imageUrl;
  final bool isFav;
  final bool isNorth;
  final bool isSouth;
  final String location;
  final int price;
  final String title;

  ScrollSheet({
    required this.id,
    required this.date,
    required this.duration,
    required this.famousPoints,
    required this.famousResturant,
    required this.imageUrl,
    required this.isFav,
    required this.isNorth,
    required this.isSouth,
    required this.location,
    required this.price,
    required this.title,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 1.0,
      minChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeManager.themeMode == ThemeMode.dark
                ? Colors.black
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 5,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                TabBar(
                  indicatorColor: Colors.black,
                  labelStyle: GoogleFonts.lato(fontSize: 18),
                  controller: tabController,
                  labelColor: themeManager.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Description'),
                    Tab(text: 'Booking'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TabBarView(controller: tabController, children: [
                    OverviewScreen(
                      title: title,
                      location: location,
                      price: price,
                      duration: duration,
                      date:date
                    ),
                    Description(
                      famousPoints: famousPoints,
                      famousResturant: famousResturant,
                    ),
                    BookTourScreen(
                      id: id, // Pass the id to the BookTourScreen
                      date: date,
                      duration: duration,
                      famousPoints: famousPoints,
                      famousResturant: famousResturant,
                      imageUrl: imageUrl,
                      isFav: isFav,
                      isNorth: isNorth,
                      isSouth: isSouth,
                      location: location,
                      price: price,
                      title: title,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
