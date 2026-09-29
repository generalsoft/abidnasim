import 'package:flutter/material.dart';

import '../constants/site_constants.dart';
import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/url_launcher_service.dart';
import 'contact_form.dart';
import 'shared/buttons.dart';
import 'shared/content_section.dart';

/// "Contact" section: the message form, plus email / phone / WhatsApp as the
/// direct channels (and as the fallback when the form can't be used).
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(
      eyebrow: t('contact_eyebrow'),
      title: t('contact_title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('contact_intro'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.58), fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              ContactButton(
                icon: Icons.email_outlined,
                label: t('contact_email'),
                onTap: () {
                  trackEvent('contact_click', parameter1Name: 'contact_method', parameter1Value: 'email');
                  openUrl('mailto:${SiteConstants.email}');
                },
              ),
              ContactButton(
                icon: Icons.phone_outlined,
                label: t('contact_phone'),
                onTap: () {
                  trackEvent('phone_click', parameter1Name: 'contact_method', parameter1Value: 'phone');
                  openUrl('tel:${SiteConstants.phoneLink}');
                },
              ),
              ContactButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: t('contact_whatsapp'),
                onTap: () {
                  trackEvent('whatsapp_click', parameter1Name: 'contact_method', parameter1Value: 'whatsapp');
                  openUrl('https://wa.me/${SiteConstants.whatsappLink}');
                },
              ),
            ],
          ),
          const SizedBox(height: 44),
          const ContactForm(),
        ],
      ),
    );
  }
}
