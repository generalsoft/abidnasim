import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../../services/url_launcher_service.dart';

/// A small inline text link: underlined, brightens on hover, opens in a new tab.
///
/// Shared by the footer credit and the "About" section's regional link. The
/// caller passes the base [style] — its colour is the resting colour; the widget
/// only brightens it and deepens the underline to show hover.
class InlineLink extends StatefulWidget {
  final String label;
  final String url;

  /// Resting text style. Its colour is used as-is until the pointer arrives.
  final TextStyle style;

  /// Sent as the analytics `link_name` parameter, so one event covers every
  /// inline link on the page.
  final String analyticsName;

  const InlineLink({
    required this.label,
    required this.url,
    required this.style,
    required this.analyticsName,
    super.key,
  });

  @override
  State<InlineLink> createState() => _InlineLinkState();
}

class _InlineLinkState extends State<InlineLink> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final resting = widget.style.color ?? Colors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: () {
          trackEvent(
            'link_click',
            parameter1Name: 'link_name',
            parameter1Value: widget.analyticsName,
            parameter2Name: 'destination_url',
            parameter2Value: widget.url,
          );

          openUrl(widget.url);
        },
        child: Text(
          widget.label,
          style: widget.style.copyWith(
            color: resting.withValues(alpha: hovering ? 0.95 : resting.a),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white.withValues(alpha: hovering ? 0.55 : 0.26),
          ),
        ),
      ),
    );
  }
}
