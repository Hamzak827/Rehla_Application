import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'booking.dart';

class Bookings with ChangeNotifier {
  late List<Booking> _bookings = [];

  List<Booking> get bookings {
    return [..._bookings];
  }

  // Fetch bookings from Firestore
  Future<void> fetchBookings() async {
    final List<Booking> loadedBookings = [];
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('bookings').get();
    for (var doc in snapshot.docs) {
      loadedBookings.add(Booking.fromMap(doc.data() as Map<String, dynamic>));
    }
    _bookings.clear();
    _bookings.addAll(loadedBookings);
    notifyListeners();
  }



  // Add booking to Firestore
  Future<void> addBooking(Booking newBooking) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(newBooking.id)
          .set(newBooking.toMap());
      _bookings.add(newBooking);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
 Future<void> fetchBookingsforusers(String userId) async {
    try {
      final List<Booking> loadedBookings = [];
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userid', isEqualTo: userId)
          .get();
      snapshot.docs.forEach((doc) {
        loadedBookings.add(Booking.fromMap(doc.data() as Map<String, dynamic>));
      });
      _bookings = loadedBookings;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // Update booking in Firestore
  Future<void> updateBooking(String id, Booking updatedBooking) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(id)
          .update(updatedBooking.toMap());
      final int index = _bookings.indexWhere((booking) => booking.id == id);
      if (index >= 0) {
        _bookings[index] = updatedBooking;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

    // Delete booking from Firestore
  Future<void> deleteBooking(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(id)
          .delete();
      _bookings.removeWhere((booking) => booking.id == id);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  


  
}

