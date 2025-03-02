import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'services/add_tour.dart';
import '../../../providers/tour.dart';
import '../../../providers/tours.dart';

class AdminHome extends StatefulWidget {
  static const routeName = '/admin_home-screen';

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Future<int> _getTotalTours() async {
    final snapshot = await FirebaseFirestore.instance.collection('tours').get();
    return snapshot.size;
  }

  Future<int> _getTotalBookings() async {
    final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
    return snapshot.size;
  }

  Future<int> _getTotalUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users')
      .where('isAdmin', isEqualTo: false) // Exclude admin users
      .get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Color.fromRGBO(61,115,127,4),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'D A S H B O A R D',
          style: GoogleFonts.roboto(
            color: themeManager.themeMode == ThemeMode.light
                ? Colors.black
                : Colors.white,
            fontSize: 26,
          ),
        ),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First row with two card boxes
          Container(
            height: screenHeight * 0.25, // 25% of screen height
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalTours(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Error fetching data'),
                          ),
                        );
                      }
                      final totalTours = snapshot.data ?? 0;
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.tour, size: 50, color: Colors.blue),
                              SizedBox(height: 8.0),
                              Text(
                                'Total Tours',
                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                '$totalTours',
                                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalBookings(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Error fetching data'),
                          ),
                        );
                      }
                      final totalBookings = snapshot.data ?? 0;
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.book_online, size: 50, color: Colors.green),
                              SizedBox(height: 8.0),
                              Text(
                                'Total Bookings',
                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                '$totalBookings',
                                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Tours list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('tours').snapshots(),
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
                    final List<dynamic> imageUrl = data['imageUrl'] ?? [];
                    final String title = data['title'] ?? '';
                    final int price = data['price'] ?? 0;

                    return Bounce(
                      duration: const Duration(milliseconds: 95),
                      onPressed: () {
                        // Add navigation logic here if needed
                      },
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("Price: $price"),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              imageUrl.isNotEmpty ? imageUrl[0] : '',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
