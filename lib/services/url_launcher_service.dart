// -----------------------------------------------------------------------------
// BROWSER URL LAUNCHER (PLACEHOLDER)
// -----------------------------------------------------------------------------
//
// We deliberately don't use dart:html here.
// Regional site cards and contact buttons call this; real browser
// navigation gets wired in during a follow-up step.
// -----------------------------------------------------------------------------

void openUrl(String url) {
  // TODO: Connect browser navigation.
  //
  // Known callers today:
  // - Presence cards -> https://nasim.pk / .us / .ae
  // - Contact section -> mailto:, https://wa.me/...
}
