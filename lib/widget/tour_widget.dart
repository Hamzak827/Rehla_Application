import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Rehla/providers/tour.dart';
import 'package:Rehla/screens/tours/detail_screen.dart';
import '../main.dart';

class TourWidget extends StatefulWidget {
  final List<Tour> tours;
  final VoidCallback onUpdate;

  TourWidget(this.tours, {Key? key, required this.onUpdate}) : super(key: key);

  @override
  State<TourWidget> createState() => _TourWidgetState();
}

class _TourWidgetState extends State<TourWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a network request by delaying for a few seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerEffect();
    }

    if (widget.tours.isEmpty) {
      return Center(child: Text('No tours found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.tours.length,
      itemBuilder: (BuildContext context, int index) {
        final tour = widget.tours[index];

        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  id: tour.id,
                  date: tour.date,
                  duration: tour.duration,
                  famousPoints: tour.famousPoints,
                  famousResturant: tour.famousResturant,
                  imageUrl: tour.imageUrl,
                  isFav: tour.isFav,
                  isNorth: tour.isNorth,
                  isSouth: tour.isSouth,
                  location: tour.location,
                  price: tour.price,
                  title: tour.title,
                ),
              ),
            );
            if (result == true) {
              widget.onUpdate();
            }
          },
          child: Card(
            color: themeManager.themeMode == ThemeMode.light
                ? Colors.white
                : Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: CachedNetworkImage(
                        imageUrl: tour.imageUrl[0],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            color: Colors.black54,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              tour.title,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            ' Starting From Rs: ${tour.price.toString()}',
                            style: GoogleFonts.lato(
                              color: themeManager.themeMode == ThemeMode.light
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timelapse,
                              size: 18,
                              color: themeManager.themeMode == ThemeMode.light
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${tour.duration} Days ${tour.duration - 1} Nights',
                              style: GoogleFonts.lato(
                                color: themeManager.themeMode == ThemeMode.light
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            color: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 150,
                              height: 15,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

