import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import '../../providers/booking.dart';
import '../../screens/bookings/book_tour_screen.dart';
import '../../main.dart';
import '../../providers/bookings.dart';
import '../../providers/tours.dart';

class BookingScreen extends StatefulWidget {
  static const routeName = '/bookings-screen';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await Provider.of<Tours>(context, listen: false).fetchTours();
    await Provider.of<Bookings>(context, listen: false).fetchBookingsforusers(userId);
  }

  String _calculateRemainingTime(DateTime tourDate) {
    final now = DateTime.now();
    final difference = tourDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} remaining';
    } else {
      final tourTime = DateTime(tourDate.year, tourDate.month, tourDate.day, 12, 0, 0);
      final hoursDifference = tourTime.difference(now).inHours;

      if (hoursDifference > 0) {
        return '${hoursDifference} hour${hoursDifference == 1 ? '' : 's'} remaining';
      } else if (hoursDifference == 0) {
        return 'Your tour is today';
      } else {
        return 'Your tour has passed';
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, BookingStatus status) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': status.index,
    });
    await Provider.of<Bookings>(context, listen: false).fetchBookingsforusers(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> _handleTourReady(Booking booking) async {
    final isTourToday = _calculateRemainingTime(booking.chooseDate) == 'Your tour is today';
    if (isTourToday && booking.status == BookingStatus.confirmed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tour Ready'),
          content: Text('Is your tour ready?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _updateBookingStatus(booking.id, BookingStatus.completed);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    } else if (!isTourToday && booking.status == BookingStatus.confirmed) {
      await _updateBookingStatus(booking.id, BookingStatus.cancelled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsData = Provider.of<Bookings>(context);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    bookingsData.fetchBookingsforusers(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(61, 115, 127, 4),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'B O O K I N G S',
          style: GoogleFonts.lato(
            color: themeManager.themeMode == ThemeMode.light ? Colors.black : Colors.white,
            fontSize: 25,
          ),
        ),
      ),
      body: Consumer<Bookings>(
        builder: (context, bookingsData, _) {
          final List<Booking> bookings = bookingsData.bookings;
          final toursData = Provider.of<Tours>(context, listen: false);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final tour = toursData.findByid(booking.tourId);
                if (tour == null) return SizedBox();
                final remainingTime = _calculateRemainingTime(booking.chooseDate);
                final bookingStatus = booking.status.name.toUpperCase();

                return Bounce(
                  duration: const Duration(milliseconds: 95),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          backgroundColor: themeManager.themeMode == ThemeMode.light ? Colors.white : Colors.grey.shade900,
                          title: const Text('Details'),
                          contentPadding: const EdgeInsets.all(15),
                          children: [
                            Text('Location: ${(tour.title).toUpperCase()}'),
                            Text('Date: ${DateFormat('EEE , M/d/y').format(booking.chooseDate)}'),
                            Text('Number of people: ${booking.person}'),
                            if (booking.hotelType == '1') const Text('Hotel And Restaurant : 5 Star'),
                            if (booking.hotelType == '2') const Text('Hotel And Restaurant : 4 Star'),
                            if (booking.hotelType == '3') const Text('Hotel And Restaurant : 3 Star'),
                            Text('Rooms: ${booking.rooms}'),
                            Text('Total: ${booking.total}'),
                            Text('Status: $bookingStatus'),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: themeManager.themeMode == ThemeMode.light ? Colors.white : Colors.grey.shade900,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      tour.imageUrl.isNotEmpty ? tour.imageUrl[0] : 'URL_TO_YOUR_DEFAULT_IMAGE',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tour.title,
                                        style: GoogleFonts.lato(fontSize: 19),
                                      ),
                                      Text(
                                        'Date: ${DateFormat('EEE , M/d/y').format(booking.chooseDate)}',
                                        style: GoogleFonts.lato(fontSize: 14),
                                      ),
                                      Text(
                                        'Departure Time : 12:00 pm',
                                        style: GoogleFonts.lato(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (remainingTime.contains('day') || remainingTime.contains('hour'))
                                  Text(
                                    'Remaining: $remainingTime',
                                    style: GoogleFonts.lato(fontSize: 14),
                                  ),
                                if (booking.status == BookingStatus.confirmed && remainingTime == 'Your tour is today')
                                  OutlinedButton(
                                    onPressed: () async {
                                      await _handleTourReady(booking);
                                    },
                                    child: Text('Your tour is ready'),
                                  ),
                                Text('Status: $bookingStatus'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: booking.status == BookingStatus.pending
                                      ? () async {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (ctx) => Scaffold(
                                                appBar: AppBar(
                                                  title: Text('Reschedule Booking'),
                                                ),
                                                body: BookTourScreen(
                                                  booking: booking,
                                                  title: '',
                                                  date: [],
                                                  duration: 0,
                                                  famousPoints: [],
                                                  famousResturant: [],
                                                  id: '',
                                                  imageUrl: [],
                                                  isFav: false,
                                                  isNorth: false,
                                                  isSouth: false,
                                                  price: tour.price,
                                                  location: '',
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      : null, // Disable the button for confirmed, completed, or cancelled statuses
                                  child: const Text('Reschedule Booking'),
                                ),
                                OutlinedButton(
                                  onPressed: booking.status == BookingStatus.pending
                                      ? () async {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Confirm Cancellation'),
                                              content: Text('Are you sure you want to cancel this booking?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _updateBookingStatus(booking.id, BookingStatus.cancelled);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      : null, // Disable the button for confirmed, completed, or cancelled statuses
                                  child: const Text('Cancel Booking'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


