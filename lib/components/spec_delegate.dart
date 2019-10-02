import 'package:chaldea/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'constants.dart' show LocaleChangeCallback;

class SpecifiedLocalizationDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  //onLocaleChange should be bind to MaterialApp function containing setState().
  static LocaleChangeCallback onLocaleChange;

  // for instance
  final Locale overriddenLocale;

  const SpecifiedLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      S.delegate.load(overriddenLocale);

  @override
  bool shouldReload(SpecifiedLocalizationDelegate old) => true;
}
