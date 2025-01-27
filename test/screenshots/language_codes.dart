import 'dart:ui';

List<Locale> getAndroidScreenshotLanguages() {
  return _getScreenshotLanguages(_preferredCountryCodePlayStore);
}

List<Locale> getIosScreenshotLanguages() {
  return _getScreenshotLanguages(_preferredCountryCodeAppStore);
}

List<Locale> _getScreenshotLanguages(Map<String, Locale> preferredCodes) {
  return [Locale('en', 'US')];
  // return [Locale('en', 'US'), Locale('ru')];
  // Set<String> seen = {};
  // return AppLocalizations.supportedLocales
  //     .map((loc) => loc.languageCode)
  //     .where((code) => seen.add(code))
  //     .map((code) => preferredCodes[code])
  //     .nonNulls
  //     .toList();
}

// where there are more than one country per language code,
// selection is made in favour of larger population.
const _preferredCountryCodePlayStore = {
  'af': Locale('af'),
  'am': Locale('am'),
  'ar': Locale('ar'),
  'az': Locale('az', 'AZ'),
  'be': Locale('be'),
  'bg': Locale('bg'),
  'bn': Locale('bn', 'BD'),
  'ca': Locale('ca'),
  'cs': Locale('cs', 'CZ'),
  'da': Locale('da', 'DK'),
  'de': Locale('de', 'DE'),
  'el': Locale('el', 'GR'),
  'en': Locale('en', 'US'),
  'es': Locale('es', '419'),
  'et': Locale('et'),
  'eu': Locale('eu', 'ES'),
  'fa': Locale('fa'),
  'fi': Locale('fi', 'FI'),
  'fil': Locale('fil'),
  'fr': Locale('fr', 'FR'),
  'gl': Locale('gl', 'ES'),
  'hi': Locale('hi', 'IN'),
  'hr': Locale('hr'),
  'hu': Locale('hu', 'HU'),
  'hy': Locale('hy', 'AM'),
  'id': Locale('id'),
  'is': Locale('is', 'IS'),
  'it': Locale('it', 'IT'),
  'iw': Locale('iw', 'IL'),
  'ja': Locale('ja', 'JP'),
  'ka': Locale('ka', 'GE'),
  'km': Locale('km', 'KH'),
  'kn': Locale('kn', 'IN'),
  'ko': Locale('ko', 'KR'),
  'ky': Locale('ky', 'KG'),
  'lo': Locale('lo', 'LA'),
  'lt': Locale('lt'),
  'lv': Locale('lv'),
  'mk': Locale('mk', 'MK'),
  'ml': Locale('ml', 'IN'),
  'mn': Locale('mn', 'MN'),
  'mr': Locale('mr', 'IN'),
  'ms': Locale('ms'),
  'my': Locale('my', 'MM'),
  'ne': Locale('ne', 'NP'),
  'nl': Locale('nl', 'NL'),
  'no': Locale('no', 'NO'),
  'pl': Locale('pl', 'PL'),
  'pt': Locale('pt', 'BR'),
  'rm': Locale('rm'),
  'ro': Locale('ro'),
  'ru': Locale('ru', 'RU'),
  'si': Locale('si', 'LK'),
  'sk': Locale('sk'),
  'sl': Locale('sl'),
  'sr': Locale('sr'),
  'sv': Locale('sv', 'SE'),
  'sw': Locale('sw'),
  'ta': Locale('ta', 'IN'),
  'te': Locale('te', 'IN'),
  'th': Locale('th'),
  'tr': Locale('tr', 'TR'),
  'uk': Locale('uk'),
  'vi': Locale('vi'),
  'zh': Locale('zh', 'CN'),
  'zu': Locale('zu'),
};

// where there are more than one country per language code,
// selection is made in favour of larger population.
const _preferredCountryCodeAppStore = {
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
