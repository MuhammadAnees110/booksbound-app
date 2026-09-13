import 'package:flutter/material.dart';

Widget buildRatingStars({required double rating, double size = 14}) {
  List<Widget> stars = [];

  for (var i = 1; i <= 5; i++) {
    if (i <= rating.floor()) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: size));
    } else if (i - rating <= 0.5) {
      stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
    } else {
      stars.add(Icon(Icons.star_border, color: Colors.amber, size: size));
    }
  }

  return Row(children: stars);
}
