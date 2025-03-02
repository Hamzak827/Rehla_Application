import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name;
  String uid;
  String email;
  String phoneNumber;
  String address;
  String image;
  final bool isAdmin; 

  UserModel({
    required this.name,
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.image,
    this.isAdmin = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'uid': uid,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'image_url':image,
        'isAdmin': isAdmin,
      };

  static UserModel fromJson(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      name: snap['name'],
      uid: snap['uid'],
      email: snap['email'],
      phoneNumber: snap['phone_number'],
      address: snap['address'],
      image: snap['image_url'],
      isAdmin: snap['isAdmin']
    );
  }

   factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      isAdmin: data['isAdmin'] ?? false, address: data['address'], email: data['email'] , image: data['image_url'], name: data['name'], phoneNumber: data['phone_number'], uid: data['uid'],
    );
  }
}
