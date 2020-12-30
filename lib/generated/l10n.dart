// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Hello!`
  String get hello {
    return Intl.message(
      'Hello!',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get gallery_tab_name {
    return Intl.message(
      'Home',
      name: 'gallery_tab_name',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_tab_name {
    return Intl.message(
      'Settings',
      name: 'settings_tab_name',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get settings_general {
    return Intl.message(
      'General',
      name: 'settings_general',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settings_language {
    return Intl.message(
      'Language',
      name: 'settings_language',
      desc: '',
      args: [],
    );
  }

  /// `Data`
  String get settings_data {
    return Intl.message(
      'Data',
      name: 'settings_data',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial`
  String get settings_tutorial {
    return Intl.message(
      'Tutorial',
      name: 'settings_tutorial',
      desc: '',
      args: [],
    );
  }

  /// `Current Account`
  String get cur_account {
    return Intl.message(
      'Current Account',
      name: 'cur_account',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  /// `Invalid input value.`
  String get input_error {
    return Intl.message(
      'Invalid input value.',
      name: 'input_error',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `New account`
  String get new_account {
    return Intl.message(
      'New account',
      name: 'new_account',
      desc: '',
      args: [],
    );
  }

  /// `Server`
  String get server {
    return Intl.message(
      'Server',
      name: 'server',
      desc: '',
      args: [],
    );
  }

  /// `CN`
  String get server_cn {
    return Intl.message(
      'CN',
      name: 'server_cn',
      desc: '',
      args: [],
    );
  }

  /// `JP`
  String get server_jp {
    return Intl.message(
      'JP',
      name: 'server_jp',
      desc: '',
      args: [],
    );
  }

  /// `Backup & Restore`
  String get backup_restore {
    return Intl.message(
      'Backup & Restore',
      name: 'backup_restore',
      desc: '',
      args: [],
    );
  }

  /// `Backup to ...`
  String get backup {
    return Intl.message(
      'Backup to ...',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `Servant`
  String get servant_title {
    return Intl.message(
      'Servant',
      name: 'servant_title',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item_title {
    return Intl.message(
      'Item',
      name: 'item_title',
      desc: '',
      args: [],
    );
  }

  /// `Event`
  String get event_title {
    return Intl.message(
      'Event',
      name: 'event_title',
      desc: '',
      args: [],
    );
  }

  /// `Command Code`
  String get cmd_code_title {
    return Intl.message(
      'Command Code',
      name: 'cmd_code_title',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `Servant`
  String get servant {
    return Intl.message(
      'Servant',
      name: 'servant',
      desc: '',
      args: [],
    );
  }

  /// `Craft Essential`
  String get craft_essential {
    return Intl.message(
      'Craft Essential',
      name: 'craft_essential',
      desc: '',
      args: [],
    );
  }

  /// `Drop Calc`
  String get drop_calculator {
    return Intl.message(
      'Drop Calc',
      name: 'drop_calculator',
      desc: '',
      args: [],
    );
  }

  /// `Calculator`
  String get calculator {
    return Intl.message(
      'Calculator',
      name: 'calculator',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}