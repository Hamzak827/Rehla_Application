import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './tour.dart';

class Tours with ChangeNotifier {
  late RangeValues priceRange;
  late RangeValues dayRange;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Tour> _likedTours = [];
  List<Tour> _filteredTours = [];
  

  List<Tour> get likedTours => _likedTours;
  List<Tour> get filteredTours => [..._filteredTours];
  


  Future<void> fetchTours() async {
    try {
      final tourSnapshots = await _db.collection('tours').get();
      _tours.clear();
      tourSnapshots.docs.forEach((doc) {
        _tours.add(Tour.fromFirestore(doc));
      });
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }



  Future<void> addTour(Tour tour) async {
    try {
      await _db.collection('tours').add(tour.toFirestore());
      await fetchTours(); // Refresh the list after adding
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTour(String id, Tour newTour) async {
    try {
      await _db.collection('tours').doc(id).set(newTour.toFirestore());
      await fetchTours(); // Refresh the list after updating
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteTour(String tourId) async {
    try {
      await _db.collection('tours').doc(tourId).delete();
      await fetchTours(); // Refresh the list after deleting
    } catch (error) {
      throw error;
    }
  }

  List<Tour> _tours = [];

  List<Tour> get tours {
    return [..._tours];
  }

  List<Tour> get favoriteItems {
    return _tours.where((tour) => tour.isFav).toList();
  }

  List<Tour> get isSouth {
    return _tours.where((element) => element.isSouth).toList();
  }

  List<Tour> get isNorth {
    return _tours.where((element) => element.isNorth).toList();
  }





Tour findByid(String id) {
  final toursWithId = _tours.where((element) => element.id == id).toList();
  print('Searching for tour with ID: $id');
  if (toursWithId.isEmpty) {
    print('Tour not found for ID: $id');
    return Tour(
      id: '',
      title: 'Tour Not Found',
      location: '',
      price: 0,
      imageUrl: [],
      date: [],
      famousResturant: [],
      famousPoints: [],
      duration: 0,
    );
  } else {
    print('Tour found for ID: $id');
    return toursWithId.first;
  }
}





  List<Tour> clearFilterTours() {
    return _filteredTours = [];
  }

  List<Tour> filterTours(
      String searchString, RangeValues priceRange, RangeValues dayRange) {
    final filteredTours = _tours.where((tour) {
      return tour.title
              .toLowerCase()
              .contains(searchString.toLowerCase().trim()) &&
          tour.price >= priceRange.start &&
          tour.price <= priceRange.end &&
          tour.duration >= dayRange.start &&
          tour.duration <= dayRange.end;
    }).toList();
    _filteredTours = filteredTours;
    return _filteredTours;
  }

  List<Tour> searchByPD(RangeValues priceRange, RangeValues dayRange) {
    final searchByPD = _tours.where((tour) {
      return tour.price >= priceRange.start &&
          tour.price <= priceRange.end &&
          tour.duration >= dayRange.start &&
          tour.duration <= dayRange.end;
    }).toList();
    return searchByPD;
  }

  List<Tour> search(
      String searchString, RangeValues priceRange, RangeValues dayRange) {
    if (searchString.isNotEmpty) {
      return filterTours(searchString, priceRange, dayRange);
    } else {
      return searchByPD(priceRange, dayRange);
    }
  }

  List<Tour> getToursByRegion(bool isNorth) {
  return _tours.where((tour) => isNorth ? tour.isNorth : tour.isSouth).toList();
}

 

   Future<void> getLikedTours(String userEmail) async {
    try {
      final likedTourSnapshots = await _db
          .collection('users-favourite-items')
          .doc(userEmail)
          .collection('place')
          .get();
      
      _likedTours.clear();
      likedTourSnapshots.docs.forEach((doc) {
        _likedTours.add(Tour.fromFirestore(doc));
      });
      // Notify listeners after fetching liked tours
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  



 


  // Other methods remain the same...
}
