import 'package:flutter/material.dart';
import 'package:chaldea/generated/i18n.dart';

typedef void DataChangeCallback({Locale locale});

class SpecifiedLocalizationDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  //class static vars: need to remove?
  //onLocaleChange should be bind to MaterialApp function containing setState().
  static DataChangeCallback onLocaleChange;

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
