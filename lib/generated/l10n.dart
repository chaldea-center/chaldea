// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_files: non_constant_identifier_names
// ignore_for_files: camel_case_types
// ignore_for_files: prefer_single_quotes

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get language {
    return Intl.message(
      '简体中文',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  String get hello {
    return Intl.message(
      '你好！Master!',
      name: 'hello',
      desc: '',
      args: [],
    );
  }


  String get gallery_tab_name {
    return Intl.message(
      '首页',
      name: 'gallery_tab_name',
      desc: '',
      args: [],
    );
  }

  String get settings_tab_name {
    return Intl.message(
      '设置',
      name: 'settings_tab_name',
      desc: '',
      args: [],
    );
  }

  String get settings_general {
    return Intl.message(
      '通用',
      name: 'settings_general',
      desc: '',
      args: [],
    );
  }

  String get settings_language {
    return Intl.message(
      '语言',
      name: 'settings_language',
      desc: '',
      args: [],
    );
  }

  String get settings_data {
    return Intl.message(
      '数据',
      name: 'settings_data',
      desc: '',
      args: [],
    );
  }

  String get settings_tutorial {
    return Intl.message(
      '使用帮助',
      name: 'settings_tutorial',
      desc: '',
      args: [],
    );
  }

  String get cur_account {
    return Intl.message(
      '当前账号',
      name: 'cur_account',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      '取消',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get ok {
    return Intl.message(
      '确定',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  String get rename {
    return Intl.message(
      '重命名',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  String get input_error {
    return Intl.message(
      '无效输入值',
      name: 'input_error',
      desc: '',
      args: [],
    );
  }

  String get delete {
    return Intl.message(
      '删除',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  String get new_account {
    return Intl.message(
      '新建账号',
      name: 'new_account',
      desc: '',
      args: [],
    );
  }

  String get server {
    return Intl.message(
      '服务器',
      name: 'server',
      desc: '',
      args: [],
    );
  }

  String get server_cn {
    return Intl.message(
      '国服',
      name: 'server_cn',
      desc: '',
      args: [],
    );
  }

  String get server_jp {
    return Intl.message(
      '日服',
      name: 'server_jp',
      desc: '',
      args: [],
    );
  }

  String get backup {
    return Intl.message(
      'Backup to ...',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  String get servant_title {
    return Intl.message(
      '从者',
      name: 'servant_title',
      desc: '',
      args: [],
    );
  }

  String get item_title {
    return Intl.message(
      '素材',
      name: 'item_title',
      desc: '',
      args: [],
    );
  }

  String get event_title {
    return Intl.message(
      '活动',
      name: 'event_title',
      desc: '',
      args: [],
    );
  }

  String get cmd_code_title {
    return Intl.message(
      '纹章',
      name: 'cmd_code_title',
      desc: '',
      args: [],
    );
  }

  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  String get more {
    return Intl.message(
      '更多',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  String get servant {
    return Intl.message(
      '从者',
      name: 'servant',
      desc: '',
      args: [],
    );
  }

  String get craft_essential {
    return Intl.message(
      '概念礼装',
      name: 'craft_essential',
      desc: '',
      args: [],
    );
  }

  String get drop_calculator {
    return Intl.message(
      '掉落速查',
      name: 'drop_calculator',
      desc: '',
      args: [],
    );
  }

  String get calculator {
    return Intl.message(
      '计算器',
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
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
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
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}