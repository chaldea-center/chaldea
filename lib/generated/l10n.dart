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
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

extension _LocaleEx on Locale {
  String get canonicalizedName {
    if (scriptCode == null) {
      return Intl.canonicalizedLocale(toString());
    }
    return toString();
  }
}

class S {
  final Locale locale;
  final String localeName;

  S(this.locale) : localeName = locale.canonicalizedName;

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale, {bool override = false}) {
    final localeName = locale.canonicalizedName;
    return initializeMessages(localeName).then((_) {
      final localizations = S(locale);
      if (override || S._current == null) {
        Intl.defaultLocale = localeName;
        S._current = localizations;
      }
      return localizations;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `English`
  String get language_en {
    return Intl.message(
      'English',
      name: 'language_en',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `About`
  String get about_app {
    return Intl.message(
      'About',
      name: 'about_app',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `The data used in this application comes from game Fate/GO and the following websites. The copyright of the original texts, pictures and voices of game belongs to TYPE MOON/FGO PROJECT.\n\nThe design of program is based on the WeChat mini program "Material Programe" and the iOS application "Guda".\n`
  String get about_app_declaration_text {
    return Intl.message(
      'The data used in this application comes from game Fate/GO and the following websites. The copyright of the original texts, pictures and voices of game belongs to TYPE MOON/FGO PROJECT.\n\nThe design of program is based on the WeChat mini program "Material Programe" and the iOS application "Guda".\n',
      name: 'about_app_declaration_text',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `App Store Rating`
  String get about_appstore_rating {
    return Intl.message(
      'App Store Rating',
      name: 'about_appstore_rating',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Data source`
  String get about_data_source {
    return Intl.message(
      'Data source',
      name: 'about_data_source',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please inform us if there is unmarked source or infringement.`
  String get about_data_source_footer {
    return Intl.message(
      'Please inform us if there is unmarked source or infringement.',
      name: 'about_data_source_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please send screenshot and log file to email:\n {email}\nLog filepath: {logPath}`
  String about_email_dialog(Object email, Object logPath) {
    return Intl.message(
      'Please send screenshot and log file to email:\n $email\nLog filepath: $logPath',
      name: 'about_email_dialog',
      desc: '',
      locale: localeName,
      args: [email, logPath],
    );
  }

  /// `Please attach screenshot and log file`
  String get about_email_subtitle {
    return Intl.message(
      'Please attach screenshot and log file',
      name: 'about_email_subtitle',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Feedback`
  String get about_feedback {
    return Intl.message(
      'Feedback',
      name: 'about_feedback',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `App Update`
  String get about_update_app {
    return Intl.message(
      'App Update',
      name: 'about_update_app',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please check update in App Store`
  String get about_update_app_alert_ios_mac {
    return Intl.message(
      'Please check update in App Store',
      name: 'about_update_app_alert_ios_mac',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current version: {curVersion}\nLatest version: {newVersion}\nRelease Note:\n{releaseNote}`
  String about_update_app_detail(
      Object curVersion, Object newVersion, Object releaseNote) {
    return Intl.message(
      'Current version: $curVersion\nLatest version: $newVersion\nRelease Note:\n$releaseNote',
      name: 'about_update_app_detail',
      desc: '',
      locale: localeName,
      args: [curVersion, newVersion, releaseNote],
    );
  }

  /// `Account`
  String get account_title {
    return Intl.message(
      'Account',
      name: 'account_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Active Skill`
  String get active_skill {
    return Intl.message(
      'Active Skill',
      name: 'active_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please add feedback details`
  String get add_feedback_details_warning {
    return Intl.message(
      'Please add feedback details',
      name: 'add_feedback_details_warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Add to blacklist`
  String get add_to_blacklist {
    return Intl.message(
      'Add to blacklist',
      name: 'add_to_blacklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AP`
  String get ap {
    return Intl.message(
      'AP',
      name: 'ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `口算不及格的咕朗台.jpg`
  String get ap_calc_page_joke {
    return Intl.message(
      '口算不及格的咕朗台.jpg',
      name: 'ap_calc_page_joke',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AP Calc`
  String get ap_calc_title {
    return Intl.message(
      'AP Calc',
      name: 'ap_calc_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AP rate`
  String get ap_efficiency {
    return Intl.message(
      'AP rate',
      name: 'ap_efficiency',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Time of AP Full`
  String get ap_overflow_time {
    return Intl.message(
      'Time of AP Full',
      name: 'ap_overflow_time',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Append Skill`
  String get append_skill {
    return Intl.message(
      'Append Skill',
      name: 'append_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Append`
  String get append_skill_short {
    return Intl.message(
      'Append',
      name: 'append_skill_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ascension`
  String get ascension {
    return Intl.message(
      'Ascension',
      name: 'ascension',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ascension Icon`
  String get ascension_icon {
    return Intl.message(
      'Ascension Icon',
      name: 'ascension_icon',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ascen`
  String get ascension_short {
    return Intl.message(
      'Ascen',
      name: 'ascension_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ascension`
  String get ascension_up {
    return Intl.message(
      'Ascension',
      name: 'ascension_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `From Files`
  String get attach_from_files {
    return Intl.message(
      'From Files',
      name: 'attach_from_files',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `From Photos`
  String get attach_from_photos {
    return Intl.message(
      'From Photos',
      name: 'attach_from_photos',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `If you have trouble picking images, use files instead`
  String get attach_help {
    return Intl.message(
      'If you have trouble picking images, use files instead',
      name: 'attach_help',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Attachment`
  String get attachment {
    return Intl.message(
      'Attachment',
      name: 'attachment',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto reset`
  String get auto_reset {
    return Intl.message(
      'Auto reset',
      name: 'auto_reset',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto Update`
  String get auto_update {
    return Intl.message(
      'Auto Update',
      name: 'auto_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Backup`
  String get backup {
    return Intl.message(
      'Backup',
      name: 'backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Timely backup wanted`
  String get backup_data_alert {
    return Intl.message(
      'Timely backup wanted',
      name: 'backup_data_alert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Backup History`
  String get backup_history {
    return Intl.message(
      'Backup History',
      name: 'backup_history',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Backup successfully`
  String get backup_success {
    return Intl.message(
      'Backup successfully',
      name: 'backup_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Blacklist`
  String get blacklist {
    return Intl.message(
      'Blacklist',
      name: 'blacklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bond`
  String get bond {
    return Intl.message(
      'Bond',
      name: 'bond',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bond Craft`
  String get bond_craft {
    return Intl.message(
      'Bond Craft',
      name: 'bond_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bond Eff`
  String get bond_eff {
    return Intl.message(
      'Bond Eff',
      name: 'bond_eff',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bootstrap Page`
  String get bootstrap_page_title {
    return Intl.message(
      'Bootstrap Page',
      name: 'bootstrap_page_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bronze`
  String get bronze {
    return Intl.message(
      'Bronze',
      name: 'bronze',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Wight`
  String get calc_weight {
    return Intl.message(
      'Wight',
      name: 'calc_weight',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Calculate`
  String get calculate {
    return Intl.message(
      'Calculate',
      name: 'calculate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Calculator`
  String get calculator {
    return Intl.message(
      'Calculator',
      name: 'calculator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Campaign`
  String get campaign_event {
    return Intl.message(
      'Campaign',
      name: 'campaign_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Description`
  String get card_description {
    return Intl.message(
      'Description',
      name: 'card_description',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Info`
  String get card_info {
    return Intl.message(
      'Info',
      name: 'card_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Carousel Setting`
  String get carousel_setting {
    return Intl.message(
      'Carousel Setting',
      name: 'carousel_setting',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chaldea User`
  String get chaldea_user {
    return Intl.message(
      'Chaldea User',
      name: 'chaldea_user',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Change Log`
  String get change_log {
    return Intl.message(
      'Change Log',
      name: 'change_log',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Characters`
  String get characters_in_card {
    return Intl.message(
      'Characters',
      name: 'characters_in_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Check update`
  String get check_update {
    return Intl.message(
      'Check update',
      name: 'check_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Choose Free Quest`
  String get choose_quest_hint {
    return Intl.message(
      'Choose Free Quest',
      name: 'choose_quest_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Clear cache`
  String get clear_cache {
    return Intl.message(
      'Clear cache',
      name: 'clear_cache',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Cache cleared`
  String get clear_cache_finish {
    return Intl.message(
      'Cache cleared',
      name: 'clear_cache_finish',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Including illustrations, voices`
  String get clear_cache_hint {
    return Intl.message(
      'Including illustrations, voices',
      name: 'clear_cache_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Clear Data`
  String get clear_data {
    return Intl.message(
      'Clear Data',
      name: 'clear_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Clear Userdata`
  String get clear_userdata {
    return Intl.message(
      'Clear Userdata',
      name: 'clear_userdata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Command Code`
  String get cmd_code_title {
    return Intl.message(
      'Command Code',
      name: 'cmd_code_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Command Code`
  String get command_code {
    return Intl.message(
      'Command Code',
      name: 'command_code',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Consumed`
  String get consumed {
    return Intl.message(
      'Consumed',
      name: 'consumed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Contact information is not filled in`
  String get contact_information_not_filled {
    return Intl.message(
      'Contact information is not filled in',
      name: 'contact_information_not_filled',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `The developer will not be able to respond to your feedback`
  String get contact_information_not_filled_warning {
    return Intl.message(
      'The developer will not be able to respond to your feedback',
      name: 'contact_information_not_filled_warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Copy Plan from...`
  String get copy_plan_menu {
    return Intl.message(
      'Copy Plan from...',
      name: 'copy_plan_menu',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Costume`
  String get costume {
    return Intl.message(
      'Costume',
      name: 'costume',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Costume Unlock`
  String get costume_unlock {
    return Intl.message(
      'Costume Unlock',
      name: 'costume_unlock',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Counts`
  String get counts {
    return Intl.message(
      'Counts',
      name: 'counts',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Craft Essence`
  String get craft_essence {
    return Intl.message(
      'Craft Essence',
      name: 'craft_essence',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Craft`
  String get craft_essence_title {
    return Intl.message(
      'Craft',
      name: 'craft_essence_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `You can add more accounts later in Settings`
  String get create_account_textfield_helper {
    return Intl.message(
      'You can add more accounts later in Settings',
      name: 'create_account_textfield_helper',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Any name`
  String get create_account_textfield_hint {
    return Intl.message(
      'Any name',
      name: 'create_account_textfield_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Create duplicated`
  String get create_duplicated_svt {
    return Intl.message(
      'Create duplicated',
      name: 'create_duplicated_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Critical`
  String get critical_attack {
    return Intl.message(
      'Critical',
      name: 'critical_attack',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current Account`
  String get cur_account {
    return Intl.message(
      'Current Account',
      name: 'cur_account',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current AP`
  String get cur_ap {
    return Intl.message(
      'Current AP',
      name: 'cur_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current`
  String get current_ {
    return Intl.message(
      'Current',
      name: 'current_',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current Version`
  String get current_version {
    return Intl.message(
      'Current Version',
      name: 'current_version',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Dark mode`
  String get dark_mode {
    return Intl.message(
      'Dark mode',
      name: 'dark_mode',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Dark`
  String get dark_mode_dark {
    return Intl.message(
      'Dark',
      name: 'dark_mode_dark',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Light color`
  String get dark_mode_light {
    return Intl.message(
      'Light color',
      name: 'dark_mode_light',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `System`
  String get dark_mode_system {
    return Intl.message(
      'System',
      name: 'dark_mode_system',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Database`
  String get database {
    return Intl.message(
      'Database',
      name: 'database',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Database is not downloaded, still continue?`
  String get database_not_downloaded {
    return Intl.message(
      'Database is not downloaded, still continue?',
      name: 'database_not_downloaded',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Goto download webpage`
  String get dataset_goto_download_page {
    return Intl.message(
      'Goto download webpage',
      name: 'dataset_goto_download_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import after downloaded`
  String get dataset_goto_download_page_hint {
    return Intl.message(
      'Import after downloaded',
      name: 'dataset_goto_download_page_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Data Management`
  String get dataset_management {
    return Intl.message(
      'Data Management',
      name: 'dataset_management',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Icon dataset`
  String get dataset_type_image {
    return Intl.message(
      'Icon dataset',
      name: 'dataset_type_image',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Text dataset`
  String get dataset_type_text {
    return Intl.message(
      'Text dataset',
      name: 'dataset_type_text',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Dataset version`
  String get dataset_version {
    return Intl.message(
      'Dataset version',
      name: 'dataset_version',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Debug`
  String get debug {
    return Intl.message(
      'Debug',
      name: 'debug',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Debug FAB`
  String get debug_fab {
    return Intl.message(
      'Debug FAB',
      name: 'debug_fab',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Debug Menu`
  String get debug_menu {
    return Intl.message(
      'Debug Menu',
      name: 'debug_menu',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Demands`
  String get demands {
    return Intl.message(
      'Demands',
      name: 'demands',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Display Settings`
  String get display_setting {
    return Intl.message(
      'Display Settings',
      name: 'display_setting',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `DONE`
  String get done {
    return Intl.message(
      'DONE',
      name: 'done',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Downloaded`
  String get download_complete {
    return Intl.message(
      'Downloaded',
      name: 'download_complete',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Download latest Gamedata`
  String get download_full_gamedata {
    return Intl.message(
      'Download latest Gamedata',
      name: 'download_full_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Full size zip file`
  String get download_full_gamedata_hint {
    return Intl.message(
      'Full size zip file',
      name: 'download_full_gamedata_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Download latest`
  String get download_latest_gamedata {
    return Intl.message(
      'Download latest',
      name: 'download_latest_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `To ensure compatibility, please upgrade to the latest APP version before updating`
  String get download_latest_gamedata_hint {
    return Intl.message(
      'To ensure compatibility, please upgrade to the latest APP version before updating',
      name: 'download_latest_gamedata_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Download source`
  String get download_source {
    return Intl.message(
      'Download source',
      name: 'download_source',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `update dataset and app`
  String get download_source_hint {
    return Intl.message(
      'update dataset and app',
      name: 'download_source_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Source {name}`
  String download_source_of(Object name) {
    return Intl.message(
      'Source $name',
      name: 'download_source_of',
      desc: '',
      locale: localeName,
      args: [name],
    );
  }

  /// `Downloaded`
  String get downloaded {
    return Intl.message(
      'Downloaded',
      name: 'downloaded',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Downloading`
  String get downloading {
    return Intl.message(
      'Downloading',
      name: 'downloading',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click + to add items`
  String get drop_calc_empty_hint {
    return Intl.message(
      'Click + to add items',
      name: 'drop_calc_empty_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Min AP`
  String get drop_calc_min_ap {
    return Intl.message(
      'Min AP',
      name: 'drop_calc_min_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Optimize`
  String get drop_calc_optimize {
    return Intl.message(
      'Optimize',
      name: 'drop_calc_optimize',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Solve`
  String get drop_calc_solve {
    return Intl.message(
      'Solve',
      name: 'drop_calc_solve',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drop rate`
  String get drop_rate {
    return Intl.message(
      'Drop rate',
      name: 'drop_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Buff Search`
  String get effect_search {
    return Intl.message(
      'Buff Search',
      name: 'effect_search',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Efficiency`
  String get efficiency {
    return Intl.message(
      'Efficiency',
      name: 'efficiency',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Efficient`
  String get efficiency_type {
    return Intl.message(
      'Efficient',
      name: 'efficiency_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `20AP Rate`
  String get efficiency_type_ap {
    return Intl.message(
      '20AP Rate',
      name: 'efficiency_type_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drop Rate`
  String get efficiency_type_drop {
    return Intl.message(
      'Drop Rate',
      name: 'efficiency_type_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemies`
  String get enemy_list {
    return Intl.message(
      'Enemies',
      name: 'enemy_list',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enhance`
  String get enhance {
    return Intl.message(
      'Enhance',
      name: 'enhance',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `The following items will be consumed for enhancement`
  String get enhance_warning {
    return Intl.message(
      'The following items will be consumed for enhancement',
      name: 'enhance_warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No internet`
  String get error_no_internet {
    return Intl.message(
      'No internet',
      name: 'error_no_internet',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No network`
  String get error_no_network {
    return Intl.message(
      'No network',
      name: 'error_no_network',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No version data found`
  String get error_no_version_data_found {
    return Intl.message(
      'No version data found',
      name: 'error_no_version_data_found',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Required app version: ≥ {version}`
  String error_required_app_version(Object version) {
    return Intl.message(
      'Required app version: ≥ $version',
      name: 'error_required_app_version',
      desc: '',
      locale: localeName,
      args: [version],
    );
  }

  /// `All items will be added to bag and remove the event out of plan`
  String get event_collect_item_confirm {
    return Intl.message(
      'All items will be added to bag and remove the event out of plan',
      name: 'event_collect_item_confirm',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Collect Items`
  String get event_collect_items {
    return Intl.message(
      'Collect Items',
      name: 'event_collect_items',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Shop/Task/Points/Quests`
  String get event_item_default {
    return Intl.message(
      'Shop/Task/Points/Quests',
      name: 'event_item_default',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Extra Obtains`
  String get event_item_extra {
    return Intl.message(
      'Extra Obtains',
      name: 'event_item_extra',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Max {n} lottery`
  String event_lottery_limit_hint(Object n) {
    return Intl.message(
      'Max $n lottery',
      name: 'event_lottery_limit_hint',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `Limited lottery`
  String get event_lottery_limited {
    return Intl.message(
      'Limited lottery',
      name: 'event_lottery_limited',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Lottery`
  String get event_lottery_unit {
    return Intl.message(
      'Lottery',
      name: 'event_lottery_unit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unlimited lottery`
  String get event_lottery_unlimited {
    return Intl.message(
      'Unlimited lottery',
      name: 'event_lottery_unlimited',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event not planned`
  String get event_not_planned {
    return Intl.message(
      'Event not planned',
      name: 'event_not_planned',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Progress`
  String get event_progress {
    return Intl.message(
      'Progress',
      name: 'event_progress',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Grail to crystal: {n}`
  String event_rerun_replace_grail(Object n) {
    return Intl.message(
      'Grail to crystal: $n',
      name: 'event_rerun_replace_grail',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `Event`
  String get event_title {
    return Intl.message(
      'Event',
      name: 'event_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Exchange Ticket`
  String get exchange_ticket {
    return Intl.message(
      'Exchange Ticket',
      name: 'exchange_ticket',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ticket`
  String get exchange_ticket_short {
    return Intl.message(
      'Ticket',
      name: 'exchange_ticket_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Levels`
  String get exp_card_plan_lv {
    return Intl.message(
      'Levels',
      name: 'exp_card_plan_lv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `5☆ Exp Card`
  String get exp_card_rarity5 {
    return Intl.message(
      '5☆ Exp Card',
      name: 'exp_card_rarity5',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Same Class`
  String get exp_card_same_class {
    return Intl.message(
      'Same Class',
      name: 'exp_card_same_class',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Level Range`
  String get exp_card_select_lvs {
    return Intl.message(
      'Select Level Range',
      name: 'exp_card_select_lvs',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Exp Card`
  String get exp_card_title {
    return Intl.message(
      'Exp Card',
      name: 'exp_card_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `FAQ`
  String get faq {
    return Intl.message(
      'FAQ',
      name: 'faq',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Favorite`
  String get favorite {
    return Intl.message(
      'Favorite',
      name: 'favorite',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `e.g. screenshots, files.`
  String get feedback_add_attachments {
    return Intl.message(
      'e.g. screenshots, files.',
      name: 'feedback_add_attachments',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Add crash log`
  String get feedback_add_crash_log {
    return Intl.message(
      'Add crash log',
      name: 'feedback_add_crash_log',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Contact information`
  String get feedback_contact {
    return Intl.message(
      'Contact information',
      name: 'feedback_contact',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Feedback or Suggestion`
  String get feedback_content_hint {
    return Intl.message(
      'Feedback or Suggestion',
      name: 'feedback_content_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Feedback form is not empty, still exist?`
  String get feedback_form_alert {
    return Intl.message(
      'Feedback form is not empty, still exist?',
      name: 'feedback_form_alert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please check <**FAQ**> first before sending feedback. And following detail is desired:\n- How to reproduce, expected behaviour\n- App/dataset version, device system and version\n- Attach screenshots and logs\n- It's better to provide contact info (e.g. Email)`
  String get feedback_info {
    return Intl.message(
      'Please check <**FAQ**> first before sending feedback. And following detail is desired:\n- How to reproduce, expected behaviour\n- App/dataset version, device system and version\n- Attach screenshots and logs\n- It\'s better to provide contact info (e.g. Email)',
      name: 'feedback_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Send`
  String get feedback_send {
    return Intl.message(
      'Send',
      name: 'feedback_send',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Subject`
  String get feedback_subject {
    return Intl.message(
      'Subject',
      name: 'feedback_subject',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Background`
  String get ffo_background {
    return Intl.message(
      'Background',
      name: 'ffo_background',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Body`
  String get ffo_body {
    return Intl.message(
      'Body',
      name: 'ffo_body',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Crop`
  String get ffo_crop {
    return Intl.message(
      'Crop',
      name: 'ffo_crop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Head`
  String get ffo_head {
    return Intl.message(
      'Head',
      name: 'ffo_head',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please download or import FFO data first↗`
  String get ffo_missing_data_hint {
    return Intl.message(
      'Please download or import FFO data first↗',
      name: 'ffo_missing_data_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Same Servant`
  String get ffo_same_svt {
    return Intl.message(
      'Same Servant',
      name: 'ffo_same_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Domus Aurea`
  String get fgo_domus_aurea {
    return Intl.message(
      'Domus Aurea',
      name: 'fgo_domus_aurea',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `File {filename} not found or mismatched hash: {hash} - {localHash}`
  String file_not_found_or_mismatched_hash(
      Object filename, Object hash, Object localHash) {
    return Intl.message(
      'File $filename not found or mismatched hash: $hash - $localHash',
      name: 'file_not_found_or_mismatched_hash',
      desc: '',
      locale: localeName,
      args: [filename, hash, localHash],
    );
  }

  /// `filename`
  String get filename {
    return Intl.message(
      'filename',
      name: 'filename',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please fill in email address. Otherwise NO reply.`
  String get fill_email_warning {
    return Intl.message(
      'Please fill in email address. Otherwise NO reply.',
      name: 'fill_email_warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Type`
  String get filter_atk_hp_type {
    return Intl.message(
      'Type',
      name: 'filter_atk_hp_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Attribute`
  String get filter_attribute {
    return Intl.message(
      'Attribute',
      name: 'filter_attribute',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Category`
  String get filter_category {
    return Intl.message(
      'Category',
      name: 'filter_category',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Effects`
  String get filter_effects {
    return Intl.message(
      'Effects',
      name: 'filter_effects',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gender`
  String get filter_gender {
    return Intl.message(
      'Gender',
      name: 'filter_gender',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Match All`
  String get filter_match_all {
    return Intl.message(
      'Match All',
      name: 'filter_match_all',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Obtains`
  String get filter_obtain {
    return Intl.message(
      'Obtains',
      name: 'filter_obtain',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan-not-reach`
  String get filter_plan_not_reached {
    return Intl.message(
      'Plan-not-reach',
      name: 'filter_plan_not_reached',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan-reached`
  String get filter_plan_reached {
    return Intl.message(
      'Plan-reached',
      name: 'filter_plan_reached',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Revert`
  String get filter_revert {
    return Intl.message(
      'Revert',
      name: 'filter_revert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Display`
  String get filter_shown_type {
    return Intl.message(
      'Display',
      name: 'filter_shown_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skills`
  String get filter_skill_lv {
    return Intl.message(
      'Skills',
      name: 'filter_skill_lv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sort`
  String get filter_sort {
    return Intl.message(
      'Sort',
      name: 'filter_sort',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Class`
  String get filter_sort_class {
    return Intl.message(
      'Class',
      name: 'filter_sort_class',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No`
  String get filter_sort_number {
    return Intl.message(
      'No',
      name: 'filter_sort_number',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rarity`
  String get filter_sort_rarity {
    return Intl.message(
      'Rarity',
      name: 'filter_sort_rarity',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Special Trait`
  String get filter_special_trait {
    return Intl.message(
      'Special Trait',
      name: 'filter_special_trait',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free Efficiency`
  String get free_efficiency {
    return Intl.message(
      'Free Efficiency',
      name: 'free_efficiency',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Quest Limit`
  String get free_progress {
    return Intl.message(
      'Quest Limit',
      name: 'free_progress',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Latest(JP)`
  String get free_progress_newest {
    return Intl.message(
      'Latest(JP)',
      name: 'free_progress_newest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free Quest`
  String get free_quest {
    return Intl.message(
      'Free Quest',
      name: 'free_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free Quest`
  String get free_quest_calculator {
    return Intl.message(
      'Free Quest',
      name: 'free_quest_calculator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free Quest`
  String get free_quest_calculator_short {
    return Intl.message(
      'Free Quest',
      name: 'free_quest_calculator_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Home`
  String get gallery_tab_name {
    return Intl.message(
      'Home',
      name: 'gallery_tab_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Game data not found, please download data first`
  String get game_data_not_found {
    return Intl.message(
      'Game data not found, please download data first',
      name: 'game_data_not_found',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drop`
  String get game_drop {
    return Intl.message(
      'Drop',
      name: 'game_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Experience`
  String get game_experience {
    return Intl.message(
      'Experience',
      name: 'game_experience',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bond`
  String get game_kizuna {
    return Intl.message(
      'Bond',
      name: 'game_kizuna',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rewards`
  String get game_rewards {
    return Intl.message(
      'Rewards',
      name: 'game_rewards',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Game Server`
  String get game_server {
    return Intl.message(
      'Game Server',
      name: 'game_server',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chinese(Simplified)`
  String get game_server_cn {
    return Intl.message(
      'Chinese(Simplified)',
      name: 'game_server_cn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Japanese`
  String get game_server_jp {
    return Intl.message(
      'Japanese',
      name: 'game_server_jp',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `English(NA)`
  String get game_server_na {
    return Intl.message(
      'English(NA)',
      name: 'game_server_na',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chinese(Traditional)`
  String get game_server_tw {
    return Intl.message(
      'Chinese(Traditional)',
      name: 'game_server_tw',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gamedata`
  String get gamedata {
    return Intl.message(
      'Gamedata',
      name: 'gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gold`
  String get gold {
    return Intl.message(
      'Gold',
      name: 'gold',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Grail`
  String get grail {
    return Intl.message(
      'Grail',
      name: 'grail',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Grail`
  String get grail_level {
    return Intl.message(
      'Grail',
      name: 'grail_level',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Palingenesis`
  String get grail_up {
    return Intl.message(
      'Palingenesis',
      name: 'grail_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Growth Curve`
  String get growth_curve {
    return Intl.message(
      'Growth Curve',
      name: 'growth_curve',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Guda Item Data`
  String get guda_item_data {
    return Intl.message(
      'Guda Item Data',
      name: 'guda_item_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Guda Servant Data`
  String get guda_servant_data {
    return Intl.message(
      'Guda Servant Data',
      name: 'guda_servant_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hash mismatch: {filename}: {hash} - {dataHash}`
  String hash_mismatch(Object filename, Object hash, Object dataHash) {
    return Intl.message(
      'Hash mismatch: $filename: $hash - $dataHash',
      name: 'hash_mismatch',
      desc: '',
      locale: localeName,
      args: [filename, hash, dataHash],
    );
  }

  /// `Hello! Master!`
  String get hello {
    return Intl.message(
      'Hello! Master!',
      name: 'hello',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hide Outdated`
  String get hide_outdated {
    return Intl.message(
      'Hide Outdated',
      name: 'hide_outdated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No bond craft`
  String get hint_no_bond_craft {
    return Intl.message(
      'No bond craft',
      name: 'hint_no_bond_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No valentine craft`
  String get hint_no_valentine_craft {
    return Intl.message(
      'No valentine craft',
      name: 'hint_no_valentine_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Icons`
  String get icons {
    return Intl.message(
      'Icons',
      name: 'icons',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ignore`
  String get ignore {
    return Intl.message(
      'Ignore',
      name: 'ignore',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Illustration`
  String get illustration {
    return Intl.message(
      'Illustration',
      name: 'illustration',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Illustrator`
  String get illustrator {
    return Intl.message(
      'Illustrator',
      name: 'illustrator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Image analysis`
  String get image_analysis {
    return Intl.message(
      'Image analysis',
      name: 'image_analysis',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import`
  String get import_data {
    return Intl.message(
      'Import',
      name: 'import_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import failed. Error:\n{error}`
  String import_data_error(Object error) {
    return Intl.message(
      'Import failed. Error:\n$error',
      name: 'import_data_error',
      desc: '',
      locale: localeName,
      args: [error],
    );
  }

  /// `Import data successfully`
  String get import_data_success {
    return Intl.message(
      'Import data successfully',
      name: 'import_data_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Guda Data`
  String get import_guda_data {
    return Intl.message(
      'Guda Data',
      name: 'import_guda_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Update：remain current userdata and update(Recommended)\nOverride：clear userdata then updatee`
  String get import_guda_hint {
    return Intl.message(
      'Update：remain current userdata and update(Recommended)\nOverride：clear userdata then updatee',
      name: 'import_guda_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import Item`
  String get import_guda_items {
    return Intl.message(
      'Import Item',
      name: 'import_guda_items',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import Servant`
  String get import_guda_servants {
    return Intl.message(
      'Import Servant',
      name: 'import_guda_servants',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Duplicated`
  String get import_http_body_duplicated {
    return Intl.message(
      'Duplicated',
      name: 'import_http_body_duplicated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click import button to import decrypted HTTPS response`
  String get import_http_body_hint {
    return Intl.message(
      'Click import button to import decrypted HTTPS response',
      name: 'import_http_body_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click servant to hide/unhide`
  String get import_http_body_hint_hide {
    return Intl.message(
      'Click servant to hide/unhide',
      name: 'import_http_body_hint_hide',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Locked Only`
  String get import_http_body_locked {
    return Intl.message(
      'Locked Only',
      name: 'import_http_body_locked',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Switched to account {account}`
  String import_http_body_success_switch(Object account) {
    return Intl.message(
      'Switched to account $account',
      name: 'import_http_body_success_switch',
      desc: '',
      locale: localeName,
      args: [account],
    );
  }

  /// `Import {itemNum} items and {svtNum} svts to`
  String import_http_body_target_account_header(Object itemNum, Object svtNum) {
    return Intl.message(
      'Import $itemNum items and $svtNum svts to',
      name: 'import_http_body_target_account_header',
      desc: '',
      locale: localeName,
      args: [itemNum, svtNum],
    );
  }

  /// `Import Screenshots`
  String get import_screenshot {
    return Intl.message(
      'Import Screenshots',
      name: 'import_screenshot',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only update recognized items`
  String get import_screenshot_hint {
    return Intl.message(
      'Only update recognized items',
      name: 'import_screenshot_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Update Items`
  String get import_screenshot_update_items {
    return Intl.message(
      'Update Items',
      name: 'import_screenshot_update_items',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import Source File`
  String get import_source_file {
    return Intl.message(
      'Import Source File',
      name: 'import_source_file',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Agility`
  String get info_agility {
    return Intl.message(
      'Agility',
      name: 'info_agility',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Alignment`
  String get info_alignment {
    return Intl.message(
      'Alignment',
      name: 'info_alignment',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bond Points`
  String get info_bond_points {
    return Intl.message(
      'Bond Points',
      name: 'info_bond_points',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Point`
  String get info_bond_points_single {
    return Intl.message(
      'Point',
      name: 'info_bond_points_single',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sum`
  String get info_bond_points_sum {
    return Intl.message(
      'Sum',
      name: 'info_bond_points_sum',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Cards`
  String get info_cards {
    return Intl.message(
      'Cards',
      name: 'info_cards',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Critical Rate`
  String get info_critical_rate {
    return Intl.message(
      'Critical Rate',
      name: 'info_critical_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Voice Actor`
  String get info_cv {
    return Intl.message(
      'Voice Actor',
      name: 'info_cv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Death Rate`
  String get info_death_rate {
    return Intl.message(
      'Death Rate',
      name: 'info_death_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Endurance`
  String get info_endurance {
    return Intl.message(
      'Endurance',
      name: 'info_endurance',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gender`
  String get info_gender {
    return Intl.message(
      'Gender',
      name: 'info_gender',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Height`
  String get info_height {
    return Intl.message(
      'Height',
      name: 'info_height',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Human`
  String get info_human {
    return Intl.message(
      'Human',
      name: 'info_human',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Luck`
  String get info_luck {
    return Intl.message(
      'Luck',
      name: 'info_luck',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Mana`
  String get info_mana {
    return Intl.message(
      'Mana',
      name: 'info_mana',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP`
  String get info_np {
    return Intl.message(
      'NP',
      name: 'info_np',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Rate`
  String get info_np_rate {
    return Intl.message(
      'NP Rate',
      name: 'info_np_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Star Rate`
  String get info_star_rate {
    return Intl.message(
      'Star Rate',
      name: 'info_star_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Strength`
  String get info_strength {
    return Intl.message(
      'Strength',
      name: 'info_strength',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Traits`
  String get info_trait {
    return Intl.message(
      'Traits',
      name: 'info_trait',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Value`
  String get info_value {
    return Intl.message(
      'Value',
      name: 'info_value',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Weak to EA`
  String get info_weak_to_ea {
    return Intl.message(
      'Weak to EA',
      name: 'info_weak_to_ea',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Weight`
  String get info_weight {
    return Intl.message(
      'Weight',
      name: 'info_weight',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Invalid inputs`
  String get input_invalid_hint {
    return Intl.message(
      'Invalid inputs',
      name: 'input_invalid_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Install`
  String get install {
    return Intl.message(
      'Install',
      name: 'install',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Interlude & Rank Up`
  String get interlude_and_rankup {
    return Intl.message(
      'Interlude & Rank Up',
      name: 'interlude_and_rankup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Invalid input.`
  String get invalid_input {
    return Intl.message(
      'Invalid input.',
      name: 'invalid_input',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Invalid startup path!`
  String get invalid_startup_path {
    return Intl.message(
      'Invalid startup path!',
      name: 'invalid_startup_path',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please, extract zip to non-system path then start the app. "C:\", "C:\Program Files" are not allowed.`
  String get invalid_startup_path_info {
    return Intl.message(
      'Please, extract zip to non-system path then start the app. "C:\\", "C:\\Program Files" are not allowed.',
      name: 'invalid_startup_path_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `"Files" app/On My iPhone/Chaldea`
  String get ios_app_path {
    return Intl.message(
      '"Files" app/On My iPhone/Chaldea',
      name: 'ios_app_path',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Issues`
  String get issues {
    return Intl.message(
      'Issues',
      name: 'issues',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message(
      'Item',
      name: 'item',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{name} already exist`
  String item_already_exist_hint(Object name) {
    return Intl.message(
      '$name already exist',
      name: 'item_already_exist_hint',
      desc: '',
      locale: localeName,
      args: [name],
    );
  }

  /// `Ascension Items`
  String get item_category_ascension {
    return Intl.message(
      'Ascension Items',
      name: 'item_category_ascension',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bronze Items`
  String get item_category_bronze {
    return Intl.message(
      'Bronze Items',
      name: 'item_category_bronze',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event Item`
  String get item_category_event_svt_ascension {
    return Intl.message(
      'Event Item',
      name: 'item_category_event_svt_ascension',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gem`
  String get item_category_gem {
    return Intl.message(
      'Gem',
      name: 'item_category_gem',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skill Items`
  String get item_category_gems {
    return Intl.message(
      'Skill Items',
      name: 'item_category_gems',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gold Items`
  String get item_category_gold {
    return Intl.message(
      'Gold Items',
      name: 'item_category_gold',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Magic Gem`
  String get item_category_magic_gem {
    return Intl.message(
      'Magic Gem',
      name: 'item_category_magic_gem',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Monument`
  String get item_category_monument {
    return Intl.message(
      'Monument',
      name: 'item_category_monument',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Others`
  String get item_category_others {
    return Intl.message(
      'Others',
      name: 'item_category_others',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Piece`
  String get item_category_piece {
    return Intl.message(
      'Piece',
      name: 'item_category_piece',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Secret Gem`
  String get item_category_secret_gem {
    return Intl.message(
      'Secret Gem',
      name: 'item_category_secret_gem',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Silver Items`
  String get item_category_silver {
    return Intl.message(
      'Silver Items',
      name: 'item_category_silver',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Special Items`
  String get item_category_special {
    return Intl.message(
      'Special Items',
      name: 'item_category_special',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Items`
  String get item_category_usual {
    return Intl.message(
      'Items',
      name: 'item_category_usual',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Item Eff`
  String get item_eff {
    return Intl.message(
      'Item Eff',
      name: 'item_eff',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Before planning, you can set exceeded num for items(Only used for free quest planning)`
  String get item_exceed_hint {
    return Intl.message(
      'Before planning, you can set exceeded num for items(Only used for free quest planning)',
      name: 'item_exceed_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Left`
  String get item_left {
    return Intl.message(
      'Left',
      name: 'item_left',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Free Quests`
  String get item_no_free_quests {
    return Intl.message(
      'No Free Quests',
      name: 'item_no_free_quests',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only show lacked`
  String get item_only_show_lack {
    return Intl.message(
      'Only show lacked',
      name: 'item_only_show_lack',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Owned`
  String get item_own {
    return Intl.message(
      'Owned',
      name: 'item_own',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Item Screenshot`
  String get item_screenshot {
    return Intl.message(
      'Item Screenshot',
      name: 'item_screenshot',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Item`
  String get item_title {
    return Intl.message(
      'Item',
      name: 'item_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Total`
  String get item_total_demand {
    return Intl.message(
      'Total',
      name: 'item_total_demand',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Join Beta Program`
  String get join_beta {
    return Intl.message(
      'Join Beta Program',
      name: 'join_beta',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Jump to {site}`
  String jump_to(Object site) {
    return Intl.message(
      'Jump to $site',
      name: 'jump_to',
      desc: '',
      locale: localeName,
      args: [site],
    );
  }

  /// `Level`
  String get level {
    return Intl.message(
      'Level',
      name: 'level',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Limited Event`
  String get limited_event {
    return Intl.message(
      'Limited Event',
      name: 'limited_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `link`
  String get link {
    return Intl.message(
      'link',
      name: 'link',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{first, select, true{Already the first one} false{Already the last one} other{No more}}`
  String list_end_hint(Object first) {
    return Intl.select(
      first,
      {
        'true': 'Already the first one',
        'false': 'Already the last one',
        'other': 'No more',
      },
      name: 'list_end_hint',
      desc: '',
      locale: localeName,
      args: [first],
    );
  }

  /// `Error loading dataset`
  String get load_dataset_error {
    return Intl.message(
      'Error loading dataset',
      name: 'load_dataset_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please reload default gamedata in Settings-Gamedata`
  String get load_dataset_error_hint {
    return Intl.message(
      'Please reload default gamedata in Settings-Gamedata',
      name: 'load_dataset_error_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Loading Data Failed`
  String get loading_data_failed {
    return Intl.message(
      'Loading Data Failed',
      name: 'loading_data_failed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Change Name`
  String get login_change_name {
    return Intl.message(
      'Change Name',
      name: 'login_change_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Change Password`
  String get login_change_password {
    return Intl.message(
      'Change Password',
      name: 'login_change_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Confirm Password`
  String get login_confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'login_confirm_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please login first`
  String get login_first_hint {
    return Intl.message(
      'Please login first',
      name: 'login_first_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Forget Password`
  String get login_forget_pwd {
    return Intl.message(
      'Forget Password',
      name: 'login_forget_pwd',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Login`
  String get login_login {
    return Intl.message(
      'Login',
      name: 'login_login',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Logout`
  String get login_logout {
    return Intl.message(
      'Logout',
      name: 'login_logout',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `New Name`
  String get login_new_name {
    return Intl.message(
      'New Name',
      name: 'login_new_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `New Password`
  String get login_new_password {
    return Intl.message(
      'New Password',
      name: 'login_new_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Password`
  String get login_password {
    return Intl.message(
      'Password',
      name: 'login_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Can only contain letters and numbers, no less than 4 digits`
  String get login_password_error {
    return Intl.message(
      'Can only contain letters and numbers, no less than 4 digits',
      name: 'login_password_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Cannot be the same as the old password`
  String get login_password_error_same_as_old {
    return Intl.message(
      'Cannot be the same as the old password',
      name: 'login_password_error_same_as_old',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Signup`
  String get login_signup {
    return Intl.message(
      'Signup',
      name: 'login_signup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Not logged in`
  String get login_state_not_login {
    return Intl.message(
      'Not logged in',
      name: 'login_state_not_login',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Username`
  String get login_username {
    return Intl.message(
      'Username',
      name: 'login_username',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Can only contain letters and numbers, starting with a letter, no less than 4 digits`
  String get login_username_error {
    return Intl.message(
      'Can only contain letters and numbers, starting with a letter, no less than 4 digits',
      name: 'login_username_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Long press to save`
  String get long_press_to_save_hint {
    return Intl.message(
      'Long press to save',
      name: 'long_press_to_save_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Lucky Bag`
  String get lucky_bag {
    return Intl.message(
      'Lucky Bag',
      name: 'lucky_bag',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Main Record`
  String get main_record {
    return Intl.message(
      'Main Record',
      name: 'main_record',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bonus`
  String get main_record_bonus {
    return Intl.message(
      'Bonus',
      name: 'main_record_bonus',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bonus`
  String get main_record_bonus_short {
    return Intl.message(
      'Bonus',
      name: 'main_record_bonus_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chapter`
  String get main_record_chapter {
    return Intl.message(
      'Chapter',
      name: 'main_record_chapter',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drops`
  String get main_record_fixed_drop {
    return Intl.message(
      'Drops',
      name: 'main_record_fixed_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drops`
  String get main_record_fixed_drop_short {
    return Intl.message(
      'Drops',
      name: 'main_record_fixed_drop_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Master-Detail width`
  String get master_detail_width {
    return Intl.message(
      'Master-Detail width',
      name: 'master_detail_width',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Master Mission`
  String get master_mission {
    return Intl.message(
      'Master Mission',
      name: 'master_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Related Quests`
  String get master_mission_related_quest {
    return Intl.message(
      'Related Quests',
      name: 'master_mission_related_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Solution`
  String get master_mission_solution {
    return Intl.message(
      'Solution',
      name: 'master_mission_solution',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Missions`
  String get master_mission_tasklist {
    return Intl.message(
      'Missions',
      name: 'master_mission_tasklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Maximum AP`
  String get max_ap {
    return Intl.message(
      'Maximum AP',
      name: 'max_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Move down`
  String get move_down {
    return Intl.message(
      'Move down',
      name: 'move_down',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Move up`
  String get move_up {
    return Intl.message(
      'Move up',
      name: 'move_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Mystic Code`
  String get mystic_code {
    return Intl.message(
      'Mystic Code',
      name: 'mystic_code',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `New account`
  String get new_account {
    return Intl.message(
      'New account',
      name: 'new_account',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NEXT`
  String get next {
    return Intl.message(
      'NEXT',
      name: 'next',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Next`
  String get next_card {
    return Intl.message(
      'Next',
      name: 'next_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NGA`
  String get nga {
    return Intl.message(
      'NGA',
      name: 'nga',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NGA-FGO`
  String get nga_fgo {
    return Intl.message(
      'NGA-FGO',
      name: 'nga_fgo',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `There is no interlude or rank up quest`
  String get no_servant_quest_hint {
    return Intl.message(
      'There is no interlude or rank up quest',
      name: 'no_servant_quest_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click ♡ to view all servants' quests`
  String get no_servant_quest_hint_subtitle {
    return Intl.message(
      'Click ♡ to view all servants\' quests',
      name: 'no_servant_quest_hint_subtitle',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Noble Phantasm`
  String get noble_phantasm {
    return Intl.message(
      'Noble Phantasm',
      name: 'noble_phantasm',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Noble Phantasm`
  String get noble_phantasm_level {
    return Intl.message(
      'Noble Phantasm',
      name: 'noble_phantasm_level',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Not Available`
  String get not_available {
    return Intl.message(
      'Not Available',
      name: 'not_available',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Not Found`
  String get not_found {
    return Intl.message(
      'Not Found',
      name: 'not_found',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Not yet implemented`
  String get not_implemented {
    return Intl.message(
      'Not yet implemented',
      name: 'not_implemented',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Obtains`
  String get obtain_methods {
    return Intl.message(
      'Obtains',
      name: 'obtain_methods',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Condition`
  String get open_condition {
    return Intl.message(
      'Condition',
      name: 'open_condition',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message(
      'Overview',
      name: 'overview',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Override`
  String get overwrite {
    return Intl.message(
      'Override',
      name: 'overwrite',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Passive Skill`
  String get passive_skill {
    return Intl.message(
      'Passive Skill',
      name: 'passive_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Patch Gamedata`
  String get patch_gamedata {
    return Intl.message(
      'Patch Gamedata',
      name: 'patch_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No compatible version with current app version`
  String get patch_gamedata_error_no_compatible {
    return Intl.message(
      'No compatible version with current app version',
      name: 'patch_gamedata_error_no_compatible',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Cannot found current version on server, downloading full size package`
  String get patch_gamedata_error_unknown_version {
    return Intl.message(
      'Cannot found current version on server, downloading full size package',
      name: 'patch_gamedata_error_unknown_version',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only patch downloaded`
  String get patch_gamedata_hint {
    return Intl.message(
      'Only patch downloaded',
      name: 'patch_gamedata_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Updated dataset to {version}`
  String patch_gamedata_success_to(Object version) {
    return Intl.message(
      'Updated dataset to $version',
      name: 'patch_gamedata_success_to',
      desc: '',
      locale: localeName,
      args: [version],
    );
  }

  /// `Plan`
  String get plan {
    return Intl.message(
      'Plan',
      name: 'plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan Max(310)`
  String get plan_max10 {
    return Intl.message(
      'Plan Max(310)',
      name: 'plan_max10',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan Max(999)`
  String get plan_max9 {
    return Intl.message(
      'Plan Max(999)',
      name: 'plan_max9',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan Objective`
  String get plan_objective {
    return Intl.message(
      'Plan Objective',
      name: 'plan_objective',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan`
  String get plan_title {
    return Intl.message(
      'Plan',
      name: 'plan_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plan {index}`
  String plan_x(Object index) {
    return Intl.message(
      'Plan $index',
      name: 'plan_x',
      desc: '',
      locale: localeName,
      args: [index],
    );
  }

  /// `Planning Quests`
  String get planning_free_quest_btn {
    return Intl.message(
      'Planning Quests',
      name: 'planning_free_quest_btn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Preferred Translation`
  String get preferred_translation {
    return Intl.message(
      'Preferred Translation',
      name: 'preferred_translation',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drag to change the order.\nUsed for game data description, not UI language. Not all game data is translated for all 5 official languages.`
  String get preferred_translation_footer {
    return Intl.message(
      'Drag to change the order.\nUsed for game data description, not UI language. Not all game data is translated for all 5 official languages.',
      name: 'preferred_translation_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `PREV`
  String get prev {
    return Intl.message(
      'PREV',
      name: 'prev',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Previous`
  String get previous_card {
    return Intl.message(
      'Previous',
      name: 'previous_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Priority`
  String get priority {
    return Intl.message(
      'Priority',
      name: 'priority',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Project Homepage`
  String get project_homepage {
    return Intl.message(
      'Project Homepage',
      name: 'project_homepage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Query failed`
  String get query_failed {
    return Intl.message(
      'Query failed',
      name: 'query_failed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Quest`
  String get quest {
    return Intl.message(
      'Quest',
      name: 'quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Conditions`
  String get quest_condition {
    return Intl.message(
      'Conditions',
      name: 'quest_condition',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rarity`
  String get rarity {
    return Intl.message(
      'Rarity',
      name: 'rarity',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rate on App Store`
  String get rate_app_store {
    return Intl.message(
      'Rate on App Store',
      name: 'rate_app_store',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rate on Google Play`
  String get rate_play_store {
    return Intl.message(
      'Rate on Google Play',
      name: 'rate_play_store',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Release Page`
  String get release_page {
    return Intl.message(
      'Release Page',
      name: 'release_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import successfully`
  String get reload_data_success {
    return Intl.message(
      'Import successfully',
      name: 'reload_data_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Reload default`
  String get reload_default_gamedata {
    return Intl.message(
      'Reload default',
      name: 'reload_default_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Importing`
  String get reloading_data {
    return Intl.message(
      'Importing',
      name: 'reloading_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Remove duplicated`
  String get remove_duplicated_svt {
    return Intl.message(
      'Remove duplicated',
      name: 'remove_duplicated_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Remove from blacklist`
  String get remove_from_blacklist {
    return Intl.message(
      'Remove from blacklist',
      name: 'remove_from_blacklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rerun`
  String get rerun_event {
    return Intl.message(
      'Rerun',
      name: 'rerun_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Reset Plan {n}(All)`
  String reset_plan_all(Object n) {
    return Intl.message(
      'Reset Plan $n(All)',
      name: 'reset_plan_all',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `Reset Plan {n}(Shown)`
  String reset_plan_shown(Object n) {
    return Intl.message(
      'Reset Plan $n(Shown)',
      name: 'reset_plan_shown',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `Reset successfully`
  String get reset_success {
    return Intl.message(
      'Reset successfully',
      name: 'reset_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Reset default skill/NP`
  String get reset_svt_enhance_state {
    return Intl.message(
      'Reset default skill/NP',
      name: 'reset_svt_enhance_state',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Reset rank up of skills and noble phantasm`
  String get reset_svt_enhance_state_hint {
    return Intl.message(
      'Reset rank up of skills and noble phantasm',
      name: 'reset_svt_enhance_state_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Restart to take effect`
  String get restart_to_take_effect {
    return Intl.message(
      'Restart to take effect',
      name: 'restart_to_take_effect',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Restart to upgrade. If the update fails, please manually copy the source folder to destination`
  String get restart_to_upgrade_hint {
    return Intl.message(
      'Restart to upgrade. If the update fails, please manually copy the source folder to destination',
      name: 'restart_to_upgrade_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `SQ Plan`
  String get saint_quartz_plan {
    return Intl.message(
      'SQ Plan',
      name: 'saint_quartz_plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Save to Photos`
  String get save_to_photos {
    return Intl.message(
      'Save to Photos',
      name: 'save_to_photos',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Saved`
  String get saved {
    return Intl.message(
      'Saved',
      name: 'saved',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Screen Size`
  String get screen_size {
    return Intl.message(
      'Screen Size',
      name: 'screen_size',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Basic`
  String get search_option_basic {
    return Intl.message(
      'Basic',
      name: 'search_option_basic',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Search Scopes`
  String get search_options {
    return Intl.message(
      'Search Scopes',
      name: 'search_options',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Total {total} results`
  String search_result_count(Object total) {
    return Intl.message(
      'Total $total results',
      name: 'search_result_count',
      desc: '',
      locale: localeName,
      args: [total],
    );
  }

  /// `Total {total} results ({hidden} hidden)`
  String search_result_count_hide(Object total, Object hidden) {
    return Intl.message(
      'Total $total results ($hidden hidden)',
      name: 'search_result_count_hide',
      desc: '',
      locale: localeName,
      args: [total, hidden],
    );
  }

  /// `Select copy source`
  String get select_copy_plan_source {
    return Intl.message(
      'Select copy source',
      name: 'select_copy_plan_source',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Language`
  String get select_lang {
    return Intl.message(
      'Select Language',
      name: 'select_lang',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Plan`
  String get select_plan {
    return Intl.message(
      'Select Plan',
      name: 'select_plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Send email to`
  String get send_email_to {
    return Intl.message(
      'Send email to',
      name: 'send_email_to',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sending`
  String get sending {
    return Intl.message(
      'Sending',
      name: 'sending',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sending failed`
  String get sending_failed {
    return Intl.message(
      'Sending failed',
      name: 'sending_failed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sent`
  String get sent {
    return Intl.message(
      'Sent',
      name: 'sent',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Servant`
  String get servant {
    return Intl.message(
      'Servant',
      name: 'servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Servant Coin`
  String get servant_coin {
    return Intl.message(
      'Servant Coin',
      name: 'servant_coin',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Servant Detail Page`
  String get servant_detail_page {
    return Intl.message(
      'Servant Detail Page',
      name: 'servant_detail_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Servant List Page`
  String get servant_list_page {
    return Intl.message(
      'Servant List Page',
      name: 'servant_list_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Servant`
  String get servant_title {
    return Intl.message(
      'Servant',
      name: 'servant_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Set Plan Name`
  String get set_plan_name {
    return Intl.message(
      'Set Plan Name',
      name: 'set_plan_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Always On Top`
  String get setting_always_on_top {
    return Intl.message(
      'Always On Top',
      name: 'setting_always_on_top',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto Rotate`
  String get setting_auto_rotate {
    return Intl.message(
      'Auto Rotate',
      name: 'setting_auto_rotate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto Turn on PlanNotReach`
  String get setting_auto_turn_on_plan_not_reach {
    return Intl.message(
      'Auto Turn on PlanNotReach',
      name: 'setting_auto_turn_on_plan_not_reach',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Home-Plan List Page`
  String get setting_home_plan_list_page {
    return Intl.message(
      'Home-Plan List Page',
      name: 'setting_home_plan_list_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only Change 2nd Append Skill`
  String get setting_only_change_second_append_skill {
    return Intl.message(
      'Only Change 2nd Append Skill',
      name: 'setting_only_change_second_append_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Priority Tagging`
  String get setting_priority_tagging {
    return Intl.message(
      'Priority Tagging',
      name: 'setting_priority_tagging',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Servant Class Filter Style`
  String get setting_servant_class_filter_style {
    return Intl.message(
      'Servant Class Filter Style',
      name: 'setting_servant_class_filter_style',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Favorite Button Default`
  String get setting_setting_favorite_button_default {
    return Intl.message(
      'Favorite Button Default',
      name: 'setting_setting_favorite_button_default',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Account at Homepage`
  String get setting_show_account_at_homepage {
    return Intl.message(
      'Show Account at Homepage',
      name: 'setting_show_account_at_homepage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Tabs Sorting`
  String get setting_tabs_sorting {
    return Intl.message(
      'Tabs Sorting',
      name: 'setting_tabs_sorting',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Data`
  String get settings_data {
    return Intl.message(
      'Data',
      name: 'settings_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Data Management`
  String get settings_data_management {
    return Intl.message(
      'Data Management',
      name: 'settings_data_management',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Documents`
  String get settings_documents {
    return Intl.message(
      'Documents',
      name: 'settings_documents',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `General`
  String get settings_general {
    return Intl.message(
      'General',
      name: 'settings_general',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Language`
  String get settings_language {
    return Intl.message(
      'Language',
      name: 'settings_language',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Settings`
  String get settings_tab_name {
    return Intl.message(
      'Settings',
      name: 'settings_tab_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Allow mobile network`
  String get settings_use_mobile_network {
    return Intl.message(
      'Allow mobile network',
      name: 'settings_use_mobile_network',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Backup userdata before upgrading application, and move backups to safe locations outside app's document folder`
  String get settings_userdata_footer {
    return Intl.message(
      'Backup userdata before upgrading application, and move backups to safe locations outside app\'s document folder',
      name: 'settings_userdata_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Frame Rate`
  String get show_frame_rate {
    return Intl.message(
      'Show Frame Rate',
      name: 'show_frame_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Outdated`
  String get show_outdated {
    return Intl.message(
      'Show Outdated',
      name: 'show_outdated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Silver`
  String get silver {
    return Intl.message(
      'Silver',
      name: 'silver',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Simulator`
  String get simulator {
    return Intl.message(
      'Simulator',
      name: 'simulator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skill`
  String get skill {
    return Intl.message(
      'Skill',
      name: 'skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skill Up`
  String get skill_up {
    return Intl.message(
      'Skill Up',
      name: 'skill_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skills Max(310)`
  String get skilled_max10 {
    return Intl.message(
      'Skills Max(310)',
      name: 'skilled_max10',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sprites`
  String get sprites {
    return Intl.message(
      'Sprites',
      name: 'sprites',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Including owned items`
  String get statistics_include_checkbox {
    return Intl.message(
      'Including owned items',
      name: 'statistics_include_checkbox',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Statistics`
  String get statistics_title {
    return Intl.message(
      'Statistics',
      name: 'statistics_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Still Send`
  String get still_send {
    return Intl.message(
      'Still Send',
      name: 'still_send',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Storage Permission`
  String get storage_permission_title {
    return Intl.message(
      'Storage Permission',
      name: 'storage_permission_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Summon`
  String get summon {
    return Intl.message(
      'Summon',
      name: 'summon',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Summon Simulator`
  String get summon_simulator {
    return Intl.message(
      'Summon Simulator',
      name: 'summon_simulator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Summons`
  String get summon_title {
    return Intl.message(
      'Summons',
      name: 'summon_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Support and Donation`
  String get support_chaldea {
    return Intl.message(
      'Support and Donation',
      name: 'support_chaldea',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Support Setup`
  String get support_party {
    return Intl.message(
      'Support Setup',
      name: 'support_party',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Basic Info`
  String get svt_info_tab_base {
    return Intl.message(
      'Basic Info',
      name: 'svt_info_tab_base',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Lore`
  String get svt_info_tab_bond_story {
    return Intl.message(
      'Lore',
      name: 'svt_info_tab_bond_story',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Not favorite`
  String get svt_not_planned {
    return Intl.message(
      'Not favorite',
      name: 'svt_not_planned',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event`
  String get svt_obtain_event {
    return Intl.message(
      'Event',
      name: 'svt_obtain_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `FriendPoint`
  String get svt_obtain_friend_point {
    return Intl.message(
      'FriendPoint',
      name: 'svt_obtain_friend_point',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Initial`
  String get svt_obtain_initial {
    return Intl.message(
      'Initial',
      name: 'svt_obtain_initial',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Limited`
  String get svt_obtain_limited {
    return Intl.message(
      'Limited',
      name: 'svt_obtain_limited',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Summon`
  String get svt_obtain_permanent {
    return Intl.message(
      'Summon',
      name: 'svt_obtain_permanent',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Story`
  String get svt_obtain_story {
    return Intl.message(
      'Story',
      name: 'svt_obtain_story',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unavailable`
  String get svt_obtain_unavailable {
    return Intl.message(
      'Unavailable',
      name: 'svt_obtain_unavailable',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hidden`
  String get svt_plan_hidden {
    return Intl.message(
      'Hidden',
      name: 'svt_plan_hidden',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Related Cards`
  String get svt_related_cards {
    return Intl.message(
      'Related Cards',
      name: 'svt_related_cards',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Reset Plan`
  String get svt_reset_plan {
    return Intl.message(
      'Reset Plan',
      name: 'svt_reset_plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Switch Slider/Dropdown`
  String get svt_switch_slider_dropdown {
    return Intl.message(
      'Switch Slider/Dropdown',
      name: 'svt_switch_slider_dropdown',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sync with {server}`
  String sync_server(Object server) {
    return Intl.message(
      'Sync with $server',
      name: 'sync_server',
      desc: '',
      locale: localeName,
      args: [server],
    );
  }

  /// `Test Info Pad`
  String get test_info_pad {
    return Intl.message(
      'Test Info Pad',
      name: 'test_info_pad',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Toggle Dark Mode`
  String get toogle_dark_mode {
    return Intl.message(
      'Toggle Dark Mode',
      name: 'toogle_dark_mode',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Refresh slides`
  String get tooltip_refresh_sliders {
    return Intl.message(
      'Refresh slides',
      name: 'tooltip_refresh_sliders',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Total AP`
  String get total_ap {
    return Intl.message(
      'Total AP',
      name: 'total_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Total counts`
  String get total_counts {
    return Intl.message(
      'Total counts',
      name: 'total_counts',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Translations`
  String get translations {
    return Intl.message(
      'Translations',
      name: 'translations',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unsupported type`
  String get unsupported_type {
    return Intl.message(
      'Unsupported type',
      name: 'unsupported_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Already the latest version`
  String get update_already_latest {
    return Intl.message(
      'Already the latest version',
      name: 'update_already_latest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Update Dataset`
  String get update_dataset {
    return Intl.message(
      'Update Dataset',
      name: 'update_dataset',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Update Now`
  String get update_now {
    return Intl.message(
      'Update Now',
      name: 'update_now',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Update slides failed\n{e}`
  String update_slides_status_msg_error(Object e) {
    return Intl.message(
      'Update slides failed\n$e',
      name: 'update_slides_status_msg_error',
      desc: '',
      locale: localeName,
      args: [e],
    );
  }

  /// `Not updated`
  String get update_slides_status_msg_info {
    return Intl.message(
      'Not updated',
      name: 'update_slides_status_msg_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Slides updated`
  String get update_slides_status_msg_success {
    return Intl.message(
      'Slides updated',
      name: 'update_slides_status_msg_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Userdata`
  String get userdata {
    return Intl.message(
      'Userdata',
      name: 'userdata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Userdata cleared`
  String get userdata_cleared {
    return Intl.message(
      'Userdata cleared',
      name: 'userdata_cleared',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Download Backup`
  String get userdata_download_backup {
    return Intl.message(
      'Download Backup',
      name: 'userdata_download_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Choose one backup`
  String get userdata_download_choose_backup {
    return Intl.message(
      'Choose one backup',
      name: 'userdata_download_choose_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Data synchronization`
  String get userdata_sync {
    return Intl.message(
      'Data synchronization',
      name: 'userdata_sync',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Upload Backup`
  String get userdata_upload_backup {
    return Intl.message(
      'Upload Backup',
      name: 'userdata_upload_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Valentine craft`
  String get valentine_craft {
    return Intl.message(
      'Valentine craft',
      name: 'valentine_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `View Illustration`
  String get view_illustration {
    return Intl.message(
      'View Illustration',
      name: 'view_illustration',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Voice`
  String get voice {
    return Intl.message(
      'Voice',
      name: 'voice',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Web Renderer`
  String get web_renderer {
    return Intl.message(
      'Web Renderer',
      name: 'web_renderer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{a} {b}`
  String words_separate(Object a, Object b) {
    return Intl.message(
      '$a $b',
      name: 'words_separate',
      desc: '',
      locale: localeName,
      args: [a, b],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      locale: localeName,
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
