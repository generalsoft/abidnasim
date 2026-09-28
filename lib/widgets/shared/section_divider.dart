import 'package:flutter/material.dart';

/// Thin horizontal rule used to separate major page sections.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
