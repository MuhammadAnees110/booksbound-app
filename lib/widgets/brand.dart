import 'package:flutter/material.dart';

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'BooksBound',
      style: (Theme.of(
        context,
      ).textTheme.headlineLarge)?.copyWith(fontFamily: 'UncialAntiqua'),
    );
  }
}
