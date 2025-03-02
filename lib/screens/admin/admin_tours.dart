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

class AdminTours extends StatefulWidget {
  static const routeName = '/admin_tours-screen';

  @override
  State<AdminTours> createState() => _AdminToursState();
}

class _AdminToursState extends State<AdminTours> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Color.fromRGBO(61,115,127,4),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'T O U R S',
          style: GoogleFonts.lato(
            color: themeManager.themeMode == ThemeMode.light
                ? Colors.black
                : Colors.white,
            fontSize: 26,
          ),
        ),
        // Remove the IconButton from here
      ),
      body: StreamBuilder(
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
                child: ListTile(
                  title: Text(title),
                  subtitle: Text("Price: $price"),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      imageUrl.isNotEmpty ? imageUrl[0] : '',
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: themeManager.themeMode == ThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                          onPressed: () {
                            print('Tour ID: ${document.id}');
                            Navigator.of(context).pushNamed(
                              AddTour.routeName,
                              arguments: document.id,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: themeManager.themeMode == ThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                          onPressed: () async {
                            await Provider.of<Tours>(context, listen: false).deleteTour(document.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddTour.routeName);
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(61,115,127,4),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Adjust the position of FAB
    );
  }
}