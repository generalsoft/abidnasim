import 'package:flutter/material.dart';

/// Filled, high-emphasis button used for primary calls to action.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryButton({required this.label, required this.icon, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Outlined, low-emphasis button used for secondary calls to action.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SecondaryButton({required this.label, required this.icon, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Outlined button styled specifically for the contact section's
/// email / phone / WhatsApp actions.
class ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ContactButton({required this.icon, required this.label, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
