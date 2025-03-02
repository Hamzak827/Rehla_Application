import 'package:flutter/material.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({
    super.key,
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(157, 255, 255, 255),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(182, 255, 255, 255),
            ),
             textAlign: TextAlign.right,
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(221, 255, 255, 255),
                fontWeight: FontWeight.w500),
                 textAlign: TextAlign.left,
          )
        ],
      ),
    );
  }
}
