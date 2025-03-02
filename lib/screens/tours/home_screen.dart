import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Rehla/chatbot/model/chat_model.dart';
import 'package:Rehla/chatbot/provider/future_list_provider.dart';
import 'package:Rehla/chatbot/screens/start_screen.dart';

import 'package:Rehla/main.dart';import '../../widget/image_cursor.dart';
import '../../providers/tour.dart';
import '../../providers/tours.dart';
import '../../widget/selectlist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future _exitDialog(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure to close this app?"),
            content: Row(
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("No"),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text("Yes"),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final toursData = Provider.of<Tours>(context, listen: false);
      setState(() {
        fTours = toursData.tours; // Initialize with all tours
      });
    });
  }

  String _searchQuery = '';
  final tourData = Tours();

  bool isFilteted = false;
  RangeValues priceRange = const RangeValues(5000, 50000);
  RangeValues dayRange = const RangeValues(1, 10);
  final TextEditingController _textEditingController = TextEditingController();

  List<Tour> fTours = [];

  @override
  Widget build(BuildContext context) {
    final toursData = Provider.of<Tours>(context, listen: false);
    var tours = toursData.tours;

    List<Tour> filteredTours = toursData.search(_searchQuery, priceRange, dayRange);

    // List of image URLs and place names for famous Pakistani tourist places
    final List<Map<String, String>> places = [
      {
        'url': 'https://images.pexels.com/photos/3582124/pexels-photo-3582124.jpeg',
        'name': 'Hunza Valley'
      },
      {
        'url': 'https://images.pexels.com/photos/5059877/pexels-photo-5059877.jpeg',
        'name': 'Fairy Meadows'
      },
      {
        'url': 'https://images.pexels.com/photos/3685443/pexels-photo-3685443.jpeg',
        'name': 'Neelum Valley'
      },
      {
        'url': 'https://images.pexels.com/photos/3582125/pexels-photo-3582125.jpeg',
        'name': 'Skardu'
      },
      {
        'url': 'https://images.pexels.com/photos/268510/pexels-photo-268510.jpeg',
        'name': 'Naran Kaghan'
      },
      {
        'url': 'https://images.pexels.com/photos/165905/pexels-photo-165905.jpeg',
        'name': 'Murree'
      },
      // Add more places as needed
    ];

    setState(() {
      fTours = toursData.search(
        _textEditingController.text,
        priceRange,
        dayRange,
      );
    });

    return WillPopScope(
      onWillPop: () {
        _exitDialog(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Row(
            children: [
              const SizedBox(
                width: 15,
              ),
              Text(
                'Rehla',
                style: GoogleFonts.lato(
                  color: themeManager.themeMode == ThemeMode.light
                      ? Colors.white
                      : Colors.white,
                  fontSize: 27,
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Color.fromRGBO(61, 115, 127, 4),
        ),
       body: SingleChildScrollView(
      child: Container( // Wrap the Column with a Container
          width: double.infinity, // Give the Container a width
          child: Column(
             
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageCursor(
                places: [
                  {
                    'name': 'Swat',
                    'url': 'https://images.pexels.com/photos/14822617/pexels-photo-14822617.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  },
                  {
                    'name': 'Kashmir',
                    'url': 'https://images.pexels.com/photos/15388314/pexels-photo-15388314/free-photo-of-wooden-house-among-green-mountains.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  },
                  {
                    'name': 'Skardu',
                    'url': 'https://images.pexels.com/photos/19442078/pexels-photo-19442078/free-photo-of-resort-on-the-shore-of-lower-kachura-lake-at-the-foot-of-the-himalayas.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  },
                  {
                    'name': 'Naran Kaghan',
                    'url': 'https://images.pexels.com/photos/26976007/pexels-photo-26976007/free-photo-of-a-view-of-a-valley-and-mountains-from-a-hill.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  },
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          fTours = toursData.search(
                            _searchQuery,
                            priceRange,
                            dayRange,
                          );
                          if (_searchQuery.isEmpty) {
                            fTours = toursData.tours; // Reset to all tours if search query is empty
                          }
                        });
                      },
                      controller: _textEditingController,
                      autofocus: false,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            _textEditingController.clear();
                            setState(() {
                              _searchQuery = '';
                              fTours = toursData.search(
                                _searchQuery,
                                priceRange,
                                dayRange,
                              );
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: themeManager.themeMode == ThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        labelText: 'Search Tour',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: themeManager.themeMode == ThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromARGB(31, 175, 173, 173)),
                    child: TextButton.icon(
                        label: Text('Filter',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: themeManager.themeMode == ThemeMode.light
                                  ? Colors.black
                                  : Colors.white,
                            )),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, state) {
                                return SimpleDialog(
                                  backgroundColor:
                                      themeManager.themeMode == ThemeMode.light
                                          ? Colors.white
                                          : Colors.black,
                                  elevation: 10,
                                  contentPadding: const EdgeInsets.all(10),
                                  title: const Text('Filter'),
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Price'),
                                        Text(
                                            'Rs : ${priceRange.start.toInt()} - ${priceRange.end.toInt()}'),
                                        RangeSlider(
                                          values: priceRange,
                                          divisions: 9,
                                          onChanged: (value) {
                                            priceRange = value;
                                            state(() {});
                                          },
                                          min: 5000,
                                          max: 50000,
                                          activeColor: Color.fromRGBO(61, 115, 127, 4), // Light purple
                                          inactiveColor: Color.fromRGBO(216, 191, 216, 0.3), // Light purple with opacity
                                           // Light purple
                                        ),
                                        const Text('Days'),
                                        Text(
                                            '${dayRange.start.toInt()}  - ${dayRange.end.toInt()}'),
                                        RangeSlider(
                                          values: dayRange,
                                          divisions: 9,
                                          onChanged: (value) {
                                            dayRange = value;
                                            state(() {});
                                            setState(() {});
                                          },
                                          min: 1,
                                          max: 10,
                                          activeColor: Color.fromRGBO(61, 115, 127, 4), // Light purple
                                          inactiveColor: Color.fromRGBO(216, 191, 216, 0.3), // Light purple with opacity
                                           // Light purple
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                priceRange = const RangeValues(
                                                    5000, 50000);
                                                dayRange =
                                                    const RangeValues(1, 10);
                                                state(() {});
                                              },
                                              child: const Text('Reset'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  fTours = toursData.search(
                                                      _textEditingController.text,
                                                      priceRange,
                                                      dayRange);
                                                });

                                                Navigator.pop(context);
                                              },
                                              child: const Text('Apply Filter'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.format_list_bulleted_sharp,
                          size: 23,
                          color: themeManager.themeMode == ThemeMode.light
                              ? Colors.black
                              : Colors.white,
                        )),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              SelectList(
                fTours,
                _searchQuery,
                priceRange,
                dayRange,
              ),
            ],
          ),
          ),
        ),
  
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, StartScreen.routeName);
          },
          backgroundColor: const Color.fromRGBO(61, 115, 127, 4),
          child: Image.asset(
            'assets/robot_6062166.png',
            height: 32, // Adjust the height of the icon as needed
            width: 32,  // Adjust the width of the icon as needed
          ),
        ),
      ),
    );
  }
}







