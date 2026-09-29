import 'package:flutter/material.dart';

import '../constants/firebase_config.dart';
import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/contact_service.dart';

/// The contact form: name / email / message, validated locally and sent to
/// Firestore through [ContactSubmitter] (see `services/contact_service.dart`).
///
/// It never throws and never navigates away: every outcome becomes an inline
/// message, so a flaky network or a build without Firebase config can't take the
/// page down. When there is no config at all, the fields render disabled with a
/// note pointing at the email / WhatsApp buttons above.
class ContactForm extends StatefulWidget {
  /// Injection seam: defaults to the real Firestore call, so tests can drive the
  /// success / failure paths without a network.
  final ContactSubmitter submit;

  /// Overrides the "is this build configured?" check. Left null in the app so
  /// [FirebaseConfig.isConfigured] decides; tests set it explicitly.
  final bool? enabled;

  const ContactForm({this.submit = submitContactMessage, this.enabled, super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  bool _sending = false;

  /// Null until the first submission, so no status line is shown on load.
  ContactStatus? _status;

  bool get _enabled => widget.enabled ?? FirebaseConfig.isConfigured;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Double-taps and Enter-key repeats are cheap to ignore, and re-running the
    // request would create a duplicate document.
    if (_sending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _sending = true;
      _status = null;
    });

    final result = await widget.submit(
      ContactSubmission(
        name: _name.text.trim(),
        email: _email.text.trim(),
        message: _message.text.trim(),
        source: 'abidnasim-com-app',
        locale: AppLocalizations.of(context).locale.languageCode,
        pageUrl: Uri.base.toString(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _sending = false;
      _status = result.status;
    });

    if (result.isSuccess) {
      _name.clear();
      _email.clear();
      _message.clear();
    }

    trackEvent(
      'contact_form_submit',
      parameter1Name: 'result',
      parameter1Value: result.isSuccess ? 'success' : 'failure',
      parameter2Name: 'detail',
      parameter2Value: _analyticsDetail(result),
    );
  }

  /// Analytics gets the technical reason, truncated to GA4's parameter limit.
  String _analyticsDetail(ContactResult result) {
    final detail = result.detail ?? result.status.name;
    return detail.length <= 100 ? detail : detail.substring(0, 100);
  }

  void _handleFieldChanged(String value) {
    if (_status == null) return;
    // Any further typing invalidates the previous outcome's message.
    setState(() => _status = null);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final enabled = _enabled;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF101217),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('contact_form_heading'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 22),
            if (!enabled) ...[
              _StatusLine(status: ContactStatus.notConfigured, message: t('contact_form_unavailable')),
              const SizedBox(height: 22),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final nameField = _ContactField(
                  controller: _name,
                  label: t('contact_form_name'),
                  enabled: enabled,
                  maxLength: contactNameMaxLength,
                  textInputAction: TextInputAction.next,
                  onChanged: _handleFieldChanged,
                  validator: (value) => _validateRequired(value, t),
                );

                final emailField = _ContactField(
                  controller: _email,
                  label: t('contact_form_email'),
                  enabled: enabled,
                  maxLength: contactEmailMaxLength,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: _handleFieldChanged,
                  validator: (value) => _validateEmail(value, t),
                );

                // Name and email sit side by side once there's room for it.
                if (constraints.maxWidth < 640) {
                  return Column(children: [nameField, const SizedBox(height: 18), emailField]);
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: nameField),
                    const SizedBox(width: 18),
                    Expanded(child: emailField),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _ContactField(
              controller: _message,
              label: t('contact_form_message'),
              enabled: enabled,
              maxLength: contactMessageMaxLength,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              onChanged: _handleFieldChanged,
              validator: (value) => _validateRequired(value, t),
            ),
            const SizedBox(height: 22),
            _SubmitButton(
              label: t('contact_form_submit'),
              sendingLabel: t('contact_form_sending'),
              sending: _sending,
              onPressed: enabled ? _handleSubmit : null,
            ),
            if (_status != null) ...[
              const SizedBox(height: 20),
              _StatusLine(status: _status!, message: _messageFor(_status!, t)),
            ],
          ],
        ),
      ),
    );
  }

  /// Localized copy for an outcome. Rejections and unreachable requests read the
  /// same to a visitor — the difference only matters in analytics.
  String _messageFor(ContactStatus status, String Function(String) t) {
    switch (status) {
      case ContactStatus.success:
        return t('contact_form_success');
      case ContactStatus.notConfigured:
        return t('contact_form_unavailable');
      case ContactStatus.rejected:
      case ContactStatus.unreachable:
        return t('contact_form_error');
    }
  }

  String? _validateRequired(String? value, String Function(String) t) {
    if (value == null || value.trim().isEmpty) return t('contact_form_required');
    return null;
  }

  String? _validateEmail(String? value, String Function(String) t) {
    final required = _validateRequired(value, t);
    if (required != null) return required;
    if (!isValidContactEmail(value!.trim())) return t('contact_form_invalid_email');
    return null;
  }
}

/// A themed text field: dark fill, subtle border, and no character counter (the
/// `maxLength` is data hygiene, not something a visitor needs to watch).
class _ContactField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _ContactField({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
    );

    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLength: maxLength,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
      onChanged: onChanged,
      validator: validator,
      // Errors appear as soon as a field is touched, so the visitor isn't
      // surprised by them only after pressing send.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: _errorColor)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: _errorColor)),
        errorStyle: const TextStyle(color: _errorColor),
      ),
    );
  }
}

/// Wide, filled submit button matching the hero's primary CTA styling, with an
/// inline spinner while the request is in flight.
class _SubmitButton extends StatelessWidget {
  final String label;
  final String sendingLabel;
  final bool sending;
  final VoidCallback? onPressed;

  const _SubmitButton({
    required this.label,
    required this.sendingLabel,
    required this.sending,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sending)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
          else
            const Icon(Icons.send_rounded, size: 17),
          const SizedBox(width: 10),
          Text(sending ? sendingLabel : label),
        ],
      ),
    );
  }
}

/// Inline outcome of a submission: success, or one of the two failure flavours
/// (plus the "this build has no Firebase config" note).
class _StatusLine extends StatelessWidget {
  final ContactStatus status;
  final String message;

  const _StatusLine({required this.status, required this.message});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = _appearance;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) get _appearance {
    switch (status) {
      case ContactStatus.success:
        return (Icons.check_circle_outline_rounded, _successColor);
      case ContactStatus.notConfigured:
        return (Icons.info_outline_rounded, _noticeColor);
      case ContactStatus.rejected:
      case ContactStatus.unreachable:
        return (Icons.error_outline_rounded, _errorColor);
    }
  }
}

const Color _successColor = Color(0xFF7BD88F);
const Color _noticeColor = Color(0xFFE0C070);
const Color _errorColor = Color(0xFFFF8A8A);
