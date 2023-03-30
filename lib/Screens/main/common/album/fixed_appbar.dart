import 'dart:math';

import 'package:flutter/material.dart';

class FixedAppBar extends StatelessWidget {
  const FixedAppBar({
    Key? key,
    required this.titleOpacity,
    required this.title,
  }) : super(key: key);

  final double titleOpacity;
  final String title;

  @override
  Widget build(BuildContext context) {
    final double opacity = min(max(titleOpacity, 0), 1);

    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              padding: const EdgeInsets.only(left: 10),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          const Center(child: SizedBox(width: 30)),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withOpacity(opacity), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
