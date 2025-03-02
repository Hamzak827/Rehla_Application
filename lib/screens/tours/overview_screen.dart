// ignore_for_file: unnecessary_const, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../widget/price_duration_tile.dart';
import '../../widget/services_tile.dart';

class OverviewScreen extends StatefulWidget {
  final String title;
  final String location;
  final int price;
  final int duration;
  final List<int> date;
  
 // Ensure this is a List<int>

  OverviewScreen({
    required this.title,
    required this.location,
    required this.price,
    required this.duration,
    required this.date,

  });

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  List<String> formattedDates = [];

  @override
  void initState() {
    super.initState();
    _formatDates();
  }

void _formatDates() {
  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;
  final today = now.day;

  formattedDates = widget.date.map((day) {
    // Determine the correct month and year based on the day value
    int displayMonth = (day >= today) ? currentMonth : (currentMonth % 12) + 1;
    int displayYear = (displayMonth == 1 && currentMonth == 12) 
        ? currentYear + 1 
        : currentYear;

    // Ensure day value is valid for the month
    try {
      final date = DateTime(displayYear, displayMonth, day);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return 'Invalid Date'; // Handle invalid dates gracefully
    }
  }).toList();
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.lato(
                      fontSize: 21, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on_outlined),
                Expanded(
                  child: Text(
                    '${widget.location}, Pakistan',
                    style: GoogleFonts.lato(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                priceDurationTile('Price', context, widget.price.toString()),
                priceDurationTile('Duration', context,
                    '${widget.duration} Days ${widget.duration - 1} Nights'),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Available Dates',
                style: GoogleFonts.lato(
                    fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ),
            formattedDates.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formattedDates.map((date) {
                      return Card(
                        color: Colors.grey[200], // Light gray background
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            date,
                            style: GoogleFonts.lato(fontSize: 16),
                          ),
                          tileColor: Colors.grey[200], // Match card color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.grey[200], // Light gray background
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          'No available dates',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                        tileColor: Colors.grey[200], // Match card color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Services',
                style: GoogleFonts.lato(
                    fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    servicesTile(Icons.follow_the_signs_sharp, 'Famous Spots',
                        context, () {}),
                    servicesTile(
                        Icons.house_outlined, 'Hotels', context, () {}),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
