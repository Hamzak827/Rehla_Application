import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;

final Provider<CachedNetworkImageProvider> profileImageProvider = Provider((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  final defaultImageUrl = 'assets/avatar.png'; // Replace with your default image URL

  if (currentUser != null && currentUser.photoURL != null && currentUser.photoURL!.isNotEmpty) {
    return CachedNetworkImageProvider(currentUser.photoURL!);
  } else {
    // Return a CachedNetworkImageProvider with the default image URL
    return CachedNetworkImageProvider(defaultImageUrl);
  }
});
