import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<Locale> getIosScreenshotLanguages() {
  Set<String> seen = {};
  // return [Locale('en', 'US')];
  // return [Locale('en', 'US'), Locale('ru')];
  return AppLocalizations.supportedLocales
      .map((loc) => loc.languageCode)
      .where((code) => seen.add(code))
      .map((code) => _preferredCountryCode[code])
      .nonNulls
      .toList();
}

// where there are more than one country per language code,
// selection is made in favour of larger population.
const _preferredCountryCode = {
  'ar': Locale('ar', 'SA'),
  'ca': Locale('ca'),
  'cs': Locale('cs'),
  'da': Locale('da'),
  'de': Locale('de', 'DE'),
  'el': Locale('el'),
  'en': Locale('en', 'US'),
  'es': Locale('es', 'MX'),
  'fi': Locale('fi'),
  'fr': Locale('fr', 'FR'),
  'he': Locale('he'),
  'hi': Locale('hi'),
  'hr': Locale('hr'),
  'hu': Locale('hu'),
  'id': Locale('id'),
  'it': Locale('it'),
  'ja': Locale('ja'),
  'ko': Locale('ko'),
  'ms': Locale('ms'),
  'nl': Locale('nl', 'NL'),
  'no': Locale('no'),
  'pl': Locale('pl'),
  'pt': Locale('pt', 'BR'),
  'ro': Locale('ro'),
  'ru': Locale('ru'),
  'sk': Locale('sk'),
  'sv': Locale('sv'),
  'th': Locale('th'),
  'tr': Locale('tr'),
  'uk': Locale('uk'),
  'vi': Locale('vi'),
  'zh': Locale('zh', 'Hans'),
};
