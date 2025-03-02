import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Tour with ChangeNotifier {
  final String id;
  final String title;
  final String location;
  final int price;
  final List<String> imageUrl;
  final List<int> date;
  final List<String> famousResturant;
  final List<String> famousPoints;
  final int duration;
  bool isFav;
  bool isSouth;
  bool isNorth;

  Tour({
    required this.famousResturant,
    required this.famousPoints,
    required String? id, 
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.date,
    required this.duration,
    this.isNorth = false,
    this.isFav = false,
    this.isSouth = false,
  }): id = id ?? Uuid().v4();

  void toggleFavoriteStatus() {
    isFav = !isFav;
    notifyListeners();
  }

  // Convert Tour instance to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'famousResturant': famousResturant,
      'famousPoints': famousPoints,
      'id': id,
      'title': title,
      'location': location,
      'price': price,
      'imageUrl': imageUrl,
      'date': date,
      'duration': duration,
      'isNorth': isNorth,
      'isFav': isFav,
      'isSouth': isSouth,
    };
  }

  // Create Tour instance from Firestore document
  factory Tour.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Tour(
      famousResturant: List<String>.from(data['famousResturant']),
      famousPoints: List<String>.from(data['famousPoints']),
      id: doc.id,
      title: data['title'],
      location: data['location'],
      price: data['price'],
      imageUrl: List<String>.from(data['imageUrl']),
      date: List<int>.from(data['date']),
      duration: data['duration'],
      isNorth: data['isNorth'],
      isFav: data['isFav'],
      isSouth: data['isSouth'],
    );
  }

  static fromSnapshot(DocumentSnapshot<Object?> snapshot) {}
}
