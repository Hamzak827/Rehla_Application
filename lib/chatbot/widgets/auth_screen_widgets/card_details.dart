import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

class CardDetails extends StatelessWidget {
  const CardDetails({super.key, required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 0.3, color: const Color.fromARGB(137, 255, 255, 255)),
          borderRadius: const BorderRadius.all(Radius.circular(36)),
          color: const Color.fromARGB(39, 255, 255, 255)),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(),
          child: Container(
            padding: const EdgeInsets.all(8),
            width: 364,
            height: 90,
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    border: Border.all(width: .5, color: Colors.black),
                    borderRadius: BorderRadius.circular(32),
                    color: const Color.fromARGB(167, 0, 0, 0),
                  ),
                  child: GlowIcon(
                    offset: Offset.zero,
                    blurRadius: 30,
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width - 190,
                    child: Text(
                      style: const TextStyle(color: Colors.white),
                      title,
                      softWrap: true,
                      maxLines: 2,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
