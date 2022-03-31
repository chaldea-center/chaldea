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

  /// `简体中文`
  String get language {
    return Intl.message(
      '简体中文',
      name: 'language',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chinese`
  String get language_en {
    return Intl.message(
      'Chinese',
      name: 'language_en',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `关于`
  String get about_app {
    return Intl.message(
      '关于',
      name: 'about_app',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `　本应用所使用数据均来源于游戏及以下网站，游戏图片文本原文等版权属于TYPE MOON/FGO PROJECT。\n　程序功能与界面设计参考微信小程序"素材规划"以及iOS版Guda。`
  String get about_app_declaration_text {
    return Intl.message(
      '　本应用所使用数据均来源于游戏及以下网站，游戏图片文本原文等版权属于TYPE MOON/FGO PROJECT。\n　程序功能与界面设计参考微信小程序"素材规划"以及iOS版Guda。',
      name: 'about_app_declaration_text',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `App Store评分`
  String get about_appstore_rating {
    return Intl.message(
      'App Store评分',
      name: 'about_appstore_rating',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `数据来源`
  String get about_data_source {
    return Intl.message(
      '数据来源',
      name: 'about_data_source',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `若存在未标注的来源或侵权敬请告知`
  String get about_data_source_footer {
    return Intl.message(
      '若存在未标注的来源或侵权敬请告知',
      name: 'about_data_source_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `请将出错页面的截图以及日志文件发送到以下邮箱:\n {email}\n日志文件路径: {logPath}`
  String about_email_dialog(Object email, Object logPath) {
    return Intl.message(
      '请将出错页面的截图以及日志文件发送到以下邮箱:\n $email\n日志文件路径: $logPath',
      name: 'about_email_dialog',
      desc: '',
      locale: localeName,
      args: [email, logPath],
    );
  }

  /// `请附上出错页面截图和日志`
  String get about_email_subtitle {
    return Intl.message(
      '请附上出错页面截图和日志',
      name: 'about_email_subtitle',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `反馈`
  String get about_feedback {
    return Intl.message(
      '反馈',
      name: 'about_feedback',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `应用更新`
  String get about_update_app {
    return Intl.message(
      '应用更新',
      name: 'about_update_app',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `请在App Store中检查更新`
  String get about_update_app_alert_ios_mac {
    return Intl.message(
      '请在App Store中检查更新',
      name: 'about_update_app_alert_ios_mac',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `当前版本: {curVersion}\n最新版本: {newVersion}\n更新内容:\n{releaseNote}`
  String about_update_app_detail(
      Object curVersion, Object newVersion, Object releaseNote) {
    return Intl.message(
      '当前版本: $curVersion\n最新版本: $newVersion\n更新内容:\n$releaseNote',
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

  /// `保有技能`
  String get active_skill {
    return Intl.message(
      '保有技能',
      name: 'active_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `添加`
  String get add {
    return Intl.message(
      '添加',
      name: 'add',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `加入黑名单`
  String get add_to_blacklist {
    return Intl.message(
      '加入黑名单',
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

  /// `AP计算`
  String get ap_calc_title {
    return Intl.message(
      'AP计算',
      name: 'ap_calc_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AP效率`
  String get ap_efficiency {
    return Intl.message(
      'AP效率',
      name: 'ap_efficiency',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AP溢出时间`
  String get ap_overflow_time {
    return Intl.message(
      'AP溢出时间',
      name: 'ap_overflow_time',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `附加技能`
  String get append_skill {
    return Intl.message(
      '附加技能',
      name: 'append_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `附加`
  String get append_skill_short {
    return Intl.message(
      '附加',
      name: 'append_skill_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `灵基`
  String get ascension {
    return Intl.message(
      '灵基',
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

  /// `灵基`
  String get ascension_short {
    return Intl.message(
      '灵基',
      name: 'ascension_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `灵基再临`
  String get ascension_up {
    return Intl.message(
      '灵基再临',
      name: 'ascension_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `附件`
  String get attachment {
    return Intl.message(
      '附件',
      name: 'attachment',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `自动重置`
  String get auto_reset {
    return Intl.message(
      '自动重置',
      name: 'auto_reset',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `自动更新`
  String get auto_update {
    return Intl.message(
      '自动更新',
      name: 'auto_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `备份`
  String get backup {
    return Intl.message(
      '备份',
      name: 'backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `及！时！备！份！`
  String get backup_data_alert {
    return Intl.message(
      '及！时！备！份！',
      name: 'backup_data_alert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `历史备份`
  String get backup_history {
    return Intl.message(
      '历史备份',
      name: 'backup_history',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `备份成功`
  String get backup_success {
    return Intl.message(
      '备份成功',
      name: 'backup_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `黑名单`
  String get blacklist {
    return Intl.message(
      '黑名单',
      name: 'blacklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `羁绊`
  String get bond {
    return Intl.message(
      '羁绊',
      name: 'bond',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `羁绊礼装`
  String get bond_craft {
    return Intl.message(
      '羁绊礼装',
      name: 'bond_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `羁绊效率`
  String get bond_eff {
    return Intl.message(
      '羁绊效率',
      name: 'bond_eff',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bootstrap Page`
  String get boostrap_page_title {
    return Intl.message(
      'Bootstrap Page',
      name: 'boostrap_page_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `铜`
  String get bronze {
    return Intl.message(
      '铜',
      name: 'bronze',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `权重`
  String get calc_weight {
    return Intl.message(
      '权重',
      name: 'calc_weight',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `计算`
  String get calculate {
    return Intl.message(
      '计算',
      name: 'calculate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `计算器`
  String get calculator {
    return Intl.message(
      '计算器',
      name: 'calculator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `纪念活动`
  String get campaign_event {
    return Intl.message(
      '纪念活动',
      name: 'campaign_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `取消`
  String get cancel {
    return Intl.message(
      '取消',
      name: 'cancel',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `解说`
  String get card_description {
    return Intl.message(
      '解说',
      name: 'card_description',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `资料`
  String get card_info {
    return Intl.message(
      '资料',
      name: 'card_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `轮播设置`
  String get carousel_setting {
    return Intl.message(
      '轮播设置',
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

  /// `更新历史`
  String get change_log {
    return Intl.message(
      '更新历史',
      name: 'change_log',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `出场角色`
  String get characters_in_card {
    return Intl.message(
      '出场角色',
      name: 'characters_in_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `检查更新`
  String get check_update {
    return Intl.message(
      '检查更新',
      name: 'check_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `选择Free本`
  String get choose_quest_hint {
    return Intl.message(
      '选择Free本',
      name: 'choose_quest_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `清空`
  String get clear {
    return Intl.message(
      '清空',
      name: 'clear',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `清除缓存`
  String get clear_cache {
    return Intl.message(
      '清除缓存',
      name: 'clear_cache',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `缓存已清理`
  String get clear_cache_finish {
    return Intl.message(
      '缓存已清理',
      name: 'clear_cache_finish',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `包括卡面语音等`
  String get clear_cache_hint {
    return Intl.message(
      '包括卡面语音等',
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

  /// `清空用户数据`
  String get clear_userdata {
    return Intl.message(
      '清空用户数据',
      name: 'clear_userdata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `纹章`
  String get cmd_code_title {
    return Intl.message(
      '纹章',
      name: 'cmd_code_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `指令纹章`
  String get command_code {
    return Intl.message(
      '指令纹章',
      name: 'command_code',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `确定`
  String get confirm {
    return Intl.message(
      '确定',
      name: 'confirm',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已消耗`
  String get consumed {
    return Intl.message(
      '已消耗',
      name: 'consumed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已复制`
  String get copied {
    return Intl.message(
      '已复制',
      name: 'copied',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `复制`
  String get copy {
    return Intl.message(
      '复制',
      name: 'copy',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `拷贝自其它规划`
  String get copy_plan_menu {
    return Intl.message(
      '拷贝自其它规划',
      name: 'copy_plan_menu',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `灵衣`
  String get costume {
    return Intl.message(
      '灵衣',
      name: 'costume',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `灵衣开放`
  String get costume_unlock {
    return Intl.message(
      '灵衣开放',
      name: 'costume_unlock',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `计数`
  String get counts {
    return Intl.message(
      '计数',
      name: 'counts',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `概念礼装`
  String get craft_essence {
    return Intl.message(
      '概念礼装',
      name: 'craft_essence',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `概念礼装`
  String get craft_essence_title {
    return Intl.message(
      '概念礼装',
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

  /// `生成2号机`
  String get create_duplicated_svt {
    return Intl.message(
      '生成2号机',
      name: 'create_duplicated_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `暴击`
  String get critical_attack {
    return Intl.message(
      '暴击',
      name: 'critical_attack',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `当前账号`
  String get cur_account {
    return Intl.message(
      '当前账号',
      name: 'cur_account',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `现有AP`
  String get cur_ap {
    return Intl.message(
      '现有AP',
      name: 'cur_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `当前`
  String get current_ {
    return Intl.message(
      '当前',
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

  /// `深色模式`
  String get dark_mode {
    return Intl.message(
      '深色模式',
      name: 'dark_mode',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `深色`
  String get dark_mode_dark {
    return Intl.message(
      '深色',
      name: 'dark_mode_dark',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `浅色`
  String get dark_mode_light {
    return Intl.message(
      '浅色',
      name: 'dark_mode_light',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `系统`
  String get dark_mode_system {
    return Intl.message(
      '系统',
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

  /// `前往下载页`
  String get dataset_goto_download_page {
    return Intl.message(
      '前往下载页',
      name: 'dataset_goto_download_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载后手动导入`
  String get dataset_goto_download_page_hint {
    return Intl.message(
      '下载后手动导入',
      name: 'dataset_goto_download_page_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `数据管理`
  String get dataset_management {
    return Intl.message(
      '数据管理',
      name: 'dataset_management',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `图片数据包`
  String get dataset_type_image {
    return Intl.message(
      '图片数据包',
      name: 'dataset_type_image',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `文本数据包`
  String get dataset_type_text {
    return Intl.message(
      '文本数据包',
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

  /// `删除`
  String get delete {
    return Intl.message(
      '删除',
      name: 'delete',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `需求`
  String get demands {
    return Intl.message(
      '需求',
      name: 'demands',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `显示设置`
  String get display_setting {
    return Intl.message(
      '显示设置',
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

  /// `下载`
  String get download {
    return Intl.message(
      '下载',
      name: 'download',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载完成`
  String get download_complete {
    return Intl.message(
      '下载完成',
      name: 'download_complete',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载最新数据`
  String get download_full_gamedata {
    return Intl.message(
      '下载最新数据',
      name: 'download_full_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `完整zip数据包`
  String get download_full_gamedata_hint {
    return Intl.message(
      '完整zip数据包',
      name: 'download_full_gamedata_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载最新数据`
  String get download_latest_gamedata {
    return Intl.message(
      '下载最新数据',
      name: 'download_latest_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `为确保兼容性，更新前请升级至最新版APP`
  String get download_latest_gamedata_hint {
    return Intl.message(
      '为确保兼容性，更新前请升级至最新版APP',
      name: 'download_latest_gamedata_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载源`
  String get download_source {
    return Intl.message(
      '下载源',
      name: 'download_source',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `游戏数据和应用更新`
  String get download_source_hint {
    return Intl.message(
      '游戏数据和应用更新',
      name: 'download_source_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `源{name}`
  String download_source_of(Object name) {
    return Intl.message(
      '源$name',
      name: 'download_source_of',
      desc: '',
      locale: localeName,
      args: [name],
    );
  }

  /// `已下载`
  String get downloaded {
    return Intl.message(
      '已下载',
      name: 'downloaded',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载中`
  String get downloading {
    return Intl.message(
      '下载中',
      name: 'downloading',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `点击 + 添加素材`
  String get drop_calc_empty_hint {
    return Intl.message(
      '点击 + 添加素材',
      name: 'drop_calc_empty_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `最低AP`
  String get drop_calc_min_ap {
    return Intl.message(
      '最低AP',
      name: 'drop_calc_min_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `优化`
  String get drop_calc_optimize {
    return Intl.message(
      '优化',
      name: 'drop_calc_optimize',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `求解`
  String get drop_calc_solve {
    return Intl.message(
      '求解',
      name: 'drop_calc_solve',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `掉率`
  String get drop_rate {
    return Intl.message(
      '掉率',
      name: 'drop_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `编辑`
  String get edit {
    return Intl.message(
      '编辑',
      name: 'edit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Buff检索`
  String get effect_search {
    return Intl.message(
      'Buff检索',
      name: 'effect_search',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `效率`
  String get efficiency {
    return Intl.message(
      '效率',
      name: 'efficiency',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `效率类型`
  String get efficiency_type {
    return Intl.message(
      '效率类型',
      name: 'efficiency_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `20AP效率`
  String get efficiency_type_ap {
    return Intl.message(
      '20AP效率',
      name: 'efficiency_type_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `每场掉率`
  String get efficiency_type_drop {
    return Intl.message(
      '每场掉率',
      name: 'efficiency_type_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `敌人一览`
  String get enemy_list {
    return Intl.message(
      '敌人一览',
      name: 'enemy_list',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `强化`
  String get enhance {
    return Intl.message(
      '强化',
      name: 'enhance',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `强化将扣除以下素材`
  String get enhance_warning {
    return Intl.message(
      '强化将扣除以下素材',
      name: 'enhance_warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无网络连接`
  String get error_no_internet {
    return Intl.message(
      '无网络连接',
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

  /// `所有素材添加到素材仓库，并将该活动移出规划`
  String get event_collect_item_confirm {
    return Intl.message(
      '所有素材添加到素材仓库，并将该活动移出规划',
      name: 'event_collect_item_confirm',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `收取素材`
  String get event_collect_items {
    return Intl.message(
      '收取素材',
      name: 'event_collect_items',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `商店/任务/点数/关卡掉落奖励`
  String get event_item_default {
    return Intl.message(
      '商店/任务/点数/关卡掉落奖励',
      name: 'event_item_default',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `额外可获取素材`
  String get event_item_extra {
    return Intl.message(
      '额外可获取素材',
      name: 'event_item_extra',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `最多{n}池`
  String event_lottery_limit_hint(Object n) {
    return Intl.message(
      '最多$n池',
      name: 'event_lottery_limit_hint',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `有限池`
  String get event_lottery_limited {
    return Intl.message(
      '有限池',
      name: 'event_lottery_limited',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `池`
  String get event_lottery_unit {
    return Intl.message(
      '池',
      name: 'event_lottery_unit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无限池`
  String get event_lottery_unlimited {
    return Intl.message(
      '无限池',
      name: 'event_lottery_unlimited',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `活动未列入规划`
  String get event_not_planned {
    return Intl.message(
      '活动未列入规划',
      name: 'event_not_planned',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `进度`
  String get event_progress {
    return Intl.message(
      '进度',
      name: 'event_progress',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `圣杯替换为传承结晶 {n} 个`
  String event_rerun_replace_grail(Object n) {
    return Intl.message(
      '圣杯替换为传承结晶 $n 个',
      name: 'event_rerun_replace_grail',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `活动`
  String get event_title {
    return Intl.message(
      '活动',
      name: 'event_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `素材交换券`
  String get exchange_ticket {
    return Intl.message(
      '素材交换券',
      name: 'exchange_ticket',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `交换券`
  String get exchange_ticket_short {
    return Intl.message(
      '交换券',
      name: 'exchange_ticket_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `等级规划`
  String get exp_card_plan_lv {
    return Intl.message(
      '等级规划',
      name: 'exp_card_plan_lv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `五星狗粮`
  String get exp_card_rarity5 {
    return Intl.message(
      '五星狗粮',
      name: 'exp_card_rarity5',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `相同职阶`
  String get exp_card_same_class {
    return Intl.message(
      '相同职阶',
      name: 'exp_card_same_class',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `选择起始和目标等级`
  String get exp_card_select_lvs {
    return Intl.message(
      '选择起始和目标等级',
      name: 'exp_card_select_lvs',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `狗粮需求`
  String get exp_card_title {
    return Intl.message(
      '狗粮需求',
      name: 'exp_card_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `失败`
  String get failed {
    return Intl.message(
      '失败',
      name: 'failed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `关注`
  String get favorite {
    return Intl.message(
      '关注',
      name: 'favorite',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `添加图像或文件附件`
  String get feedback_add_attachments {
    return Intl.message(
      '添加图像或文件附件',
      name: 'feedback_add_attachments',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `添加崩溃日志`
  String get feedback_add_crash_log {
    return Intl.message(
      '添加崩溃日志',
      name: 'feedback_add_crash_log',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `联系方式`
  String get feedback_contact {
    return Intl.message(
      '联系方式',
      name: 'feedback_contact',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `反馈与建议`
  String get feedback_content_hint {
    return Intl.message(
      '反馈与建议',
      name: 'feedback_content_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `发送`
  String get feedback_send {
    return Intl.message(
      '发送',
      name: 'feedback_send',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `主题`
  String get feedback_subject {
    return Intl.message(
      '主题',
      name: 'feedback_subject',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `背景`
  String get ffo_background {
    return Intl.message(
      '背景',
      name: 'ffo_background',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `身体`
  String get ffo_body {
    return Intl.message(
      '身体',
      name: 'ffo_body',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `裁剪`
  String get ffo_crop {
    return Intl.message(
      '裁剪',
      name: 'ffo_crop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `头部`
  String get ffo_head {
    return Intl.message(
      '头部',
      name: 'ffo_head',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `请先下载或导入FFO资源包↗`
  String get ffo_missing_data_hint {
    return Intl.message(
      '请先下载或导入FFO资源包↗',
      name: 'ffo_missing_data_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `同一从者`
  String get ffo_same_svt {
    return Intl.message(
      '同一从者',
      name: 'ffo_same_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `效率剧场`
  String get fgo_domus_aurea {
    return Intl.message(
      '效率剧场',
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

  /// `文件名`
  String get filename {
    return Intl.message(
      '文件名',
      name: 'filename',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `筛选`
  String get filter {
    return Intl.message(
      '筛选',
      name: 'filter',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `属性`
  String get filter_atk_hp_type {
    return Intl.message(
      '属性',
      name: 'filter_atk_hp_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `阵营`
  String get filter_attribute {
    return Intl.message(
      '阵营',
      name: 'filter_attribute',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `分类`
  String get filter_category {
    return Intl.message(
      '分类',
      name: 'filter_category',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `效果`
  String get filter_effects {
    return Intl.message(
      '效果',
      name: 'filter_effects',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `性别`
  String get filter_gender {
    return Intl.message(
      '性别',
      name: 'filter_gender',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `全匹配`
  String get filter_match_all {
    return Intl.message(
      '全匹配',
      name: 'filter_match_all',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `获取方式`
  String get filter_obtain {
    return Intl.message(
      '获取方式',
      name: 'filter_obtain',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `未满`
  String get filter_plan_not_reached {
    return Intl.message(
      '未满',
      name: 'filter_plan_not_reached',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已满`
  String get filter_plan_reached {
    return Intl.message(
      '已满',
      name: 'filter_plan_reached',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `反向匹配`
  String get filter_revert {
    return Intl.message(
      '反向匹配',
      name: 'filter_revert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `显示`
  String get filter_shown_type {
    return Intl.message(
      '显示',
      name: 'filter_shown_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `技能练度`
  String get filter_skill_lv {
    return Intl.message(
      '技能练度',
      name: 'filter_skill_lv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `排序`
  String get filter_sort {
    return Intl.message(
      '排序',
      name: 'filter_sort',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `职阶`
  String get filter_sort_class {
    return Intl.message(
      '职阶',
      name: 'filter_sort_class',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `序号`
  String get filter_sort_number {
    return Intl.message(
      '序号',
      name: 'filter_sort_number',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `星级`
  String get filter_sort_rarity {
    return Intl.message(
      '星级',
      name: 'filter_sort_rarity',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `特殊特性`
  String get filter_special_trait {
    return Intl.message(
      '特殊特性',
      name: 'filter_special_trait',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free效率`
  String get free_efficiency {
    return Intl.message(
      'Free效率',
      name: 'free_efficiency',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free进度`
  String get free_progress {
    return Intl.message(
      'Free进度',
      name: 'free_progress',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `日服最新`
  String get free_progress_newest {
    return Intl.message(
      '日服最新',
      name: 'free_progress_newest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free本`
  String get free_quest {
    return Intl.message(
      'Free本',
      name: 'free_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free速查`
  String get free_quest_calculator {
    return Intl.message(
      'Free速查',
      name: 'free_quest_calculator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Free速查`
  String get free_quest_calculator_short {
    return Intl.message(
      'Free速查',
      name: 'free_quest_calculator_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `首页`
  String get gallery_tab_name {
    return Intl.message(
      '首页',
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

  /// `掉落`
  String get game_drop {
    return Intl.message(
      '掉落',
      name: 'game_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `经验`
  String get game_experience {
    return Intl.message(
      '经验',
      name: 'game_experience',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `羁绊`
  String get game_kizuna {
    return Intl.message(
      '羁绊',
      name: 'game_kizuna',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `通关奖励`
  String get game_rewards {
    return Intl.message(
      '通关奖励',
      name: 'game_rewards',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `服务器`
  String get game_server {
    return Intl.message(
      '服务器',
      name: 'game_server',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `国服`
  String get game_server_cn {
    return Intl.message(
      '国服',
      name: 'game_server_cn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `日服`
  String get game_server_jp {
    return Intl.message(
      '日服',
      name: 'game_server_jp',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `美服`
  String get game_server_na {
    return Intl.message(
      '美服',
      name: 'game_server_na',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `台服`
  String get game_server_tw {
    return Intl.message(
      '台服',
      name: 'game_server_tw',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `游戏数据`
  String get gamedata {
    return Intl.message(
      '游戏数据',
      name: 'gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `金`
  String get gold {
    return Intl.message(
      '金',
      name: 'gold',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `圣杯`
  String get grail {
    return Intl.message(
      '圣杯',
      name: 'grail',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `圣杯等级`
  String get grail_level {
    return Intl.message(
      '圣杯等级',
      name: 'grail_level',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `圣杯转临`
  String get grail_up {
    return Intl.message(
      '圣杯转临',
      name: 'grail_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `成长曲线`
  String get growth_curve {
    return Intl.message(
      '成长曲线',
      name: 'growth_curve',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Guda素材数据`
  String get guda_item_data {
    return Intl.message(
      'Guda素材数据',
      name: 'guda_item_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Guda从者数据`
  String get guda_servant_data {
    return Intl.message(
      'Guda从者数据',
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

  /// `你好！御主!`
  String get hello {
    return Intl.message(
      '你好！御主!',
      name: 'hello',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `帮助`
  String get help {
    return Intl.message(
      '帮助',
      name: 'help',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `隐藏已过期`
  String get hide_outdated {
    return Intl.message(
      '隐藏已过期',
      name: 'hide_outdated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无羁绊礼装`
  String get hint_no_bond_craft {
    return Intl.message(
      '无羁绊礼装',
      name: 'hint_no_bond_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无情人节礼装`
  String get hint_no_valentine_craft {
    return Intl.message(
      '无情人节礼装',
      name: 'hint_no_valentine_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `图标`
  String get icons {
    return Intl.message(
      '图标',
      name: 'icons',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `忽略`
  String get ignore {
    return Intl.message(
      '忽略',
      name: 'ignore',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `卡面`
  String get illustration {
    return Intl.message(
      '卡面',
      name: 'illustration',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `画师`
  String get illustrator {
    return Intl.message(
      '画师',
      name: 'illustrator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `图像解析`
  String get image_analysis {
    return Intl.message(
      '图像解析',
      name: 'image_analysis',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入`
  String get import_data {
    return Intl.message(
      '导入',
      name: 'import_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入失败，Error:\n{error}`
  String import_data_error(Object error) {
    return Intl.message(
      '导入失败，Error:\n$error',
      name: 'import_data_error',
      desc: '',
      locale: localeName,
      args: [error],
    );
  }

  /// `成功导入数据`
  String get import_data_success {
    return Intl.message(
      '成功导入数据',
      name: 'import_data_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入Guda`
  String get import_guda_data {
    return Intl.message(
      '导入Guda',
      name: 'import_guda_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据`
  String get import_guda_hint {
    return Intl.message(
      '更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据',
      name: 'import_guda_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入素材`
  String get import_guda_items {
    return Intl.message(
      '导入素材',
      name: 'import_guda_items',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入从者`
  String get import_guda_servants {
    return Intl.message(
      '导入从者',
      name: 'import_guda_servants',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `允许2号机`
  String get import_http_body_duplicated {
    return Intl.message(
      '允许2号机',
      name: 'import_http_body_duplicated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `点击右上角导入解密的HTTPS响应包以导入账户数据\n点击帮助以查看如何捕获并解密HTTPS响应内容`
  String get import_http_body_hint {
    return Intl.message(
      '点击右上角导入解密的HTTPS响应包以导入账户数据\n点击帮助以查看如何捕获并解密HTTPS响应内容',
      name: 'import_http_body_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `点击从者可隐藏/取消隐藏该从者`
  String get import_http_body_hint_hide {
    return Intl.message(
      '点击从者可隐藏/取消隐藏该从者',
      name: 'import_http_body_hint_hide',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `仅锁定`
  String get import_http_body_locked {
    return Intl.message(
      '仅锁定',
      name: 'import_http_body_locked',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已切换到账号{account}`
  String import_http_body_success_switch(Object account) {
    return Intl.message(
      '已切换到账号$account',
      name: 'import_http_body_success_switch',
      desc: '',
      locale: localeName,
      args: [account],
    );
  }

  /// `导入{itemNum}个素材,{svtNum}从者到`
  String import_http_body_target_account_header(Object itemNum, Object svtNum) {
    return Intl.message(
      '导入$itemNum个素材,$svtNum从者到',
      name: 'import_http_body_target_account_header',
      desc: '',
      locale: localeName,
      args: [itemNum, svtNum],
    );
  }

  /// `导入截图`
  String get import_screenshot {
    return Intl.message(
      '导入截图',
      name: 'import_screenshot',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `仅更新识别出的素材`
  String get import_screenshot_hint {
    return Intl.message(
      '仅更新识别出的素材',
      name: 'import_screenshot_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `更新素材`
  String get import_screenshot_update_items {
    return Intl.message(
      '更新素材',
      name: 'import_screenshot_update_items',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入源数据`
  String get import_source_file {
    return Intl.message(
      '导入源数据',
      name: 'import_source_file',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `敏捷`
  String get info_agility {
    return Intl.message(
      '敏捷',
      name: 'info_agility',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `属性`
  String get info_alignment {
    return Intl.message(
      '属性',
      name: 'info_alignment',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `羁绊点数`
  String get info_bond_points {
    return Intl.message(
      '羁绊点数',
      name: 'info_bond_points',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `点数`
  String get info_bond_points_single {
    return Intl.message(
      '点数',
      name: 'info_bond_points_single',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `累积`
  String get info_bond_points_sum {
    return Intl.message(
      '累积',
      name: 'info_bond_points_sum',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `配卡`
  String get info_cards {
    return Intl.message(
      '配卡',
      name: 'info_cards',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `暴击权重`
  String get info_critical_rate {
    return Intl.message(
      '暴击权重',
      name: 'info_critical_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `声优`
  String get info_cv {
    return Intl.message(
      '声优',
      name: 'info_cv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `即死率`
  String get info_death_rate {
    return Intl.message(
      '即死率',
      name: 'info_death_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `耐久`
  String get info_endurance {
    return Intl.message(
      '耐久',
      name: 'info_endurance',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `性别`
  String get info_gender {
    return Intl.message(
      '性别',
      name: 'info_gender',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `身高`
  String get info_height {
    return Intl.message(
      '身高',
      name: 'info_height',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `人形`
  String get info_human {
    return Intl.message(
      '人形',
      name: 'info_human',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `幸运`
  String get info_luck {
    return Intl.message(
      '幸运',
      name: 'info_luck',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `魔力`
  String get info_mana {
    return Intl.message(
      '魔力',
      name: 'info_mana',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `宝具`
  String get info_np {
    return Intl.message(
      '宝具',
      name: 'info_np',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP获得率`
  String get info_np_rate {
    return Intl.message(
      'NP获得率',
      name: 'info_np_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `出星率`
  String get info_star_rate {
    return Intl.message(
      '出星率',
      name: 'info_star_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `筋力`
  String get info_strength {
    return Intl.message(
      '筋力',
      name: 'info_strength',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `特性`
  String get info_trait {
    return Intl.message(
      '特性',
      name: 'info_trait',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `数值`
  String get info_value {
    return Intl.message(
      '数值',
      name: 'info_value',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `被EA特攻`
  String get info_weak_to_ea {
    return Intl.message(
      '被EA特攻',
      name: 'info_weak_to_ea',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `体重`
  String get info_weight {
    return Intl.message(
      '体重',
      name: 'info_weight',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `输入无效`
  String get input_invalid_hint {
    return Intl.message(
      '输入无效',
      name: 'input_invalid_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `安装`
  String get install {
    return Intl.message(
      '安装',
      name: 'install',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `幕间&强化`
  String get interlude_and_rankup {
    return Intl.message(
      '幕间&强化',
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

  /// `"文件"应用/我的iPhone/Chaldea`
  String get ios_app_path {
    return Intl.message(
      '"文件"应用/我的iPhone/Chaldea',
      name: 'ios_app_path',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `常见问题`
  String get issues {
    return Intl.message(
      '常见问题',
      name: 'issues',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `素材`
  String get item {
    return Intl.message(
      '素材',
      name: 'item',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{name}已存在`
  String item_already_exist_hint(Object name) {
    return Intl.message(
      '$name已存在',
      name: 'item_already_exist_hint',
      desc: '',
      locale: localeName,
      args: [name],
    );
  }

  /// `职阶棋子`
  String get item_category_ascension {
    return Intl.message(
      '职阶棋子',
      name: 'item_category_ascension',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `铜素材`
  String get item_category_bronze {
    return Intl.message(
      '铜素材',
      name: 'item_category_bronze',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `活动从者灵基再临素材`
  String get item_category_event_svt_ascension {
    return Intl.message(
      '活动从者灵基再临素材',
      name: 'item_category_event_svt_ascension',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `辉石`
  String get item_category_gem {
    return Intl.message(
      '辉石',
      name: 'item_category_gem',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `技能石`
  String get item_category_gems {
    return Intl.message(
      '技能石',
      name: 'item_category_gems',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `金素材`
  String get item_category_gold {
    return Intl.message(
      '金素材',
      name: 'item_category_gold',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `魔石`
  String get item_category_magic_gem {
    return Intl.message(
      '魔石',
      name: 'item_category_magic_gem',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `金像`
  String get item_category_monument {
    return Intl.message(
      '金像',
      name: 'item_category_monument',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `其他`
  String get item_category_others {
    return Intl.message(
      '其他',
      name: 'item_category_others',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `银棋`
  String get item_category_piece {
    return Intl.message(
      '银棋',
      name: 'item_category_piece',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `秘石`
  String get item_category_secret_gem {
    return Intl.message(
      '秘石',
      name: 'item_category_secret_gem',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `银素材`
  String get item_category_silver {
    return Intl.message(
      '银素材',
      name: 'item_category_silver',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `特殊素材`
  String get item_category_special {
    return Intl.message(
      '特殊素材',
      name: 'item_category_special',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `普通素材`
  String get item_category_usual {
    return Intl.message(
      '普通素材',
      name: 'item_category_usual',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `素材效率`
  String get item_eff {
    return Intl.message(
      '素材效率',
      name: 'item_eff',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `计算规划前，可以设置不同材料的富余量(仅用于Free本规划)`
  String get item_exceed_hint {
    return Intl.message(
      '计算规划前，可以设置不同材料的富余量(仅用于Free本规划)',
      name: 'item_exceed_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `剩余`
  String get item_left {
    return Intl.message(
      '剩余',
      name: 'item_left',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无Free本`
  String get item_no_free_quests {
    return Intl.message(
      '无Free本',
      name: 'item_no_free_quests',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `仅显示不足`
  String get item_only_show_lack {
    return Intl.message(
      '仅显示不足',
      name: 'item_only_show_lack',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `拥有`
  String get item_own {
    return Intl.message(
      '拥有',
      name: 'item_own',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `素材截图`
  String get item_screenshot {
    return Intl.message(
      '素材截图',
      name: 'item_screenshot',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `素材`
  String get item_title {
    return Intl.message(
      '素材',
      name: 'item_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `共需`
  String get item_total_demand {
    return Intl.message(
      '共需',
      name: 'item_total_demand',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `加入Beta版`
  String get join_beta {
    return Intl.message(
      '加入Beta版',
      name: 'join_beta',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `跳转到{site}`
  String jump_to(Object site) {
    return Intl.message(
      '跳转到$site',
      name: 'jump_to',
      desc: '',
      locale: localeName,
      args: [site],
    );
  }

  /// `等级`
  String get level {
    return Intl.message(
      '等级',
      name: 'level',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `限时活动`
  String get limited_event {
    return Intl.message(
      '限时活动',
      name: 'limited_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `链接`
  String get link {
    return Intl.message(
      '链接',
      name: 'link',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{first, select, true{已经是第一张} false{已经是最后一张} other{已经到头了}}`
  String list_end_hint(Object first) {
    return Intl.select(
      first,
      {
        'true': '已经是第一张',
        'false': '已经是最后一张',
        'other': '已经到头了',
      },
      name: 'list_end_hint',
      desc: '',
      locale: localeName,
      args: [first],
    );
  }

  /// `加载数据出错`
  String get load_dataset_error {
    return Intl.message(
      '加载数据出错',
      name: 'load_dataset_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `请在设置-游戏数据中重新加载默认资源`
  String get load_dataset_error_hint {
    return Intl.message(
      '请在设置-游戏数据中重新加载默认资源',
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

  /// `修改密码`
  String get login_change_password {
    return Intl.message(
      '修改密码',
      name: 'login_change_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `请先登陆`
  String get login_first_hint {
    return Intl.message(
      '请先登陆',
      name: 'login_first_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `忘记密码`
  String get login_forget_pwd {
    return Intl.message(
      '忘记密码',
      name: 'login_forget_pwd',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `登陆`
  String get login_login {
    return Intl.message(
      '登陆',
      name: 'login_login',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `登出`
  String get login_logout {
    return Intl.message(
      '登出',
      name: 'login_logout',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `新密码`
  String get login_new_password {
    return Intl.message(
      '新密码',
      name: 'login_new_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `密码`
  String get login_password {
    return Intl.message(
      '密码',
      name: 'login_password',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `只能包含字母与数字，不少于4位`
  String get login_password_error {
    return Intl.message(
      '只能包含字母与数字，不少于4位',
      name: 'login_password_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `不能与旧密码相同`
  String get login_password_error_same_as_old {
    return Intl.message(
      '不能与旧密码相同',
      name: 'login_password_error_same_as_old',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `注册`
  String get login_signup {
    return Intl.message(
      '注册',
      name: 'login_signup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `未登录`
  String get login_state_not_login {
    return Intl.message(
      '未登录',
      name: 'login_state_not_login',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `用户名`
  String get login_username {
    return Intl.message(
      '用户名',
      name: 'login_username',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `只能包含字母与数字，字母开头，不少于4位`
  String get login_username_error {
    return Intl.message(
      '只能包含字母与数字，字母开头，不少于4位',
      name: 'login_username_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `长按保存`
  String get long_press_to_save_hint {
    return Intl.message(
      '长按保存',
      name: 'long_press_to_save_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `福袋`
  String get lucky_bag {
    return Intl.message(
      '福袋',
      name: 'lucky_bag',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `主线记录`
  String get main_record {
    return Intl.message(
      '主线记录',
      name: 'main_record',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `通关奖励`
  String get main_record_bonus {
    return Intl.message(
      '通关奖励',
      name: 'main_record_bonus',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `奖励`
  String get main_record_bonus_short {
    return Intl.message(
      '奖励',
      name: 'main_record_bonus_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `章节`
  String get main_record_chapter {
    return Intl.message(
      '章节',
      name: 'main_record_chapter',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `固定掉落`
  String get main_record_fixed_drop {
    return Intl.message(
      '固定掉落',
      name: 'main_record_fixed_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `掉落`
  String get main_record_fixed_drop_short {
    return Intl.message(
      '掉落',
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

  /// `御主任务`
  String get master_mission {
    return Intl.message(
      '御主任务',
      name: 'master_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `关联关卡`
  String get master_mission_related_quest {
    return Intl.message(
      '关联关卡',
      name: 'master_mission_related_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `方案`
  String get master_mission_solution {
    return Intl.message(
      '方案',
      name: 'master_mission_solution',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `任务列表`
  String get master_mission_tasklist {
    return Intl.message(
      '任务列表',
      name: 'master_mission_tasklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `最大AP`
  String get max_ap {
    return Intl.message(
      '最大AP',
      name: 'max_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `更多`
  String get more {
    return Intl.message(
      '更多',
      name: 'more',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下移`
  String get move_down {
    return Intl.message(
      '下移',
      name: 'move_down',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `上移`
  String get move_up {
    return Intl.message(
      '上移',
      name: 'move_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `魔术礼装`
  String get mystic_code {
    return Intl.message(
      '魔术礼装',
      name: 'mystic_code',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `新建账号`
  String get new_account {
    return Intl.message(
      '新建账号',
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

  /// `下一张`
  String get next_card {
    return Intl.message(
      '下一张',
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

  /// `否`
  String get no {
    return Intl.message(
      '否',
      name: 'no',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无幕间或强化关卡`
  String get no_servant_quest_hint {
    return Intl.message(
      '无幕间或强化关卡',
      name: 'no_servant_quest_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `点击♡查看所有从者任务`
  String get no_servant_quest_hint_subtitle {
    return Intl.message(
      '点击♡查看所有从者任务',
      name: 'no_servant_quest_hint_subtitle',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `宝具`
  String get noble_phantasm {
    return Intl.message(
      '宝具',
      name: 'noble_phantasm',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `宝具等级`
  String get noble_phantasm_level {
    return Intl.message(
      '宝具等级',
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

  /// `尚未实现`
  String get not_implemented {
    return Intl.message(
      '尚未实现',
      name: 'not_implemented',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `获取方式`
  String get obtain_methods {
    return Intl.message(
      '获取方式',
      name: 'obtain_methods',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `确定`
  String get ok {
    return Intl.message(
      '确定',
      name: 'ok',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `打开`
  String get open {
    return Intl.message(
      '打开',
      name: 'open',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `开发条件`
  String get open_condition {
    return Intl.message(
      '开发条件',
      name: 'open_condition',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `概览`
  String get overview {
    return Intl.message(
      '概览',
      name: 'overview',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `覆盖`
  String get overwrite {
    return Intl.message(
      '覆盖',
      name: 'overwrite',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `被动技能`
  String get passive_skill {
    return Intl.message(
      '被动技能',
      name: 'passive_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `更新游戏数据`
  String get patch_gamedata {
    return Intl.message(
      '更新游戏数据',
      name: 'patch_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `找不到兼容此APP版本的数据版本`
  String get patch_gamedata_error_no_compatible {
    return Intl.message(
      '找不到兼容此APP版本的数据版本',
      name: 'patch_gamedata_error_no_compatible',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `服务器不存在当前版本，下载完整版资源ing`
  String get patch_gamedata_error_unknown_version {
    return Intl.message(
      '服务器不存在当前版本，下载完整版资源ing',
      name: 'patch_gamedata_error_unknown_version',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `打补丁`
  String get patch_gamedata_hint {
    return Intl.message(
      '打补丁',
      name: 'patch_gamedata_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已更新数据版本至{version}`
  String patch_gamedata_success_to(Object version) {
    return Intl.message(
      '已更新数据版本至$version',
      name: 'patch_gamedata_success_to',
      desc: '',
      locale: localeName,
      args: [version],
    );
  }

  /// `规划`
  String get plan {
    return Intl.message(
      '规划',
      name: 'plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `规划最大化(310)`
  String get plan_max10 {
    return Intl.message(
      '规划最大化(310)',
      name: 'plan_max10',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `规划最大化(999)`
  String get plan_max9 {
    return Intl.message(
      '规划最大化(999)',
      name: 'plan_max9',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `规划目标`
  String get plan_objective {
    return Intl.message(
      '规划目标',
      name: 'plan_objective',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `规划`
  String get plan_title {
    return Intl.message(
      '规划',
      name: 'plan_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `规划{index}`
  String plan_x(Object index) {
    return Intl.message(
      '规划$index',
      name: 'plan_x',
      desc: '',
      locale: localeName,
      args: [index],
    );
  }

  /// `规划Free本`
  String get planning_free_quest_btn {
    return Intl.message(
      '规划Free本',
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

  /// `预览`
  String get preview {
    return Intl.message(
      '预览',
      name: 'preview',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `上一张`
  String get previous_card {
    return Intl.message(
      '上一张',
      name: 'previous_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `优先级`
  String get priority {
    return Intl.message(
      '优先级',
      name: 'priority',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `项目主页`
  String get project_homepage {
    return Intl.message(
      '项目主页',
      name: 'project_homepage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `查询失败`
  String get query_failed {
    return Intl.message(
      '查询失败',
      name: 'query_failed',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `关卡`
  String get quest {
    return Intl.message(
      '关卡',
      name: 'quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `开放条件`
  String get quest_condition {
    return Intl.message(
      '开放条件',
      name: 'quest_condition',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `稀有度`
  String get rarity {
    return Intl.message(
      '稀有度',
      name: 'rarity',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `App Store评分`
  String get rate_app_store {
    return Intl.message(
      'App Store评分',
      name: 'rate_app_store',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Google Play评分`
  String get rate_play_store {
    return Intl.message(
      'Google Play评分',
      name: 'rate_play_store',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载页`
  String get release_page {
    return Intl.message(
      '下载页',
      name: 'release_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入成功`
  String get reload_data_success {
    return Intl.message(
      '导入成功',
      name: 'reload_data_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `重新载入预装版本`
  String get reload_default_gamedata {
    return Intl.message(
      '重新载入预装版本',
      name: 'reload_default_gamedata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `导入中`
  String get reloading_data {
    return Intl.message(
      '导入中',
      name: 'reloading_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `销毁2号机`
  String get remove_duplicated_svt {
    return Intl.message(
      '销毁2号机',
      name: 'remove_duplicated_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `移出黑名单`
  String get remove_from_blacklist {
    return Intl.message(
      '移出黑名单',
      name: 'remove_from_blacklist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `重命名`
  String get rename {
    return Intl.message(
      '重命名',
      name: 'rename',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `复刻活动`
  String get rerun_event {
    return Intl.message(
      '复刻活动',
      name: 'rerun_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `重置`
  String get reset {
    return Intl.message(
      '重置',
      name: 'reset',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `重置规划{n}(所有)`
  String reset_plan_all(Object n) {
    return Intl.message(
      '重置规划$n(所有)',
      name: 'reset_plan_all',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `重置规划{n}(已显示)`
  String reset_plan_shown(Object n) {
    return Intl.message(
      '重置规划$n(已显示)',
      name: 'reset_plan_shown',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `已重置`
  String get reset_success {
    return Intl.message(
      '已重置',
      name: 'reset_success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `重置强化本状态`
  String get reset_svt_enhance_state {
    return Intl.message(
      '重置强化本状态',
      name: 'reset_svt_enhance_state',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `宝具本/技能本恢复成国服状态`
  String get reset_svt_enhance_state_hint {
    return Intl.message(
      '宝具本/技能本恢复成国服状态',
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

  /// `重启以更新应用，若更新失败，请手动复制source文件夹到destination`
  String get restart_to_upgrade_hint {
    return Intl.message(
      '重启以更新应用，若更新失败，请手动复制source文件夹到destination',
      name: 'restart_to_upgrade_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `恢复`
  String get restore {
    return Intl.message(
      '恢复',
      name: 'restore',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `攒石`
  String get saint_quartz_plan {
    return Intl.message(
      '攒石',
      name: 'saint_quartz_plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `保存`
  String get save {
    return Intl.message(
      '保存',
      name: 'save',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `保存到相册`
  String get save_to_photos {
    return Intl.message(
      '保存到相册',
      name: 'save_to_photos',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已保存`
  String get saved {
    return Intl.message(
      '已保存',
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

  /// `搜索`
  String get search {
    return Intl.message(
      '搜索',
      name: 'search',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `基础信息`
  String get search_option_basic {
    return Intl.message(
      '基础信息',
      name: 'search_option_basic',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `搜索范围`
  String get search_options {
    return Intl.message(
      '搜索范围',
      name: 'search_options',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `总计: {total}`
  String search_result_count(Object total) {
    return Intl.message(
      '总计: $total',
      name: 'search_result_count',
      desc: '',
      locale: localeName,
      args: [total],
    );
  }

  /// `总计: {total} (隐藏: {hidden})`
  String search_result_count_hide(Object total, Object hidden) {
    return Intl.message(
      '总计: $total (隐藏: $hidden)',
      name: 'search_result_count_hide',
      desc: '',
      locale: localeName,
      args: [total, hidden],
    );
  }

  /// `选择复制来源`
  String get select_copy_plan_source {
    return Intl.message(
      '选择复制来源',
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

  /// `选择规划`
  String get select_plan {
    return Intl.message(
      '选择规划',
      name: 'select_plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `从者`
  String get servant {
    return Intl.message(
      '从者',
      name: 'servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `从者硬币`
  String get servant_coin {
    return Intl.message(
      '从者硬币',
      name: 'servant_coin',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `从者详情页`
  String get servant_detail_page {
    return Intl.message(
      '从者详情页',
      name: 'servant_detail_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `从者列表页`
  String get servant_list_page {
    return Intl.message(
      '从者列表页',
      name: 'servant_list_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `从者`
  String get servant_title {
    return Intl.message(
      '从者',
      name: 'servant_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `设置规划名称`
  String get set_plan_name {
    return Intl.message(
      '设置规划名称',
      name: 'set_plan_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `置顶显示`
  String get setting_always_on_top {
    return Intl.message(
      '置顶显示',
      name: 'setting_always_on_top',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `自动旋转`
  String get setting_auto_rotate {
    return Intl.message(
      '自动旋转',
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

  /// `首页-规划列表页`
  String get setting_home_plan_list_page {
    return Intl.message(
      '首页-规划列表页',
      name: 'setting_home_plan_list_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `仅更改附加技能2`
  String get setting_only_change_second_append_skill {
    return Intl.message(
      '仅更改附加技能2',
      name: 'setting_only_change_second_append_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Plans List Page`
  String get setting_plans_list_page {
    return Intl.message(
      'Plans List Page',
      name: 'setting_plans_list_page',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `优先级备注`
  String get setting_priority_tagging {
    return Intl.message(
      '优先级备注',
      name: 'setting_priority_tagging',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `从者职阶筛选样式`
  String get setting_servant_class_filter_style {
    return Intl.message(
      '从者职阶筛选样式',
      name: 'setting_servant_class_filter_style',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `「关注」按钮默认筛选`
  String get setting_setting_favorite_button_default {
    return Intl.message(
      '「关注」按钮默认筛选',
      name: 'setting_setting_favorite_button_default',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `首页显示当前账号`
  String get setting_show_account_at_homepage {
    return Intl.message(
      '首页显示当前账号',
      name: 'setting_show_account_at_homepage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `标签页排序`
  String get setting_tabs_sorting {
    return Intl.message(
      '标签页排序',
      name: 'setting_tabs_sorting',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `数据`
  String get settings_data {
    return Intl.message(
      '数据',
      name: 'settings_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `数据管理`
  String get settings_data_management {
    return Intl.message(
      '数据管理',
      name: 'settings_data_management',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `使用文档`
  String get settings_documents {
    return Intl.message(
      '使用文档',
      name: 'settings_documents',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `通用`
  String get settings_general {
    return Intl.message(
      '通用',
      name: 'settings_general',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `语言`
  String get settings_language {
    return Intl.message(
      '语言',
      name: 'settings_language',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `设置`
  String get settings_tab_name {
    return Intl.message(
      '设置',
      name: 'settings_tab_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `使用移动数据下载`
  String get settings_use_mobile_network {
    return Intl.message(
      '使用移动数据下载',
      name: 'settings_use_mobile_network',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置`
  String get settings_userdata_footer {
    return Intl.message(
      '更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置',
      name: 'settings_userdata_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `分享`
  String get share {
    return Intl.message(
      '分享',
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

  /// `显示已过期`
  String get show_outdated {
    return Intl.message(
      '显示已过期',
      name: 'show_outdated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `银`
  String get silver {
    return Intl.message(
      '银',
      name: 'silver',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `模拟器`
  String get simulator {
    return Intl.message(
      '模拟器',
      name: 'simulator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `技能`
  String get skill {
    return Intl.message(
      '技能',
      name: 'skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `技能升级`
  String get skill_up {
    return Intl.message(
      '技能升级',
      name: 'skill_up',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `练度最大化(310)`
  String get skilled_max10 {
    return Intl.message(
      '练度最大化(310)',
      name: 'skilled_max10',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `模型`
  String get sprites {
    return Intl.message(
      '模型',
      name: 'sprites',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `包含现有素材`
  String get statistics_include_checkbox {
    return Intl.message(
      '包含现有素材',
      name: 'statistics_include_checkbox',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `统计`
  String get statistics_title {
    return Intl.message(
      '统计',
      name: 'statistics_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `储存权限`
  String get storage_permission_title {
    return Intl.message(
      '储存权限',
      name: 'storage_permission_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `成功`
  String get success {
    return Intl.message(
      '成功',
      name: 'success',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `卡池`
  String get summon {
    return Intl.message(
      '卡池',
      name: 'summon',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `抽卡模拟器`
  String get summon_simulator {
    return Intl.message(
      '抽卡模拟器',
      name: 'summon_simulator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `卡池一览`
  String get summon_title {
    return Intl.message(
      '卡池一览',
      name: 'summon_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `支持与捐赠`
  String get support_chaldea {
    return Intl.message(
      '支持与捐赠',
      name: 'support_chaldea',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `助战编制`
  String get support_party {
    return Intl.message(
      '助战编制',
      name: 'support_party',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `基础资料`
  String get svt_info_tab_base {
    return Intl.message(
      '基础资料',
      name: 'svt_info_tab_base',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `羁绊故事`
  String get svt_info_tab_bond_story {
    return Intl.message(
      '羁绊故事',
      name: 'svt_info_tab_bond_story',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `未关注`
  String get svt_not_planned {
    return Intl.message(
      '未关注',
      name: 'svt_not_planned',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `活动赠送`
  String get svt_obtain_event {
    return Intl.message(
      '活动赠送',
      name: 'svt_obtain_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `友情点召唤`
  String get svt_obtain_friend_point {
    return Intl.message(
      '友情点召唤',
      name: 'svt_obtain_friend_point',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `初始获得`
  String get svt_obtain_initial {
    return Intl.message(
      '初始获得',
      name: 'svt_obtain_initial',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `期间限定`
  String get svt_obtain_limited {
    return Intl.message(
      '期间限定',
      name: 'svt_obtain_limited',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `圣晶石常驻`
  String get svt_obtain_permanent {
    return Intl.message(
      '圣晶石常驻',
      name: 'svt_obtain_permanent',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `剧情限定`
  String get svt_obtain_story {
    return Intl.message(
      '剧情限定',
      name: 'svt_obtain_story',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `无法召唤`
  String get svt_obtain_unavailable {
    return Intl.message(
      '无法召唤',
      name: 'svt_obtain_unavailable',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已隐藏`
  String get svt_plan_hidden {
    return Intl.message(
      '已隐藏',
      name: 'svt_plan_hidden',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `出场礼装/纹章`
  String get svt_related_cards {
    return Intl.message(
      '出场礼装/纹章',
      name: 'svt_related_cards',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `重置规划`
  String get svt_reset_plan {
    return Intl.message(
      '重置规划',
      name: 'svt_reset_plan',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `切换滑动条/下拉框`
  String get svt_switch_slider_dropdown {
    return Intl.message(
      '切换滑动条/下拉框',
      name: 'svt_switch_slider_dropdown',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `同步{server}`
  String sync_server(Object server) {
    return Intl.message(
      '同步$server',
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

  /// `刷新轮播图`
  String get tooltip_refresh_sliders {
    return Intl.message(
      '刷新轮播图',
      name: 'tooltip_refresh_sliders',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `总AP`
  String get total_ap {
    return Intl.message(
      '总AP',
      name: 'total_ap',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `总数`
  String get total_counts {
    return Intl.message(
      '总数',
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

  /// `更新`
  String get update {
    return Intl.message(
      '更新',
      name: 'update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `已经是最新版本`
  String get update_already_latest {
    return Intl.message(
      '已经是最新版本',
      name: 'update_already_latest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `更新资源包`
  String get update_dataset {
    return Intl.message(
      '更新资源包',
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

  /// `上传`
  String get upload {
    return Intl.message(
      '上传',
      name: 'upload',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `用户数据`
  String get userdata {
    return Intl.message(
      '用户数据',
      name: 'userdata',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `用户数据已清空`
  String get userdata_cleared {
    return Intl.message(
      '用户数据已清空',
      name: 'userdata_cleared',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `下载备份`
  String get userdata_download_backup {
    return Intl.message(
      '下载备份',
      name: 'userdata_download_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `选择一个备份`
  String get userdata_download_choose_backup {
    return Intl.message(
      '选择一个备份',
      name: 'userdata_download_choose_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `同步数据`
  String get userdata_sync {
    return Intl.message(
      '同步数据',
      name: 'userdata_sync',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `上传备份`
  String get userdata_upload_backup {
    return Intl.message(
      '上传备份',
      name: 'userdata_upload_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `情人节礼装`
  String get valentine_craft {
    return Intl.message(
      '情人节礼装',
      name: 'valentine_craft',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `版本`
  String get version {
    return Intl.message(
      '版本',
      name: 'version',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `查看卡面`
  String get view_illustration {
    return Intl.message(
      '查看卡面',
      name: 'view_illustration',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `语音`
  String get voice {
    return Intl.message(
      '语音',
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

  /// `{a}{b}`
  String words_separate(Object a, Object b) {
    return Intl.message(
      '$a$b',
      name: 'words_separate',
      desc: '',
      locale: localeName,
      args: [a, b],
    );
  }

  /// `是`
  String get yes {
    return Intl.message(
      '是',
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
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
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
