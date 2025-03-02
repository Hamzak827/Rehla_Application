
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tours.dart';
import '../../widget/tour_widget.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  static const routeName = '/favourite-s';

  @override
  Widget build(BuildContext context) {
    final tourData = Provider.of<Tours>(context);

    return TourWidget(tourData.likedTours, onUpdate: () {
      // Handle update here, such as fetching liked tours again
      tourData.getLikedTours(FirebaseAuth.instance.currentUser!.email!);
    });
  }
}






