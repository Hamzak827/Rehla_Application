// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, unused_local_variable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';



import '../../main.dart';

import '../../providers/booking.dart';

import '../../providers/bookings.dart';
import '../../providers/tour.dart';
import 'package:uuid/uuid.dart';





class BookTourScreen extends StatefulWidget {



 final Booking? booking;

  final String id;
  final List date;
  final int duration;
  final List famousPoints;
  final List famousResturant;
  final List imageUrl;
  final bool isFav;
  final bool isNorth;
  final bool isSouth;
  final String location;
  final int price;
  final String title;
 

  BookTourScreen({Key? key, required this.id, required this.date, required this.duration, required this.famousPoints, required this.famousResturant, required this.imageUrl, required this.isFav, required this.isNorth, required this.isSouth, required this.location, required this.price, required this.title, this.booking});

  @override
  State<BookTourScreen> createState() => _BookTourScreenState();
}





class _BookTourScreenState extends State<BookTourScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime _selectDate = DateTime(0);
  
  int person = 0;
  int? total;
  String? value;
  //String? value1 = 'Standard';
  String? value1;
  int? categoryPrice = 0;
  int? rooms;
  bool flag = true;
  
  String? tourid;
   // Flag to differentiate create and update


    @override
  void initState() {
    super.initState();
    print('Tour Price: ${widget.price}');
       if (widget.booking != null) {
       
      // Populate the form fields with existing booking data if it exists
      populateFormFields(widget.booking!);
      //total = widget.booking!.total;
       // Calculate the base price of the tour (excluding hotel charges)
  int baseTourPrice = widget.price * person;
  
  // Calculate the total amount including both the base tour price and hotel charges
  total = baseTourPrice + categoryPrice!;
     
    } else {
      fetchUserName(); // Fetch user name for new booking
    }
  
  
  }


  



  

    void populateFormFields(Booking booking) {
    // Populate form fields with existing booking data
    nameController.text = booking.name;
    emailController.text = booking.email;
    phoneController.text = booking.number;
    _selectDate = booking.chooseDate;
    person = booking.person;
    value1 = booking.hotelType;
    total = booking.total;
    
    

    
      tourid=widget.booking!.tourId;// Also set the tourId for consistency

      // Calculate categoryPrice based on hotelType if needed
  if (value1 == '5 Star') {
    categoryPrice = 5000;
  } else if (value1 == '4 Star') {
    categoryPrice = 3000;
  } else if (value1 == '3 Star') {
    categoryPrice = 0;
  }
  }




 

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userEmail != null) {
        setState(() {
          nameController.text = userDoc['name'];
          emailController.text = userEmail;
        });
      }
    }
  }

Future<void> submitData() async {
  if (formKey.currentState!.validate()) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    total = person * (widget.price + categoryPrice!);
    if (person % 2 == 0) {
      rooms = person ~/ 2;
    } else {
      rooms = (person / 2 + 0.5).toInt();
    }

    String bookingId = widget.booking?.id ?? Uuid().v4(); // Use existing ID if updating
    String tourid=widget.booking?.tourId ??widget.id;

    final newBooking = Booking(
      id: bookingId,
      tourId: tourid,
      name: nameController.text,
      email: emailController.text,
      number: phoneController.text,
      chooseDate: _selectDate,
      depTime: _selectDate,
      person: person,
      hotelType: value1!,
      rooms: rooms!,
      total: total!,
      userId: userId,
    );

    // Check if the selected date is available for the tour
    List<int> availableDates = widget.date.cast<int>();
    if (!availableDates.contains(_selectDate.day)) {
      String availableDatesStr = availableDates.map((day) => day.toString()).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected date is not available for booking. Available dates: $availableDatesStr'),
          duration: Duration(seconds: 5),
        ),
      );
      return; // Exit the method if selected date is not available
    }

    try {
      if (widget.booking == null) {
        // Create new booking
        await Provider.of<Bookings>(context, listen: false)
            .addBooking(newBooking);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking successful!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Update existing booking
        await Provider.of<Bookings>(context, listen: false)
            .updateBooking(widget.booking!.id,newBooking);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}



void weekDay(Tour selectTour) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: themeManager.themeMode == ThemeMode.light
                ? Colors.white
                : Colors.black,
          ),
        ),
        child: SfDateRangePicker(
          view: DateRangePickerView.month,
          selectionMode: DateRangePickerSelectionMode.single,
          minDate: DateTime.now(),
          maxDate: DateTime.now().add(const Duration(days: 30)),
          selectableDayPredicate: (DateTime date) {
            // Custom logic for allowed weekdays (modify as needed)
            return selectTour.date.contains(date.weekday);
          },
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is DateTime) {
              setState(() => _selectDate = args.value);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  bool isEmailValid(String email) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(email);
  }





  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  controller: nameController,
                  autofocus: false,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.person_outlined),
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a Email';
                    } else if (!isEmailValid(value)) {
                      return 'Please enter a valid Email';
                    } else {
                      return null;
                    }
                  },
                  controller: emailController,
                  // initialValue: currentUser!.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: 'Email',
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
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a Phone Number';
                    } else if (value.length < 11 || value.length > 11) {
                      return 'Please enter a 11 Digit Phone Number';
                    } else {
                      return null;
                    }
                  },
                  controller: phoneController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.call),
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
            Padding(
  padding: const EdgeInsets.all(6.0),
  child: TextFormField(
    validator: (value) {
      if (_selectDate == DateTime(0)) {
        return 'Please select a Date';
      } else {
        return null;
      }
    },
    readOnly: true,
    onTap: () async {
      // Show date picker and await for user's selection
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectDate == DateTime(0) ? DateTime.now() : _selectDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)), // Allow selection within a year
      );

      // Update the selected date if the user picked a date
      if (pickedDate != null) {
        setState(() {
          _selectDate = pickedDate;
        });
      }
    },
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      suffixIcon: IconButton(
        onPressed: () async {
          // Show date picker and await for user's selection
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectDate == DateTime(0) ? DateTime.now() : _selectDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365)), // Allow selection within a year
          );

          // Update the selected date if the user picked a date
          if (pickedDate != null) {
            setState(() {
              _selectDate = pickedDate;
            });
          }
        },
        icon: const Icon(Icons.calendar_month_outlined),
      ),
      hintText: _selectDate == DateTime(0)
          ? 'Choose Date'
          : '${DateFormat.yMd().format(_selectDate)} - ${DateFormat.yMd().format(_selectDate.add(Duration(days: widget.duration)))}',
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




              Padding(
                padding: const EdgeInsets.all(6.0),
                child:  DropdownButtonFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
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
                validator: (value) {
                  if (value == null) {
                    return 'Please Select Hotel';
                  }
                  return null;
                },
                isDense: true,
                hint: value1 == null
                    ? const Text('Select Hotel Category')
                    : null,
                isExpanded: true,
                value: value1,
                items: [
                  DropdownMenuItem(
                    value: '5 Star',
                    child: Text(
                      '5 Star',
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        color: themeManager.themeMode == ThemeMode.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: '4 Star',
                    child: Text(
                      '4 Star',
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        color: themeManager.themeMode == ThemeMode.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: '3 Star',
                    child: Text(
                      '3 Star',
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        color: themeManager.themeMode == ThemeMode.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    value1 = value as String; // Update value1 to the selected text value
                    if (value1 == '5 Star') {
                      categoryPrice = 5000;
                    } else if (value1 == '4 Star') {
                      categoryPrice = 3000;
                    } else if (value1 == '3 Star') {
                      categoryPrice = 0;
                    }
                    total = person * (widget.price + categoryPrice!);
                  });
                },
              ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextFormField(
                  validator: (value) {
                    if (person == 0) {
                      return 'Please Select Person';
                    } else {
                      return null;
                    }
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '   $person Person ',
                          style: GoogleFonts.lato(
                            fontSize: 17,
                            color: themeManager.themeMode == ThemeMode.light
                                ? Colors.grey.shade800
                                : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              if (person > 0) {
                                person -= 1;
                              }
                              setState(() {});
                            },
                            icon: const Icon(Icons.remove)),
                        IconButton(
                            onPressed: () {
                              if (person < 10) {
                                person += 1;
                              }

                              setState(() {});
                            },
                            icon: const Icon(Icons.add)),
                      ],
                    ),
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
              if (person % 2 == 0)
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text('  Rooms Alot : ${person ~/ 2}'),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text('  Rooms Alot : ${(person / 2 + 0.5).toInt()}'),
                ),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 15),
                    child: Text(
                        'Total : ${person * (widget.price + categoryPrice!)}',
                        style: GoogleFonts.lato(
                          fontSize: 25,
                        )),
                  ),
                ],
              ),
           Center(
  child: OutlinedButton(
    style: ButtonStyle(
      fixedSize: MaterialStateProperty.all(Size(250, 50)),
    ),
    onPressed: () async {
      if (formKey.currentState!.validate()) {
        bool confirmed = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: themeManager.themeMode == ThemeMode.light
                  ? Colors.white
                  : Colors.grey.shade900,
              title: Text(widget.booking == null ? 'Book Now' : 'Update Booking'),
              content: Text(widget.booking == null
                  ? 'Are you sure you want to book this tour?'
                  : 'Are you sure you want to update this booking?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false if not confirmed
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true if confirmed
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );

        if (confirmed != null && confirmed) {
          await submitData(); // Submit data if confirmed
        }
      }
    },
    child: Text(widget.booking == null ? 'Book Now' : 'Save Changes'),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}