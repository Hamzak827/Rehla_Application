import 'dart:ui';
import 'package:flutter/material.dart';

class DisplayContainer extends StatelessWidget {
  const DisplayContainer({
    super.key,
    required this.title,
    required this.desc,
    required this.name,
    required this.imageAddress,
    required this.onPressed,
  });

  final String title;
  final String desc;
  final String name;
  final String imageAddress;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 273,
      decoration: BoxDecoration(
        color: Color.fromRGBO(66, 66, 66, 1),
        border: Border.all(
          color: const Color.fromARGB(195, 125, 123, 123),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          imageAddress,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  desc,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(185, 255, 255, 255),
                    fontFamily: 'Open Sans',
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 183),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset.zero,
                      )
                    ],
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    onPressed: onPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Start $name",
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Open sans",
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
