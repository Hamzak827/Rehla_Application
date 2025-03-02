import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}


class Booking with ChangeNotifier {
  final String id;
  final String userId;
  final String tourId;
  final String name;
  final String email;
  final String number;
  final DateTime chooseDate;
  final DateTime depTime;
  final int person;
  final String hotelType;
  final int rooms;
  final int total;
  final BookingStatus status;
  final bool isApproved;


  Booking({
    required this.id,
    required this.userId,
    required this.tourId,
    required this.name,
    required this.email,
    required this.number,
    required this.chooseDate,
    required this.depTime,
    required this.person,
    required this.hotelType,
    required this.rooms,
    required this.total,
    this.status=BookingStatus.pending,
    this.isApproved=false,
  
  
  });

  // Convert a Booking object into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid':userId,
      'tourId': tourId,
      'name': name,
      'email': email,
      'number': number,
      'chooseDate': chooseDate.toIso8601String(),
      'depTime': depTime.toIso8601String(),
      'person': person,
      'hotelType': hotelType,
      'rooms': rooms,
      'total': total,
      'status':status.index,
      'isApproved':isApproved,
     
    };
  }

  // Create a Booking object from a map
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      tourId: map['tourId'],
      name: map['name'],
      email: map['email'],
      number: map['number'],
      chooseDate: DateTime.parse(map['chooseDate']),
      depTime: DateTime.parse(map['depTime']),
      person: map['person'],
      hotelType: map['hotelType'],
      rooms: map['rooms'],
      total: map['total'], userId: '',
      status: map['status'] != null ? BookingStatus.values[map['status']] : BookingStatus.pending,
      isApproved: map['isApproved'] ?? false, 
    );
  }
}

