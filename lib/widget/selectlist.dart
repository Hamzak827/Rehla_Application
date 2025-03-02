import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Rehla/providers/tours.dart';
import 'package:Rehla/widget/issouth.dart';
import 'package:Rehla/widget/tour_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/tour.dart';
import '../screens/tours/favourite_screen.dart';
import 'isnorth.dart';

class SelectList extends StatefulWidget {
  final List<Tour> fTours;
  final String searchQuery;
  final RangeValues priceRange;
  final RangeValues dayRange;

  const SelectList(this.fTours, this.searchQuery, this.priceRange, this.dayRange, {Key? key}) : super(key: key);

  @override
  _SelectListState createState() => _SelectListState();
}

class _SelectListState extends State<SelectList> {
  late List<Tour> filteredTours;

  List<String> items = [
    "All",
    "Northern",
    "Southern",
    "Favourite",
  ];
  int current = 0;
  late bool _isLoading;
  late Tours _tourData;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _tourData = Provider.of<Tours>(context, listen: false);
    _fetchTours();
    filteredTours = widget.fTours;
  }

  @override
  void didUpdateWidget(SelectList oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredTours = widget.fTours;
  }

  Future<void> _fetchTours() async {
    try {
      await _tourData.fetchTours();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Error fetching tours: $error');
    }
  }

  Future<void> _fetchLikedTours() async {
    try {
      await _tourData.getLikedTours(FirebaseAuth.instance.currentUser!.email!);
    } catch (error) {
      // Handle error
      print('Error fetching liked tours: $error');
    }
  }

  void _updateLikedTours() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchLikedTours();
    setState(() {
      _isLoading = false;
    });
  }

  List<Tour> searchTours(List<Tour> tours, String query) {
    if (query.isEmpty) {
      return tours; // Return all tours if the query is empty
    } else {
      // Filter tours whose title contains the search query
      return tours.where((tour) => tour.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  List<Tour> filterToursByPriceAndDay(List<Tour> tours, RangeValues priceRange, RangeValues dayRange) {
    return tours.where((tour) => tour.price >= priceRange.start && tour.price <= priceRange.end && tour.duration >= dayRange.start && tour.duration <= dayRange.end).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Tour> filteredTours = widget.fTours;

    // Apply search filter
    filteredTours = searchTours(widget.fTours, widget.searchQuery);

    // Apply price and day range filter
    filteredTours = filterToursByPriceAndDay(filteredTours, widget.priceRange, widget.dayRange);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            current = index;
                          });
                          if (index == 3) {
                            _updateLikedTours();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.all(5),
                          width: 72,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: current == index
                                ? BorderRadius.circular(15)
                                : BorderRadius.circular(10),
                            border: current == index
                                ? Border.all(
                                    color: themeManager.themeMode == ThemeMode.light
                                        ? Colors.black87
                                        : Colors.white,
                                    width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              items[index],
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: themeManager.themeMode == ThemeMode.light
                                      ? current == index
                                          ? Colors.black
                                          : Colors.grey
                                      : current == index
                                          ? Colors.white
                                          : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: current == index,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                color: themeManager.themeMode == ThemeMode.light
                                    ? Colors.black
                                    : Colors.white,
                                shape: BoxShape.circle),
                          )),
                    ],
                  );
                },
              ),
            ),
          ),
          _isLoading
              ? _buildLoadingIndicator()
              : current == 0
                  ? TourWidget(filteredTours, onUpdate: _updateLikedTours)
                  : current == 1
                      ? TourWidget(_tourData.isNorth, onUpdate: _updateLikedTours)
                      : current == 2
                          ? TourWidget(_tourData.isSouth, onUpdate: _updateLikedTours)
                          : current == 3
                              ? TourWidget(_tourData.likedTours, onUpdate: _updateLikedTours)
                              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              title: Container(
                width: double.infinity,
                height: 100,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}


