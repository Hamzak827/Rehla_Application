import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/booking.dart';
import '../../providers/bookings.dart';
import '../../main.dart';
import '../../providers/tour.dart';
import '../../providers/tours.dart';

class AdminBookings extends StatefulWidget {
  const AdminBookings({super.key});
  static const routeName = '/user-bookings';

  @override
  State<AdminBookings> createState() => _AdminBookingsState();
}

class _AdminBookingsState extends State<AdminBookings> {
  DateTime _selectedDate = DateTime.now();
  bool _filterByDate = false;
  Map<String, String> userNames = {};

  @override
  void initState() {
    super.initState();
    Provider.of<Bookings>(context, listen: false).fetchBookings();
    Provider.of<Tours>(context, listen: false).fetchTours();
    fetchUserNames(); // Fetch user names when the widget is initialized
  }

  Future<void> fetchUserNames() async {
    final bookings = Provider.of<Bookings>(context, listen: false).bookings;
    final Map<String, String> fetchedUserNames = {};

    for (var booking in bookings) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(booking.userId).get();
      if (userDoc.exists) {
        fetchedUserNames[booking.userId] = userDoc['name'];
      }
    }

    setState(() {
      userNames = fetchedUserNames;
    });
  }

  Future<void> approveBooking(String bookingId, bool isApproved) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': isApproved ? BookingStatus.confirmed.index : BookingStatus.pending.index,
      'isApproved': isApproved,
    });
    Provider.of<Bookings>(context, listen: false).fetchBookings();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterByDate = true;
      });
    }
  }

  DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception("Unsupported date format");
    }
  }

  @override
  Widget build(BuildContext context) {
    final toursData = Provider.of<Tours>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color.fromRGBO(61,115,127,4),
        centerTitle: true,
        title: Text(
          'A L L  B O O K I N G S',
          style: GoogleFonts.roboto(
            color: themeManager.themeMode == ThemeMode.light ? Colors.black : Colors.white,
            fontSize: 25,
          ),
        ),
       
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot document = documents[index];
              final Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
              if (data == null) {
                return SizedBox(); // Return an empty widget if data is null
              }
              final String tourId = data['tourId'] ?? '';
              final Booking booking = Booking(
                id: data['id'] ?? '',
                tourId: tourId,
                name: data['name'] ?? '',
                email: data['email'] ?? '',
                number: data['number'] ?? '',
                chooseDate: _parseDate(data['chooseDate']),
                depTime: _parseDate(data['depTime']),
                person: data['person'] ?? 0,
                hotelType: data['hotelType'] ?? '',
                rooms: data['rooms'] ?? 0,
                total: data['total'] ?? 0,
                userId: data['userId'] ?? '',
                status: BookingStatus.values[data['status']] ?? BookingStatus.pending,
                isApproved: data['isApproved'] ?? false,
              );
              final tour = toursData.findByid(tourId);
              if (tour == null) {
                return SizedBox();
              }

              final userName = userNames[booking.userId] ?? 'Unknown User';

              return BookingItem(
                tour: tour,
                booking: booking,
                approveCallback: (bool newValue) {
                  approveBooking(booking.id, newValue);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class BookingItem extends StatelessWidget {
  final Tour tour;
  final Booking booking;
  final Function(bool) approveCallback;

  const BookingItem({
    required this.tour,
    required this.booking,
    required this.approveCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 95),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Details'),
              contentPadding: const EdgeInsets.all(15),
              children: [
                Text('Location: ${(tour.title).toUpperCase()}'),
                Text('Name: ${booking.name}'),
                Text('Email: ${booking.email}'),
                Text('Phone Number: ${booking.number}'),
                Text('Date: ${DateFormat('EEE , M/d/y').format(booking.chooseDate)}'),
                Text('Number of people: ${booking.person}'),
                if (booking.hotelType == '1') const Text('Hotel And Restaurant : 5 Star'),
                if (booking.hotelType == '2') const Text('Hotel And Restaurant : 4 Star'),
                if (booking.hotelType == '3') const Text('Hotel And Restaurant : 3 Star'),
                Text('Rooms: ${booking.rooms}'),
                Text('Total: ${booking.total}'),
                Text('Status: ${booking.status.name.toUpperCase()}'),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 4),
        child: Card(
          color: themeManager.themeMode == ThemeMode.light ? Colors.white : Colors.grey.shade900,
          elevation: 3,
          child: ListTile(
            title: Text(tour.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${booking.person} Persons'),
                Row(
                  children: [
                    Text('Approval: '),
                    Checkbox(
                      value: booking.isApproved,
                      onChanged: (bool? newValue) {
                        approveCallback(newValue ?? false);
                      },
                    ),
                  ],
                ),
                Text('Status: ${booking.status.name.toUpperCase()}'),
              ],
            ),
            trailing: Text('Total ${booking.total.toString()}'),
            leading: CircleAvatar(
              backgroundImage: tour.imageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(tour.imageUrl[0])
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
          ),
        ),
      ),
    );
  }
}
