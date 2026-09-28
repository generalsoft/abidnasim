import 'package:flutter/material.dart';

/// Shared layout shell for a page section: an eyebrow label, a large title,
/// and arbitrary content beneath it, centered with a max content width.
class ContentSection extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;

  const ContentSection({required this.eyebrow, required this.title, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width > 1100 ? 100 : 28, vertical: 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: TextStyle(
                  fontSize: width > 700 ? 58 : 42,
                  height: 1.02,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 54),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
