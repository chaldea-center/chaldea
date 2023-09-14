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
    assert(
        _current != null, 'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
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

  /// `The data used in this application comes from the game Fate/GO and the following websites. The copyright of the original texts, pictures and voices of game belongs to TYPE MOON/FGO PROJECT.\n\nThe design of the program is based on the WeChat mini program "Material Programe" and the iOS application "Guda".\n\nBattle Simulator "Laplace" is implemented by Yome - the author of "FGO Simulator" - which is also inspired by FGO teamup.`
  String get about_app_declaration_text {
    return Intl.message(
      'The data used in this application comes from the game Fate/GO and the following websites. The copyright of the original texts, pictures and voices of game belongs to TYPE MOON/FGO PROJECT.\n\nThe design of the program is based on the WeChat mini program "Material Programe" and the iOS application "Guda".\n\nBattle Simulator "Laplace" is implemented by Yome - the author of "FGO Simulator" - which is also inspired by FGO teamup.',
      name: 'about_app_declaration_text',
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

  /// `Current version: {curVersion}\nLatest version: {newVersion}\nRelease Note:\n{releaseNote}`
  String about_update_app_detail(Object curVersion, Object newVersion, Object releaseNote) {
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

  /// `Active`
  String get active_skill_short {
    return Intl.message(
      'Active',
      name: 'active_skill_short',
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

  /// `Add Condition`
  String get add_condition {
    return Intl.message(
      'Add Condition',
      name: 'add_condition',
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

  /// `Add Mission`
  String get add_mission {
    return Intl.message(
      'Add Mission',
      name: 'add_mission',
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

  /// `Anniversary`
  String get anniversary {
    return Intl.message(
      'Anniversary',
      name: 'anniversary',
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

  /// `Quest Campaigns' start time of non-JP regions may be incorrect`
  String get ap_campaign_time_mismatch_hint {
    return Intl.message(
      'Quest Campaigns\' start time of non-JP regions may be incorrect',
      name: 'ap_campaign_time_mismatch_hint',
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

  /// `Data Folder`
  String get app_data_folder {
    return Intl.message(
      'Data Folder',
      name: 'app_data_folder',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Use External Storage (SD card)`
  String get app_data_use_external_storage {
    return Intl.message(
      'Use External Storage (SD card)',
      name: 'app_data_use_external_storage',
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

  /// `April Fool`
  String get april_fool {
    return Intl.message(
      'April Fool',
      name: 'april_fool',
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

  /// `Ascension Stage`
  String get ascension_stage {
    return Intl.message(
      'Ascension Stage',
      name: 'ascension_stage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Stage`
  String get ascension_stage_short {
    return Intl.message(
      'Stage',
      name: 'ascension_stage_short',
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

  /// `Load`
  String get atlas_load {
    return Intl.message(
      'Load',
      name: 'atlas_load',
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

  /// `Attack NP Rate`
  String get attack_np_rate {
    return Intl.message(
      'Attack NP Rate',
      name: 'attack_np_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Attribute Advantage`
  String get attribute_advantage {
    return Intl.message(
      'Attribute Advantage',
      name: 'attribute_advantage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hints:\n- userId here is not friend code you saw on login/friend page\n- DO NOT share above keys or screenshot to others!!!\n- choose one of following methods to import`
  String get auth_data_hints {
    return Intl.message(
      'Hints:\n- userId here is not friend code you saw on login/friend page\n- DO NOT share above keys or screenshot to others!!!\n- choose one of following methods to import',
      name: 'auth_data_hints',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto Add Trait`
  String get auto_add_trait {
    return Intl.message(
      'Auto Add Trait',
      name: 'auto_add_trait',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto Login`
  String get auto_login {
    return Intl.message(
      'Auto Login',
      name: 'auto_login',
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

  /// `Autoplay`
  String get autoplay {
    return Intl.message(
      'Autoplay',
      name: 'autoplay',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Background`
  String get background {
    return Intl.message(
      'Background',
      name: 'background',
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

  /// `Backup failed`
  String get backup_failed {
    return Intl.message(
      'Backup failed',
      name: 'backup_failed',
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

  /// `Action`
  String get battle_action {
    return Intl.message(
      'Action',
      name: 'battle_action',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Action Crit`
  String get battle_action_crit {
    return Intl.message(
      'Action Crit',
      name: 'battle_action_crit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Activate Custom Skill`
  String get battle_activate_custom_skill {
    return Intl.message(
      'Activate Custom Skill',
      name: 'battle_activate_custom_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Activation Probability`
  String get battle_activate_probability {
    return Intl.message(
      'Activation Probability',
      name: 'battle_activate_probability',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `After 7th`
  String get battle_after_7th {
    return Intl.message(
      'After 7th',
      name: 'battle_after_7th',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ally`
  String get battle_ally {
    return Intl.message(
      'Ally',
      name: 'battle_ally',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Attack NP Parameters`
  String get battle_atk_np_parameters {
    return Intl.message(
      'Attack NP Parameters',
      name: 'battle_atk_np_parameters',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Attack`
  String get battle_attack {
    return Intl.message(
      'Attack',
      name: 'battle_attack',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Battle Log`
  String get battle_battle_log {
    return Intl.message(
      'Battle Log',
      name: 'battle_battle_log',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Before 7th`
  String get battle_before_7th {
    return Intl.message(
      'Before 7th',
      name: 'battle_before_7th',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Buff Details`
  String get battle_buff_details {
    return Intl.message(
      'Buff Details',
      name: 'battle_buff_details',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Permanent`
  String get battle_buff_permanent {
    return Intl.message(
      'Permanent',
      name: 'battle_buff_permanent',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Times`
  String get battle_buff_times {
    return Intl.message(
      'Times',
      name: 'battle_buff_times',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Turns`
  String get battle_buff_turns {
    return Intl.message(
      'Turns',
      name: 'battle_buff_turns',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Buster Chain Damage`
  String get battle_buster_chain {
    return Intl.message(
      'Buster Chain Damage',
      name: 'battle_buster_chain',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Card NP Rate`
  String get battle_card_np_rate {
    return Intl.message(
      'Card NP Rate',
      name: 'battle_card_np_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Card Star Rate`
  String get battle_card_star_rate {
    return Intl.message(
      'Card Star Rate',
      name: 'battle_card_star_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Change Ascension`
  String get battle_change_ascension {
    return Intl.message(
      'Change Ascension',
      name: 'battle_change_ascension',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Charge 100% NP to party`
  String get battle_charge_party {
    return Intl.message(
      'Charge 100% NP to party',
      name: 'battle_charge_party',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click icon to select CE`
  String get battle_click_to_select_ce {
    return Intl.message(
      'Click icon to select CE',
      name: 'battle_click_to_select_ce',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click to select servant`
  String get battle_click_to_select_servants {
    return Intl.message(
      'Click to select servant',
      name: 'battle_click_to_select_servants',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Command Card`
  String get battle_command_card {
    return Intl.message(
      'Command Card',
      name: 'battle_command_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Damage`
  String get battle_damage {
    return Intl.message(
      'Damage',
      name: 'battle_damage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Damage Parameters`
  String get battle_damage_parameters {
    return Intl.message(
      'Damage Parameters',
      name: 'battle_damage_parameters',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Damage Rate`
  String get battle_damage_rate {
    return Intl.message(
      'Damage Rate',
      name: 'battle_damage_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Defeated`
  String get battle_death {
    return Intl.message(
      'Defeated',
      name: 'battle_death',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Edit Craft Essence Option`
  String get battle_edit_ce_option {
    return Intl.message(
      'Edit Craft Essence Option',
      name: 'battle_edit_ce_option',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Edit Servant Option`
  String get battle_edit_servant_option {
    return Intl.message(
      'Edit Servant Option',
      name: 'battle_edit_servant_option',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemy Remaining`
  String get battle_enemy_remaining {
    return Intl.message(
      'Enemy Remaining',
      name: 'battle_enemy_remaining',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Extra Damage Rate`
  String get battle_extra_rate {
    return Intl.message(
      'Extra Damage Rate',
      name: 'battle_extra_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `First Card Bonus`
  String get battle_first_card_bonus {
    return Intl.message(
      'First Card Bonus',
      name: 'battle_first_card_bonus',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Heal`
  String get battle_heal {
    return Intl.message(
      'Heal',
      name: 'battle_heal',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Invalid `
  String get battle_invalid {
    return Intl.message(
      'Invalid ',
      name: 'battle_invalid',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `MC Lv`
  String get battle_mc_lv {
    return Intl.message(
      'MC Lv',
      name: 'battle_mc_lv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Misc Configs`
  String get battle_misc_config {
    return Intl.message(
      'Misc Configs',
      name: 'battle_misc_config',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No quest phase selected.`
  String get battle_no_quest_phase {
    return Intl.message(
      'No quest phase selected.',
      name: 'battle_no_quest_phase',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No servant selected.`
  String get battle_no_servant {
    return Intl.message(
      'No servant selected.',
      name: 'battle_no_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No skill selected`
  String get battle_no_skill_selected {
    return Intl.message(
      'No skill selected',
      name: 'battle_no_skill_selected',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Source`
  String get battle_no_source {
    return Intl.message(
      'No Source',
      name: 'battle_no_source',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Card`
  String get battle_np_card {
    return Intl.message(
      'NP Card',
      name: 'battle_np_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Prefer Player Data`
  String get battle_prefer_player_data {
    return Intl.message(
      'Prefer Player Data',
      name: 'battle_prefer_player_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Probability Threshold`
  String get battle_probability_threshold {
    return Intl.message(
      'Probability Threshold',
      name: 'battle_probability_threshold',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `From`
  String get battle_quest_from {
    return Intl.message(
      'From',
      name: 'battle_quest_from',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Random`
  String get battle_random {
    return Intl.message(
      'Random',
      name: 'battle_random',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Records`
  String get battle_records {
    return Intl.message(
      'Records',
      name: 'battle_records',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Remaining HP`
  String get battle_remaining_hp {
    return Intl.message(
      'Remaining HP',
      name: 'battle_remaining_hp',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `require {actorName} on field`
  String battle_require_actor_on_field(Object actorName) {
    return Intl.message(
      'require $actorName on field',
      name: 'battle_require_actor_on_field',
      desc: '',
      locale: localeName,
      args: [actorName],
    );
  }

  /// `Required field traits `
  String get battle_require_field_traits {
    return Intl.message(
      'Required field traits ',
      name: 'battle_require_field_traits',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Required opponent traits`
  String get battle_require_opponent_traits {
    return Intl.message(
      'Required opponent traits',
      name: 'battle_require_opponent_traits',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Required self traits`
  String get battle_require_self_traits {
    return Intl.message(
      'Required self traits',
      name: 'battle_require_self_traits',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Activator`
  String get battle_select_activator {
    return Intl.message(
      'Select Activator',
      name: 'battle_select_activator',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Card`
  String get battle_select_card {
    return Intl.message(
      'Select Card',
      name: 'battle_select_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Repeatedly click Command Card and will be Critical Attack when in red`
  String get battle_select_critical_card_hint {
    return Intl.message(
      'Repeatedly click Command Card and will be Critical Attack when in red',
      name: 'battle_select_critical_card_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Effect `
  String get battle_select_effect {
    return Intl.message(
      'Select Effect ',
      name: 'battle_select_effect',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Should Activate`
  String get battle_should_activate {
    return Intl.message(
      'Should Activate',
      name: 'battle_should_activate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Battle Simulation`
  String get battle_simulation {
    return Intl.message(
      'Battle Simulation',
      name: 'battle_simulation',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Team Setup`
  String get battle_simulation_setup {
    return Intl.message(
      'Team Setup',
      name: 'battle_simulation_setup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skip current stage`
  String get battle_skip_current_wave {
    return Intl.message(
      'Skip current stage',
      name: 'battle_skip_current_wave',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Star Parameters`
  String get battle_star_parameters {
    return Intl.message(
      'Star Parameters',
      name: 'battle_star_parameters',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Manual random value mode`
  String get battle_tailored_execution {
    return Intl.message(
      'Manual random value mode',
      name: 'battle_tailored_execution',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Make sure enemy/ally are correctly targeted first.`
  String get battle_targeted_required_hint {
    return Intl.message(
      'Make sure enemy/ally are correctly targeted first.',
      name: 'battle_targeted_required_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Turn`
  String get battle_turn {
    return Intl.message(
      'Turn',
      name: 'battle_turn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Turn End`
  String get battle_turn_end {
    return Intl.message(
      'Turn End',
      name: 'battle_turn_end',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Undo last action`
  String get battle_undo {
    return Intl.message(
      'Undo last action',
      name: 'battle_undo',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Beast's Footprint`
  String get beast_footprint {
    return Intl.message(
      'Beast\'s Footprint',
      name: 'beast_footprint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `BGM`
  String get bgm {
    return Intl.message(
      'BGM',
      name: 'bgm',
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

  /// `Bond Limit`
  String get bond_limit {
    return Intl.message(
      'Bond Limit',
      name: 'bond_limit',
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

  /// `Branch Quest`
  String get branch_quest {
    return Intl.message(
      'Branch Quest',
      name: 'branch_quest',
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

  /// `Opponent`
  String get buff_check_opponent {
    return Intl.message(
      'Opponent',
      name: 'buff_check_opponent',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Self`
  String get buff_check_self {
    return Intl.message(
      'Self',
      name: 'buff_check_self',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Cache Icons`
  String get cache_icons {
    return Intl.message(
      'Cache Icons',
      name: 'cache_icons',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Weight`
  String get calc_weight {
    return Intl.message(
      'Weight',
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

  /// `Figure`
  String get card_asset_chara_figure {
    return Intl.message(
      'Figure',
      name: 'card_asset_chara_figure',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Command Card`
  String get card_asset_command {
    return Intl.message(
      'Command Card',
      name: 'card_asset_command',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Thumbnail`
  String get card_asset_face {
    return Intl.message(
      'Thumbnail',
      name: 'card_asset_face',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Formation`
  String get card_asset_narrow_figure {
    return Intl.message(
      'Formation',
      name: 'card_asset_narrow_figure',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Status Icon`
  String get card_asset_status {
    return Intl.message(
      'Status Icon',
      name: 'card_asset_status',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Status`
  String get card_collection_status {
    return Intl.message(
      'Status',
      name: 'card_collection_status',
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

  /// `Card Name`
  String get card_name {
    return Intl.message(
      'Card Name',
      name: 'card_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Met`
  String get card_status_met {
    return Intl.message(
      'Met',
      name: 'card_status_met',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Not Met`
  String get card_status_not_met {
    return Intl.message(
      'Not Met',
      name: 'card_status_not_met',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Owned`
  String get card_status_owned {
    return Intl.message(
      'Owned',
      name: 'card_status_owned',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Card Strengthen`
  String get card_strengthen {
    return Intl.message(
      'Card Strengthen',
      name: 'card_strengthen',
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

  /// `Equipped Servants`
  String get cc_equipped_svt {
    return Intl.message(
      'Equipped Servants',
      name: 'cc_equipped_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please add custom skills/buffs through servant options`
  String get ce_custom_skill_hint {
    return Intl.message(
      'Please add custom skills/buffs through servant options',
      name: 'ce_custom_skill_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chaldea Account`
  String get chaldea_account {
    return Intl.message(
      'Chaldea Account',
      name: 'chaldea_account',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `  Not compatible with V1 data.\n  A simple account system for userdata backup to server and multi-device synchronization\n  NO security guarantee, PLEASE DON'T set frequently used passwords!!!\n  No need to register if you do not need these two features.`
  String get chaldea_account_system_hint {
    return Intl.message(
      '  Not compatible with V1 data.\n  A simple account system for userdata backup to server and multi-device synchronization\n  NO security guarantee, PLEASE DON\'T set frequently used passwords!!!\n  No need to register if you do not need these two features.',
      name: 'chaldea_account_system_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chaldea App Backup`
  String get chaldea_backup {
    return Intl.message(
      'Chaldea App Backup',
      name: 'chaldea_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chaldea Gate`
  String get chaldea_gate {
    return Intl.message(
      'Chaldea Gate',
      name: 'chaldea_gate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chaldea Server`
  String get chaldea_server {
    return Intl.message(
      'Chaldea Server',
      name: 'chaldea_server',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `China`
  String get chaldea_server_cn {
    return Intl.message(
      'China',
      name: 'chaldea_server_cn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Global`
  String get chaldea_server_global {
    return Intl.message(
      'Global',
      name: 'chaldea_server_global',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Used for game data and screenshots recognizer`
  String get chaldea_server_hint {
    return Intl.message(
      'Used for game data and screenshots recognizer',
      name: 'chaldea_server_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chaldea - A cross-platform utility for Fate/GO. Supporting game data review, servant/event/item planning, master mission planning, summon simulator and so on.\n\nFor details: \n{url}\n`
  String chaldea_share_msg(Object url) {
    return Intl.message(
      'Chaldea - A cross-platform utility for Fate/GO. Supporting game data review, servant/event/item planning, master mission planning, summon simulator and so on.\n\nFor details: \n$url\n',
      name: 'chaldea_share_msg',
      desc: '',
      locale: localeName,
      args: [url],
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

  /// `Charge NP to {count}`
  String charge_np_to(Object count) {
    return Intl.message(
      'Charge NP to $count',
      name: 'charge_np_to',
      desc: '',
      locale: localeName,
      args: [count],
    );
  }

  /// `Verify file integrity`
  String get check_file_hash {
    return Intl.message(
      'Verify file integrity',
      name: 'check_file_hash',
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

  /// `Class Advantage`
  String get class_advantage {
    return Intl.message(
      'Class Advantage',
      name: 'class_advantage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Class Damage Multiplier`
  String get class_attack_rate {
    return Intl.message(
      'Class Damage Multiplier',
      name: 'class_attack_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sign`
  String get class_board_square {
    return Intl.message(
      'Sign',
      name: 'class_board_square',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Class Score`
  String get class_score {
    return Intl.message(
      'Class Score',
      name: 'class_score',
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

  /// `Clear Cache`
  String get clear_cache {
    return Intl.message(
      'Clear Cache',
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

  /// `Summon Coins`
  String get coin_summon_num {
    return Intl.message(
      'Summon Coins',
      name: 'coin_summon_num',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Collapse`
  String get collapse {
    return Intl.message(
      'Collapse',
      name: 'collapse',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Command Assist`
  String get command_assist {
    return Intl.message(
      'Command Assist',
      name: 'command_assist',
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

  /// `Command Spell`
  String get command_spell {
    return Intl.message(
      'Command Spell',
      name: 'command_spell',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only need to meet one *Group* of conditions`
  String get common_release_group_hint {
    return Intl.message(
      'Only need to meet one *Group* of conditions',
      name: 'common_release_group_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Condition`
  String get condition {
    return Intl.message(
      'Condition',
      name: 'condition',
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

  /// `Cost`
  String get cost {
    return Intl.message(
      'Cost',
      name: 'cost',
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

  /// `Count Rare Enemy`
  String get count_rare_enemy {
    return Intl.message(
      'Count Rare Enemy',
      name: 'count_rare_enemy',
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

  /// `Create Custom Skill`
  String get create_custom_skill {
    return Intl.message(
      'Create Custom Skill',
      name: 'create_custom_skill',
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

  /// `Crit Star Mod`
  String get crit_star_mod {
    return Intl.message(
      'Crit Star Mod',
      name: 'crit_star_mod',
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

  /// `Critical Star`
  String get critical_star {
    return Intl.message(
      'Critical Star',
      name: 'critical_star',
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

  /// `Custom Chara Figure Face`
  String get custom_chara_figure {
    return Intl.message(
      'Custom Chara Figure Face',
      name: 'custom_chara_figure',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Long press on any Figure(with multiple faces, url contains /CharaFigure/[id]/) will take you here. Or input the figure id/url below.\n - Servant-Illustration-Figure\n - Event/War "Assets" page\n - Story script - open menu - Assets`
  String get custom_chara_figure_intro {
    return Intl.message(
      'Long press on any Figure(with multiple faces, url contains /CharaFigure/[id]/) will take you here. Or input the figure id/url below.\n - Servant-Illustration-Figure\n - Event/War "Assets" page\n - Story script - open menu - Assets',
      name: 'custom_chara_figure_intro',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Custom Mission`
  String get custom_mission {
    return Intl.message(
      'Custom Mission',
      name: 'custom_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemy conditions and Quest conditions must not be mixed in one mission`
  String get custom_mission_mixed_type_hint {
    return Intl.message(
      'Enemy conditions and Quest conditions must not be mixed in one mission',
      name: 'custom_mission_mixed_type_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No mission, click + to add mission`
  String get custom_mission_nothing_hint {
    return Intl.message(
      'No mission, click + to add mission',
      name: 'custom_mission_nothing_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Original Mission`
  String get custom_mission_source_mission {
    return Intl.message(
      'Original Mission',
      name: 'custom_mission_source_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Custom Skill`
  String get custom_skill {
    return Intl.message(
      'Custom Skill',
      name: 'custom_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ember Gathering`
  String get daily_ember_quest {
    return Intl.message(
      'Ember Gathering',
      name: 'daily_ember_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enter the Treasure Vault`
  String get daily_qp_quest {
    return Intl.message(
      'Enter the Treasure Vault',
      name: 'daily_qp_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Training Ground`
  String get daily_training_quest {
    return Intl.message(
      'Training Ground',
      name: 'daily_training_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Damage`
  String get damage {
    return Intl.message(
      'Damage',
      name: 'damage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `More Powerful with Lower/Higher HP: Use MAX Rate`
  String get damage_np_hp_ratio_max_rate {
    return Intl.message(
      'More Powerful with Lower/Higher HP: Use MAX Rate',
      name: 'damage_np_hp_ratio_max_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `More powerful with more stackable traits`
  String get damage_np_indiv_sum_count {
    return Intl.message(
      'More powerful with more stackable traits',
      name: 'damage_np_indiv_sum_count',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Damage Rate`
  String get damage_rate {
    return Intl.message(
      'Damage Rate',
      name: 'damage_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click to show calculation parameters`
  String get damage_recorder_param_hint {
    return Intl.message(
      'Click to show calculation parameters',
      name: 'damage_recorder_param_hint',
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

  /// `Light`
  String get dark_mode_light {
    return Intl.message(
      'Light',
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

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Death Chance`
  String get death_chance {
    return Intl.message(
      'Death Chance',
      name: 'death_chance',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Death Effect Rate`
  String get death_effect_rate {
    return Intl.message(
      'Death Effect Rate',
      name: 'death_effect_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Debuff Immune`
  String get debuff_immune {
    return Intl.message(
      'Debuff Immune',
      name: 'debuff_immune',
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

  /// `Def NP Gain Mod`
  String get def_np_gain_mod {
    return Intl.message(
      'Def NP Gain Mod',
      name: 'def_np_gain_mod',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Default Lvs`
  String get default_lvs {
    return Intl.message(
      'Default Lvs',
      name: 'default_lvs',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Default lv setting is used only if "Prefer Player Data" turned off or servant/CE not favorite.`
  String get default_lvs_hint {
    return Intl.message(
      'Default lv setting is used only if "Prefer Player Data" turned off or servant/CE not favorite.',
      name: 'default_lvs_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Defense NP Rate`
  String get defense_np_rate {
    return Intl.message(
      'Defense NP Rate',
      name: 'defense_np_rate',
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

  /// `Reason for Deletion`
  String get delete_reason {
    return Intl.message(
      'Reason for Deletion',
      name: 'delete_reason',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Delete Unreleased Cards`
  String get delete_unreleased_card {
    return Intl.message(
      'Delete Unreleased Cards',
      name: 'delete_unreleased_card',
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

  /// `Describe Mission`
  String get describe_mission {
    return Intl.message(
      'Describe Mission',
      name: 'describe_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Desktop only`
  String get desktop_only {
    return Intl.message(
      'Desktop only',
      name: 'desktop_only',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Detective Missions`
  String get detective_mission {
    return Intl.message(
      'Detective Missions',
      name: 'detective_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Detective Rank`
  String get detective_rank {
    return Intl.message(
      'Detective Rank',
      name: 'detective_rank',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Disable`
  String get disable {
    return Intl.message(
      'Disable',
      name: 'disable',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Disable Event Effects`
  String get disable_event_effects {
    return Intl.message(
      'Disable Event Effects',
      name: 'disable_event_effects',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message(
      'Disabled',
      name: 'disabled',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Grid`
  String get display_grid {
    return Intl.message(
      'Grid',
      name: 'display_grid',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `List`
  String get display_list {
    return Intl.message(
      'List',
      name: 'display_list',
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

  /// `Show Multi-Window Button`
  String get display_show_window_fab {
    return Intl.message(
      'Show Multi-Window Button',
      name: 'display_show_window_fab',
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

  /// `CN endpoint for China mainland`
  String get download_source_hint {
    return Intl.message(
      'CN endpoint for China mainland',
      name: 'download_source_hint',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Drag to sort`
  String get drag_to_sort {
    return Intl.message(
      'Drag to sort',
      name: 'drag_to_sort',
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

  /// `The quest enemies only show a certain version, but the drop data is collected from all versions.`
  String get drop_from_all_hashes_hint {
    return Intl.message(
      'The quest enemies only show a certain version, but the drop data is collected from all versions.',
      name: 'drop_from_all_hashes_hint',
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

  /// `Duplicated Servant`
  String get duplicated_servant {
    return Intl.message(
      'Duplicated Servant',
      name: 'duplicated_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Duplicated`
  String get duplicated_servant_duplicated {
    return Intl.message(
      'Duplicated',
      name: 'duplicated_servant_duplicated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Primary`
  String get duplicated_servant_primary {
    return Intl.message(
      'Primary',
      name: 'duplicated_servant_primary',
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

  /// `Effect Scope`
  String get effect_scope {
    return Intl.message(
      'Effect Scope',
      name: 'effect_scope',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Effect Search`
  String get effect_search {
    return Intl.message(
      'Effect Search',
      name: 'effect_search',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Effective condition of Func or Buff. Poison/Curse/Burn also search buffs containing the trait.`
  String get effect_search_trait_hint {
    return Intl.message(
      'Effective condition of Func or Buff. Poison/Curse/Burn also search buffs containing the trait.',
      name: 'effect_search_trait_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Effect Target`
  String get effect_target {
    return Intl.message(
      'Effect Target',
      name: 'effect_target',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Effect Type`
  String get effect_type {
    return Intl.message(
      'Effect Type',
      name: 'effect_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Effective Condition`
  String get effective_condition {
    return Intl.message(
      'Effective Condition',
      name: 'effective_condition',
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

  /// `Empty`
  String get empty_hint {
    return Intl.message(
      'Empty',
      name: 'empty_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enable`
  String get enable {
    return Intl.message(
      'Enable',
      name: 'enable',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enable Split View`
  String get enable_split_view {
    return Intl.message(
      'Enable Split View',
      name: 'enable_split_view',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `End Enemy Turn`
  String get end_enemy_turn {
    return Intl.message(
      'End Enemy Turn',
      name: 'end_enemy_turn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemy`
  String get enemy {
    return Intl.message(
      'Enemy',
      name: 'enemy',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemy Count`
  String get enemy_count {
    return Intl.message(
      'Enemy Count',
      name: 'enemy_count',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Trait filter is only used for enemies in Main Story's free quests`
  String get enemy_filter_trait_hint {
    return Intl.message(
      'Trait filter is only used for enemies in Main Story\'s free quests',
      name: 'enemy_filter_trait_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Leader: battle ends if defeated`
  String get enemy_leader_hint {
    return Intl.message(
      'Leader: battle ends if defeated',
      name: 'enemy_leader_hint',
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

  /// `Enemy Master`
  String get enemy_master {
    return Intl.message(
      'Enemy Master',
      name: 'enemy_master',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Non-Servant`
  String get enemy_not_servant {
    return Intl.message(
      'Non-Servant',
      name: 'enemy_not_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemy Only NPs`
  String get enemy_only_nps {
    return Intl.message(
      'Enemy Only NPs',
      name: 'enemy_only_nps',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Summary`
  String get enemy_summary {
    return Intl.message(
      'Summary',
      name: 'enemy_summary',
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

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No data found`
  String get error_no_data_found {
    return Intl.message(
      'No data found',
      name: 'error_no_data_found',
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

  /// `Error! Click to go back >_<`
  String get error_widget_hint {
    return Intl.message(
      'Error! Click to go back >_<',
      name: 'error_widget_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event`
  String get event {
    return Intl.message(
      'Event',
      name: 'event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AP Cost 1/2`
  String get event_ap_cost_half {
    return Intl.message(
      'AP Cost 1/2',
      name: 'event_ap_cost_half',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bonus`
  String get event_bonus {
    return Intl.message(
      'Bonus',
      name: 'event_bonus',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Bulletin`
  String get event_bulletin_board {
    return Intl.message(
      'Bulletin',
      name: 'event_bulletin_board',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Campaign`
  String get event_campaign {
    return Intl.message(
      'Campaign',
      name: 'event_campaign',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Cooltime`
  String get event_cooltime {
    return Intl.message(
      'Cooltime',
      name: 'event_cooltime',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Custom Getatable Items`
  String get event_custom_item {
    return Intl.message(
      'Custom Getatable Items',
      name: 'event_custom_item',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Click + button to customize items`
  String get event_custom_item_empty_hint {
    return Intl.message(
      'Click + button to customize items',
      name: 'event_custom_item_empty_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Digging`
  String get event_digging {
    return Intl.message(
      'Digging',
      name: 'event_digging',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Fortification`
  String get event_fortification {
    return Intl.message(
      'Fortification',
      name: 'event_fortification',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event FQ`
  String get event_free_quest {
    return Intl.message(
      'Event FQ',
      name: 'event_free_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Heel`
  String get event_heel {
    return Intl.message(
      'Heel',
      name: 'event_heel',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Extra Items`
  String get event_item_extra {
    return Intl.message(
      'Extra Items',
      name: 'event_item_extra',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Extra Fixed Items`
  String get event_item_fixed_extra {
    return Intl.message(
      'Extra Fixed Items',
      name: 'event_item_fixed_extra',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Lottery`
  String get event_lottery {
    return Intl.message(
      'Lottery',
      name: 'event_lottery',
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

  /// `Murals`
  String get event_mural {
    return Intl.message(
      'Murals',
      name: 'event_mural',
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

  /// `This trait may be event only servant/enemy trait or field trait.\n Normal servant or enemy may not have this trait, they may have another trait with similar name but different ID.\nSome traits are not translated with 'Servant', but they may be servant only trait in event.`
  String get event_only_trait_hint {
    return Intl.message(
      'This trait may be event only servant/enemy trait or field trait.\n Normal servant or enemy may not have this trait, they may have another trait with similar name but different ID.\nSome traits are not translated with \'Servant\', but they may be servant only trait in event.',
      name: 'event_only_trait_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event Point`
  String get event_point {
    return Intl.message(
      'Event Point',
      name: 'event_point',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Points`
  String get event_point_reward {
    return Intl.message(
      'Points',
      name: 'event_point_reward',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event Quests`
  String get event_quest {
    return Intl.message(
      'Event Quests',
      name: 'event_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Recipe`
  String get event_recipe {
    return Intl.message(
      'Recipe',
      name: 'event_recipe',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Grail to crystal: {n}/{total}`
  String event_rerun_replace_grail(Object n, Object total) {
    return Intl.message(
      'Grail to crystal: $n/$total',
      name: 'event_rerun_replace_grail',
      desc: '',
      locale: localeName,
      args: [n, total],
    );
  }

  /// `Event Shop`
  String get event_shop {
    return Intl.message(
      'Event Shop',
      name: 'event_shop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Event Skill`
  String get event_skill {
    return Intl.message(
      'Event Skill',
      name: 'event_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Withdrawn`
  String get event_svt_withdraw {
    return Intl.message(
      'Withdrawn',
      name: 'event_svt_withdraw',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Tower`
  String get event_tower {
    return Intl.message(
      'Tower',
      name: 'event_tower',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Treasure Box`
  String get event_treasure_box {
    return Intl.message(
      'Treasure Box',
      name: 'event_treasure_box',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Exchange Count`
  String get exchange_count {
    return Intl.message(
      'Exchange Count',
      name: 'exchange_count',
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

  /// `NEXT`
  String get exp_card_plan_next {
    return Intl.message(
      'NEXT',
      name: 'exp_card_plan_next',
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

  /// `Expand`
  String get expand {
    return Intl.message(
      'Expand',
      name: 'expand',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Extra Passive`
  String get extra_passive {
    return Intl.message(
      'Extra Passive',
      name: 'extra_passive',
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

  /// `Favorite All Shown Svts`
  String get favorite_all_shown_svt {
    return Intl.message(
      'Favorite All Shown Svts',
      name: 'favorite_all_shown_svt',
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

  /// `Feedback form is not empty, still exit?`
  String get feedback_form_alert {
    return Intl.message(
      'Feedback form is not empty, still exit?',
      name: 'feedback_form_alert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please check <**FAQ**> first before sending feedback. And following detail is desired:\n- How to reproduce, expected behaviour\n- App/dataset version, device system and version\n- Attach screenshots and logs\n- It's better to provide contact info (e.g. Email)\n- DO NOT ask me why cannot find servant xxx`
  String get feedback_info {
    return Intl.message(
      'Please check <**FAQ**> first before sending feedback. And following detail is desired:\n- How to reproduce, expected behaviour\n- App/dataset version, device system and version\n- Attach screenshots and logs\n- It\'s better to provide contact info (e.g. Email)\n- DO NOT ask me why cannot find servant xxx',
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

  /// `Field AI`
  String get field_ai {
    return Intl.message(
      'Field AI',
      name: 'field_ai',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `File {filename} not found or mismatched hash: {hash} - {localHash}`
  String file_not_found_or_mismatched_hash(Object filename, Object hash, Object localHash) {
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

  /// `Plan Not Reach`
  String get filter_plan_not_reached {
    return Intl.message(
      'Plan Not Reach',
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

  /// `Fix CORS issue for "Global" source`
  String get fix_cors_for_chaldea_data {
    return Intl.message(
      'Fix CORS issue for "Global" source',
      name: 'fix_cors_for_chaldea_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Usually on FireFox`
  String get fix_cors_for_chaldea_data_hint {
    return Intl.message(
      'Usually on FireFox',
      name: 'fix_cors_for_chaldea_data_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Fixed OC`
  String get fixed_oc {
    return Intl.message(
      'Fixed OC',
      name: 'fixed_oc',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Force Enable NP S.E.`
  String get force_enable_np_se {
    return Intl.message(
      'Force Enable NP S.E.',
      name: 'force_enable_np_se',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Force Death`
  String get force_instant_death {
    return Intl.message(
      'Force Death',
      name: 'force_instant_death',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Forced Update`
  String get forced_update {
    return Intl.message(
      'Forced Update',
      name: 'forced_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Fou`
  String get foukun {
    return Intl.message(
      'Fou',
      name: 'foukun',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Decimals are not displayed, there may be an error of ±1 between the displayed result and the calculated result`
  String get fq_plan_decimal_hint {
    return Intl.message(
      'Decimals are not displayed, there may be an error of ±1 between the displayed result and the calculated result',
      name: 'fq_plan_decimal_hint',
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

  /// `Gacha`
  String get gacha {
    return Intl.message(
      'Gacha',
      name: 'gacha',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Banner image may be overridden by`
  String get gacha_image_overridden_hint {
    return Intl.message(
      'Banner image may be overridden by',
      name: 'gacha_image_overridden_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gacha Prob Calc`
  String get gacha_prob_calc {
    return Intl.message(
      'Gacha Prob Calc',
      name: 'gacha_prob_calc',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{rarity}☆ CE Pick Up`
  String gacha_prob_ce_pickup(Object rarity) {
    return Intl.message(
      '$rarity☆ CE Pick Up',
      name: 'gacha_prob_ce_pickup',
      desc: '',
      locale: localeName,
      args: [rarity],
    );
  }

  /// `Custom Rate`
  String get gacha_prob_custom_rate {
    return Intl.message(
      'Custom Rate',
      name: 'gacha_prob_custom_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `If the value is too large or too small, the calculation result is inaccurate due to the double precision problem.`
  String get gacha_prob_precision_hint {
    return Intl.message(
      'If the value is too large or too small, the calculation result is inaccurate due to the double precision problem.',
      name: 'gacha_prob_precision_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{rarity}☆ SVT Pick Up`
  String gacha_prob_svt_pickup(Object rarity) {
    return Intl.message(
      '$rarity☆ SVT Pick Up',
      name: 'gacha_prob_svt_pickup',
      desc: '',
      locale: localeName,
      args: [rarity],
    );
  }

  /// `Sum of NP level of servants in Inventory & Second Archive, don't include burned and event 4☆ servants.\nEffect on probability due to Unregistered Spirit Origin shop, Lucky Bag(GSSR) and 5/4-Star Servant Present needs manual correction.`
  String get gacha_svt_count_hint {
    return Intl.message(
      'Sum of NP level of servants in Inventory & Second Archive, don\'t include burned and event 4☆ servants.\nEffect on probability due to Unregistered Spirit Origin shop, Lucky Bag(GSSR) and 5/4-Star Servant Present needs manual correction.',
      name: 'gacha_svt_count_hint',
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

  /// `Game Account`
  String get game_account {
    return Intl.message(
      'Game Account',
      name: 'game_account',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Loading game data failed, please download data again`
  String get game_data_not_found {
    return Intl.message(
      'Loading game data failed, please download data again',
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

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `All`
  String get general_all {
    return Intl.message(
      'All',
      name: 'general_all',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Any`
  String get general_any {
    return Intl.message(
      'Any',
      name: 'general_any',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Close`
  String get general_close {
    return Intl.message(
      'Close',
      name: 'general_close',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Custom`
  String get general_custom {
    return Intl.message(
      'Custom',
      name: 'general_custom',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Default`
  String get general_default {
    return Intl.message(
      'Default',
      name: 'general_default',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Export`
  String get general_export {
    return Intl.message(
      'Export',
      name: 'general_export',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import`
  String get general_import {
    return Intl.message(
      'Import',
      name: 'general_import',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Next`
  String get general_next {
    return Intl.message(
      'Next',
      name: 'general_next',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Others`
  String get general_others {
    return Intl.message(
      'Others',
      name: 'general_others',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Previous`
  String get general_previous {
    return Intl.message(
      'Previous',
      name: 'general_previous',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Special`
  String get general_special {
    return Intl.message(
      'Special',
      name: 'general_special',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Type`
  String get general_type {
    return Intl.message(
      'Type',
      name: 'general_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Global Text Selectable`
  String get global_text_selection {
    return Intl.message(
      'Global Text Selectable',
      name: 'global_text_selection',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Invalid input or no valid target found`
  String get glpk_error_no_valid_target {
    return Intl.message(
      'Invalid input or no valid target found',
      name: 'glpk_error_no_valid_target',
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

  /// `Gudako`
  String get guda_female {
    return Intl.message(
      'Gudako',
      name: 'guda_female',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gudao`
  String get guda_male {
    return Intl.message(
      'Gudao',
      name: 'guda_male',
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

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
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

  /// `Hide Plan Detail`
  String get hide_svt_plan_details {
    return Intl.message(
      'Hide Plan Detail',
      name: 'hide_svt_plan_details',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `It is only not displayed on plan tab, but it is actually still included in the material planning and statistics.`
  String get hide_svt_plan_details_hint {
    return Intl.message(
      'It is only not displayed on plan tab, but it is actually still included in the material planning and statistics.',
      name: 'hide_svt_plan_details_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hide Unreleased Cards`
  String get hide_unreleased_card {
    return Intl.message(
      'Hide Unreleased Cards',
      name: 'hide_unreleased_card',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `High DIfficulty Quest`
  String get high_difficulty_quest {
    return Intl.message(
      'High DIfficulty Quest',
      name: 'high_difficulty_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `(JP/NA/CN/TW)Capture the data when logging in`
  String get http_sniff_hint {
    return Intl.message(
      '(JP/NA/CN/TW)Capture the data when logging in',
      name: 'http_sniff_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Https Sniffing`
  String get https_sniff {
    return Intl.message(
      'Https Sniffing',
      name: 'https_sniff',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hunting Quests`
  String get hunting_quest {
    return Intl.message(
      'Hunting Quests',
      name: 'hunting_quest',
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

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enhance - Skill`
  String get import_active_skill_hint {
    return Intl.message(
      'Enhance - Skill',
      name: 'import_active_skill_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Active Skill Screenshots`
  String get import_active_skill_screenshots {
    return Intl.message(
      'Active Skill Screenshots',
      name: 'import_active_skill_screenshots',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enhance - Append Skill`
  String get import_append_skill_hint {
    return Intl.message(
      'Enhance - Append Skill',
      name: 'import_append_skill_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Append Skill Screenshots`
  String get import_append_skill_screenshots {
    return Intl.message(
      'Append Skill Screenshots',
      name: 'import_append_skill_screenshots',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Account File`
  String get import_auth_file {
    return Intl.message(
      'Account File',
      name: 'import_auth_file',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Import Backup`
  String get import_backup {
    return Intl.message(
      'Import Backup',
      name: 'import_backup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `All servants`
  String get import_csv_export_all {
    return Intl.message(
      'All servants',
      name: 'import_csv_export_all',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Empty template`
  String get import_csv_export_empty {
    return Intl.message(
      'Empty template',
      name: 'import_csv_export_empty',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only favorite servants`
  String get import_csv_export_favorite {
    return Intl.message(
      'Only favorite servants',
      name: 'import_csv_export_favorite',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Export Template`
  String get import_csv_export_template {
    return Intl.message(
      'Export Template',
      name: 'import_csv_export_template',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Load CSV`
  String get import_csv_load_csv {
    return Intl.message(
      'Load CSV',
      name: 'import_csv_load_csv',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `CSV Template`
  String get import_csv_title {
    return Intl.message(
      'CSV Template',
      name: 'import_csv_title',
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

  /// `From Clipboard`
  String get import_from_clipboard {
    return Intl.message(
      'From Clipboard',
      name: 'import_from_clipboard',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `From File`
  String get import_from_file {
    return Intl.message(
      'From File',
      name: 'import_from_file',
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

  /// `Import Image`
  String get import_image {
    return Intl.message(
      'Import Image',
      name: 'import_image',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `My Room - Item List`
  String get import_item_hint {
    return Intl.message(
      'My Room - Item List',
      name: 'import_item_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Items Screenshots`
  String get import_item_screenshots {
    return Intl.message(
      'Items Screenshots',
      name: 'import_item_screenshots',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Only update recognized results`
  String get import_screenshot_hint {
    return Intl.message(
      'Only update recognized results',
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

  /// `More import methods`
  String get import_userdata_more {
    return Intl.message(
      'More import methods',
      name: 'import_userdata_more',
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

  /// `Charge`
  String get info_charge {
    return Intl.message(
      'Charge',
      name: 'info_charge',
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

  /// `Instant Death`
  String get instant_death {
    return Intl.message(
      'Instant Death',
      name: 'instant_death',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Instant Death Params`
  String get instant_death_params {
    return Intl.message(
      'Instant Death Params',
      name: 'instant_death_params',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Interlude`
  String get interlude {
    return Intl.message(
      'Interlude',
      name: 'interlude',
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

  /// `Apple`
  String get item_apple {
    return Intl.message(
      'Apple',
      name: 'item_apple',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Edit Owned Amount`
  String get item_edit_owned_amount {
    return Intl.message(
      'Edit Owned Amount',
      name: 'item_edit_owned_amount',
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

  /// `Grail → Lore`
  String get item_grail2crystal {
    return Intl.message(
      'Grail → Lore',
      name: 'item_grail2crystal',
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

  /// `Pay attention to the quest runs, few runs may result inaccurate stats!`
  String get item_obtain_event_free_hint {
    return Intl.message(
      'Pay attention to the quest runs, few runs may result inaccurate stats!',
      name: 'item_obtain_event_free_hint',
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

  /// `Include Owned`
  String get item_stat_include_owned {
    return Intl.message(
      'Include Owned',
      name: 'item_stat_include_owned',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Subtract Event`
  String get item_stat_sub_event {
    return Intl.message(
      'Subtract Event',
      name: 'item_stat_sub_event',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Subtract Owned`
  String get item_stat_sub_owned {
    return Intl.message(
      'Subtract Owned',
      name: 'item_stat_sub_owned',
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

  /// `Warning that this quest contains multiple enemy configurations, when searching shared teams or simulating check the corresponding version:\nClick Details - Select Version - Click the Calculate Button`
  String get laplace_enemy_multi_ver_hint {
    return Intl.message(
      'Warning that this quest contains multiple enemy configurations, when searching shared teams or simulating check the corresponding version:\nClick Details - Select Version - Click the Calculate Button',
      name: 'laplace_enemy_multi_ver_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `My Teams`
  String get laplace_my_teams {
    return Intl.message(
      'My Teams',
      name: 'laplace_my_teams',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Multi-step NP found(e.g. Chen Gong/Arash), please check MIN/MAX RNG to ensure NP refund is sufficient and able to clear the quest.`
  String get laplace_upload_td_multi_dmg_func_hint {
    return Intl.message(
      'Multi-step NP found(e.g. Chen Gong/Arash), please check MIN/MAX RNG to ensure NP refund is sufficient and able to clear the quest.',
      name: 'laplace_upload_td_multi_dmg_func_hint',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Limited Time`
  String get limited_time {
    return Intl.message(
      'Limited Time',
      name: 'limited_time',
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

  /// `{shown} shown (total {total})`
  String list_count_shown_all(Object shown, Object total) {
    return Intl.message(
      '$shown shown (total $total)',
      name: 'list_count_shown_all',
      desc: '',
      locale: localeName,
      args: [shown, total],
    );
  }

  /// `{shown} shown, {ignore} ignored (total {total})`
  String list_count_shown_hidden_all(Object shown, Object ignore, Object total) {
    return Intl.message(
      '$shown shown, $ignore ignored (total $total)',
      name: 'list_count_shown_hidden_all',
      desc: '',
      locale: localeName,
      args: [shown, ignore, total],
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

  /// `Load FFO Data`
  String get load_ffo_data {
    return Intl.message(
      'Load FFO Data',
      name: 'load_ffo_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Logic Type`
  String get logic_type {
    return Intl.message(
      'Logic Type',
      name: 'logic_type',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `AND`
  String get logic_type_and {
    return Intl.message(
      'AND',
      name: 'logic_type_and',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `OR`
  String get logic_type_or {
    return Intl.message(
      'OR',
      name: 'logic_type_or',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Login Auth`
  String get login_auth {
    return Intl.message(
      'Login Auth',
      name: 'login_auth',
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

  /// `6-18 characters, at least one alphabet`
  String get login_password_error {
    return Intl.message(
      '6-18 characters, at least one alphabet',
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

  /// `Long press to remove`
  String get long_press_to_remove {
    return Intl.message(
      'Long press to remove',
      name: 'long_press_to_remove',
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

  /// `Cost of 1 roll`
  String get lottery_cost_per_roll {
    return Intl.message(
      'Cost of 1 roll',
      name: 'lottery_cost_per_roll',
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

  /// `Best`
  String get lucky_bag_best {
    return Intl.message(
      'Best',
      name: 'lucky_bag_best',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Expectation`
  String get lucky_bag_expectation {
    return Intl.message(
      'Expectation',
      name: 'lucky_bag_expectation',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Exp.`
  String get lucky_bag_expectation_short {
    return Intl.message(
      'Exp.',
      name: 'lucky_bag_expectation_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rating`
  String get lucky_bag_rating {
    return Intl.message(
      'Rating',
      name: 'lucky_bag_rating',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unwanted`
  String get lucky_bag_tooltip_unwanted {
    return Intl.message(
      'Unwanted',
      name: 'lucky_bag_tooltip_unwanted',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Wanted`
  String get lucky_bag_tooltip_wanted {
    return Intl.message(
      'Wanted',
      name: 'lucky_bag_tooltip_wanted',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Worst`
  String get lucky_bag_worst {
    return Intl.message(
      'Worst',
      name: 'lucky_bag_worst',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Main Interlude`
  String get main_interlude {
    return Intl.message(
      'Main Interlude',
      name: 'main_interlude',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Main Quests`
  String get main_quest {
    return Intl.message(
      'Main Quests',
      name: 'main_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Main Record`
  String get main_story {
    return Intl.message(
      'Main Record',
      name: 'main_story',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Chapter`
  String get main_story_chapter {
    return Intl.message(
      'Chapter',
      name: 'main_story_chapter',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Gimmicks`
  String get map_gimmicks {
    return Intl.message(
      'Gimmicks',
      name: 'map_gimmicks',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Layer {layer}`
  String map_layer_n(Object layer) {
    return Intl.message(
      'Layer $layer',
      name: 'map_layer_n',
      desc: '',
      locale: localeName,
      args: [layer],
    );
  }

  /// `FQ spots only`
  String get map_show_fq_spots_only {
    return Intl.message(
      'FQ spots only',
      name: 'map_show_fq_spots_only',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Header Image`
  String get map_show_header_image {
    return Intl.message(
      'Show Header Image',
      name: 'map_show_header_image',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Roads`
  String get map_show_roads {
    return Intl.message(
      'Show Roads',
      name: 'map_show_roads',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Spots`
  String get map_show_spots {
    return Intl.message(
      'Show Spots',
      name: 'map_show_spots',
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

  /// `Weekly Mission`
  String get master_mission_weekly {
    return Intl.message(
      'Weekly Mission',
      name: 'master_mission_weekly',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Max enemy act count`
  String get max_enemy_act_count {
    return Intl.message(
      'Max enemy act count',
      name: 'max_enemy_act_count',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Max enemies on stage`
  String get max_enemy_on_stage {
    return Intl.message(
      'Max enemies on stage',
      name: 'max_enemy_on_stage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `MLB`
  String get max_limit_break {
    return Intl.message(
      'MLB',
      name: 'max_limit_break',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Max Window Width`
  String get max_window_width {
    return Intl.message(
      'Max Window Width',
      name: 'max_window_width',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Assets`
  String get media_assets {
    return Intl.message(
      'Assets',
      name: 'media_assets',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Merge Same Drop Item`
  String get merge_same_drop {
    return Intl.message(
      'Merge Same Drop Item',
      name: 'merge_same_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NOT MIGRATE`
  String get migrate_external_storage_btn_no {
    return Intl.message(
      'NOT MIGRATE',
      name: 'migrate_external_storage_btn_no',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `MIGRATE`
  String get migrate_external_storage_btn_yes {
    return Intl.message(
      'MIGRATE',
      name: 'migrate_external_storage_btn_yes',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Please move the data manually, otherwise the data will be empty after startup.`
  String get migrate_external_storage_manual_warning {
    return Intl.message(
      'Please move the data manually, otherwise the data will be empty after startup.',
      name: 'migrate_external_storage_manual_warning',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Migrate Data`
  String get migrate_external_storage_title {
    return Intl.message(
      'Migrate Data',
      name: 'migrate_external_storage_title',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Mission`
  String get mission {
    return Intl.message(
      'Mission',
      name: 'mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Mission Targets`
  String get mission_target {
    return Intl.message(
      'Mission Targets',
      name: 'mission_target',
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

  /// `My Room`
  String get my_room {
    return Intl.message(
      'My Room',
      name: 'my_room',
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

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Force Online Mode`
  String get network_force_online {
    return Intl.message(
      'Force Online Mode',
      name: 'network_force_online',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `App will change to offline mode if no network detected`
  String get network_force_online_hint {
    return Intl.message(
      'App will change to offline mode if no network detected',
      name: 'network_force_online_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Network Settings`
  String get network_settings {
    return Intl.message(
      'Network Settings',
      name: 'network_settings',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Network Status`
  String get network_status {
    return Intl.message(
      'Network Status',
      name: 'network_status',
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

  /// `New data available`
  String get new_data_available {
    return Intl.message(
      'New data available',
      name: 'new_data_available',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `New Drop Data`
  String get new_drop_data_6th {
    return Intl.message(
      'New Drop Data',
      name: 'new_drop_data_6th',
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

  /// `NEXT`
  String get next_page {
    return Intl.message(
      'NEXT',
      name: 'next_page',
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

  /// `No uploaded teams`
  String get no_uploaded_teams {
    return Intl.message(
      'No uploaded teams',
      name: 'no_uploaded_teams',
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

  /// `Non-favorite servants will be skipped`
  String get non_favorite_svt_be_skipped {
    return Intl.message(
      'Non-favorite servants will be skipped',
      name: 'non_favorite_svt_be_skipped',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `non-MLB`
  String get non_mlb {
    return Intl.message(
      'non-MLB',
      name: 'non_mlb',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Normal Attack`
  String get normal_attack {
    return Intl.message(
      'Normal Attack',
      name: 'normal_attack',
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

  /// `Not Outdated`
  String get not_outdated {
    return Intl.message(
      'Not Outdated',
      name: 'not_outdated',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Charge`
  String get np_charge {
    return Intl.message(
      'NP Charge',
      name: 'np_charge',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Instant`
  String get np_charge_type_instant {
    return Intl.message(
      'Instant',
      name: 'np_charge_type_instant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Instant Sum`
  String get np_charge_type_instant_sum {
    return Intl.message(
      'Instant Sum',
      name: 'np_charge_type_instant_sum',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Per Turn`
  String get np_charge_type_perturn {
    return Intl.message(
      'Per Turn',
      name: 'np_charge_type_perturn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Damage`
  String get np_damage {
    return Intl.message(
      'NP Damage',
      name: 'np_damage',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Gain Mod`
  String get np_gain_mod {
    return Intl.message(
      'NP Gain Mod',
      name: 'np_gain_mod',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Not Enough`
  String get np_not_enough {
    return Intl.message(
      'NP Not Enough',
      name: 'np_not_enough',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP refund`
  String get np_refund {
    return Intl.message(
      'NP refund',
      name: 'np_refund',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Refund`
  String get np_refund_short {
    return Intl.message(
      'Refund',
      name: 'np_refund_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP S.E.`
  String get np_se {
    return Intl.message(
      'NP S.E.',
      name: 'np_se',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP`
  String get np_short {
    return Intl.message(
      'NP',
      name: 'np_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Special Damage Rate`
  String get np_sp_damage_rate {
    return Intl.message(
      'NP Special Damage Rate',
      name: 'np_sp_damage_rate',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Time`
  String get obtain_time {
    return Intl.message(
      'Time',
      name: 'obtain_time',
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

  /// `One-off Quest`
  String get one_off_quest {
    return Intl.message(
      'One-off Quest',
      name: 'one_off_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only show enemies from main story's free quest`
  String get only_show_main_story_enemy {
    return Intl.message(
      'Only show enemies from main story\'s free quest',
      name: 'only_show_main_story_enemy',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only used for AoE NP`
  String get only_usuable_for_aoe_np {
    return Intl.message(
      'Only used for AoE NP',
      name: 'only_usuable_for_aoe_np',
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

  /// `Please open with file manager`
  String get open_in_file_manager {
    return Intl.message(
      'Please open with file manager',
      name: 'open_in_file_manager',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Opening Time`
  String get opening_time {
    return Intl.message(
      'Opening Time',
      name: 'opening_time',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message(
      'Options',
      name: 'options',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Outdated`
  String get outdated {
    return Intl.message(
      'Outdated',
      name: 'outdated',
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

  /// `Passive`
  String get passive_skill_short {
    return Intl.message(
      'Passive',
      name: 'passive_skill_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Paste`
  String get paste {
    return Intl.message(
      'Paste',
      name: 'paste',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Choose one Quest Enemy, open popup menu, then copy it to clipboard.`
  String get paste_enemy_hint {
    return Intl.message(
      'Choose one Quest Enemy, open popup menu, then copy it to clipboard.',
      name: 'paste_enemy_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Permanent`
  String get permanent {
    return Intl.message(
      'Permanent',
      name: 'permanent',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Pin to Top`
  String get pin_to_top {
    return Intl.message(
      'Pin to Top',
      name: 'pin_to_top',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Unlocked Append`
  String get plan_list_only_unlock_append {
    return Intl.message(
      'Unlocked Append',
      name: 'plan_list_only_unlock_append',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Set All`
  String get plan_list_set_all {
    return Intl.message(
      'Set All',
      name: 'plan_list_set_all',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current`
  String get plan_list_set_all_current {
    return Intl.message(
      'Current',
      name: 'plan_list_set_all_current',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Target`
  String get plan_list_set_all_target {
    return Intl.message(
      'Target',
      name: 'plan_list_set_all_target',
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

  /// `Player Data`
  String get player_data {
    return Intl.message(
      'Player Data',
      name: 'player_data',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Prefer April Fools' Day icon`
  String get prefer_april_fool_icon {
    return Intl.message(
      'Prefer April Fools\' Day icon',
      name: 'prefer_april_fool_icon',
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

  /// `Used for game data description, not UI language. Not all game data is translated for all 5 official languages.`
  String get preferred_translation_footer {
    return Intl.message(
      'Used for game data description, not UI language. Not all game data is translated for all 5 official languages.',
      name: 'preferred_translation_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Present Box`
  String get present_box {
    return Intl.message(
      'Present Box',
      name: 'present_box',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `PREV`
  String get prev_page {
    return Intl.message(
      'PREV',
      name: 'prev_page',
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

  /// `Tags should not be too long, otherwise it cannot be shown completely`
  String get priority_tagging_hint {
    return Intl.message(
      'Tags should not be too long, otherwise it cannot be shown completely',
      name: 'priority_tagging_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `probability`
  String get probability {
    return Intl.message(
      'probability',
      name: 'probability',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Expectation`
  String get probability_expectation {
    return Intl.message(
      'Expectation',
      name: 'probability_expectation',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Progress`
  String get progress {
    return Intl.message(
      'Progress',
      name: 'progress',
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

  /// `Section {n}`
  String quest_chapter_n(Object n) {
    return Intl.message(
      'Section $n',
      name: 'quest_chapter_n',
      desc: '',
      locale: localeName,
      args: [n],
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

  /// `Invalid quest, only Free and Raid Quests supports team sharing`
  String get quest_disallow_laplace_share_hint {
    return Intl.message(
      'Invalid quest, only Free and Raid Quests supports team sharing',
      name: 'quest_disallow_laplace_share_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `For event effects, both war and field trait(94000xxx) are required to be correctly set.\nOnly basic quest/enemy edit supported, special functions (multiple hp bar/shiftServant) are not supported. Customize JSON data for complex quest.`
  String get quest_edit_hint {
    return Intl.message(
      'For event effects, both war and field trait(94000xxx) are required to be correctly set.\nOnly basic quest/enemy edit supported, special functions (multiple hp bar/shiftServant) are not supported. Customize JSON data for complex quest.',
      name: 'quest_edit_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `A summary for enemies in free quest from Main Story, any property may be overridden from server. Only for reference.\n*Special* Trait means only part of enemies have this trait.`
  String get quest_enemy_summary_hint {
    return Intl.message(
      'A summary for enemies in free quest from Main Story, any property may be overridden from server. Only for reference.\n*Special* Trait means only part of enemies have this trait.',
      name: 'quest_enemy_summary_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Fields`
  String get quest_fields {
    return Intl.message(
      'Fields',
      name: 'quest_fields',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drops`
  String get quest_fixed_drop {
    return Intl.message(
      'Drops',
      name: 'quest_fixed_drop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Drops`
  String get quest_fixed_drop_short {
    return Intl.message(
      'Drops',
      name: 'quest_fixed_drop_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Something went wrong or {region} doesn't have this quest's data`
  String quest_not_found_error(Object region) {
    return Intl.message(
      'Something went wrong or $region doesn\'t have this quest\'s data',
      name: 'quest_not_found_error',
      desc: '',
      locale: localeName,
      args: [region],
    );
  }

  /// `Preferred Region`
  String get quest_prefer_region {
    return Intl.message(
      'Preferred Region',
      name: 'quest_prefer_region',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `If the related event of the quest has not started at chosen region, it will fallback to JP`
  String get quest_prefer_region_hint {
    return Intl.message(
      'If the related event of the quest has not started at chosen region, it will fallback to JP',
      name: 'quest_prefer_region_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Only JP(after 2020/11) or NA(2020/12) may contain enemy data`
  String get quest_region_has_enemy_hint {
    return Intl.message(
      'Only JP(after 2020/11) or NA(2020/12) may contain enemy data',
      name: 'quest_region_has_enemy_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Restrictions`
  String get quest_restriction {
    return Intl.message(
      'Restrictions',
      name: 'quest_restriction',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Quest Rewards`
  String get quest_reward {
    return Intl.message(
      'Quest Rewards',
      name: 'quest_reward',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rewards`
  String get quest_reward_short {
    return Intl.message(
      'Rewards',
      name: 'quest_reward_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{runs} Runs`
  String quest_runs(Object runs) {
    return Intl.message(
      '$runs Runs',
      name: 'quest_runs',
      desc: '',
      locale: localeName,
      args: [runs],
    );
  }

  /// `AP Cost Event Time`
  String get quest_timeline_sort_campaign_open {
    return Intl.message(
      'AP Cost Event Time',
      name: 'quest_timeline_sort_campaign_open',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Quest Open Time`
  String get quest_timeline_sort_quest_open {
    return Intl.message(
      'Quest Open Time',
      name: 'quest_timeline_sort_quest_open',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Version {index}/{total} ({enemy} enemies)`
  String quest_version(Object index, Object total, Object enemy) {
    return Intl.message(
      'Version $index/$total ($enemy enemies)',
      name: 'quest_version',
      desc: '',
      locale: localeName,
      args: [index, total, enemy],
    );
  }

  /// `Wave`
  String get quest_wave {
    return Intl.message(
      'Wave',
      name: 'quest_wave',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Quit`
  String get quit {
    return Intl.message(
      'Quit',
      name: 'quit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Raid Quest`
  String get raid_quest {
    return Intl.message(
      'Raid Quest',
      name: 'raid_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Random`
  String get random {
    return Intl.message(
      'Random',
      name: 'random',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Random Missions`
  String get random_mission {
    return Intl.message(
      'Random Missions',
      name: 'random_mission',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rank Up`
  String get rankup_quest {
    return Intl.message(
      'Rank Up',
      name: 'rankup_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Some quests' start time is not correct.\nIf show by AP campaign time, only JP time is used.`
  String get rankup_timeline_hint {
    return Intl.message(
      'Some quests\' start time is not correct.\nIf show by AP campaign time, only JP time is used.',
      name: 'rankup_timeline_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Rare enemy, chance to appear`
  String get rare_enemy_hint {
    return Intl.message(
      'Rare enemy, chance to appear',
      name: 'rare_enemy_hint',
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

  /// `{unknown} unknown, {dup} dup, {valid}/{total} valid, {selected} selected`
  String recognizer_result_count(Object unknown, Object dup, Object valid, Object total, Object selected) {
    return Intl.message(
      '$unknown unknown, $dup dup, $valid/$total valid, $selected selected',
      name: 'recognizer_result_count',
      desc: '',
      locale: localeName,
      args: [unknown, dup, valid, total, selected],
    );
  }

  /// `Current View`
  String get recorder_screenshot_current_view {
    return Intl.message(
      'Current View',
      name: 'recorder_screenshot_current_view',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Full View`
  String get recorder_screenshot_full_view {
    return Intl.message(
      'Full View',
      name: 'recorder_screenshot_full_view',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No new card found`
  String get refresh_data_no_update {
    return Intl.message(
      'No new card found',
      name: 'refresh_data_no_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `CN`
  String get region_cn {
    return Intl.message(
      'CN',
      name: 'region_cn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `JP`
  String get region_jp {
    return Intl.message(
      'JP',
      name: 'region_jp',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `KR`
  String get region_kr {
    return Intl.message(
      'KR',
      name: 'region_kr',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NA`
  String get region_na {
    return Intl.message(
      'NA',
      name: 'region_na',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `{region} Notice`
  String region_notice(Object region) {
    return Intl.message(
      '$region Notice',
      name: 'region_notice',
      desc: '',
      locale: localeName,
      args: [region],
    );
  }

  /// `TW`
  String get region_tw {
    return Intl.message(
      'TW',
      name: 'region_tw',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Related Traits`
  String get related_traits {
    return Intl.message(
      'Related Traits',
      name: 'related_traits',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Remove Condition`
  String get remove_condition {
    return Intl.message(
      'Remove Condition',
      name: 'remove_condition',
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

  /// `Remove Mission`
  String get remove_mission {
    return Intl.message(
      'Remove Mission',
      name: 'remove_mission',
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

  /// `Reset custom ascension icons`
  String get reset_custom_ascension_icon {
    return Intl.message(
      'Reset custom ascension icons',
      name: 'reset_custom_ascension_icon',
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

  /// `Reset Skill CD`
  String get reset_skill_cd {
    return Intl.message(
      'Reset Skill CD',
      name: 'reset_skill_cd',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Resettable Digged Num`
  String get resettable_digged_num {
    return Intl.message(
      'Resettable Digged Num',
      name: 'resettable_digged_num',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Resolution`
  String get resolution {
    return Intl.message(
      'Resolution',
      name: 'resolution',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Restart to take effect`
  String get restart_to_apply_changes {
    return Intl.message(
      'Restart to take effect',
      name: 'restart_to_apply_changes',
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

  /// `Results`
  String get results {
    return Intl.message(
      'Results',
      name: 'results',
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

  /// `Keep Same Event Plan`
  String get same_event_plan {
    return Intl.message(
      'Keep Same Event Plan',
      name: 'same_event_plan',
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

  /// `Save As`
  String get save_as {
    return Intl.message(
      'Save As',
      name: 'save_as',
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

  /// `Screenshots`
  String get screenshots {
    return Intl.message(
      'Screenshots',
      name: 'screenshots',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Choice`
  String get script_choice {
    return Intl.message(
      'Choice',
      name: 'script_choice',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Choice Branch End`
  String get script_choice_end {
    return Intl.message(
      'Choice Branch End',
      name: 'script_choice_end',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hujimaru`
  String get script_player_name {
    return Intl.message(
      'Hujimaru',
      name: 'script_player_name',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Story`
  String get script_story {
    return Intl.message(
      'Story',
      name: 'script_story',
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

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select CE`
  String get select_ce {
    return Intl.message(
      'Select CE',
      name: 'select_ce',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Select Item`
  String get select_item_title {
    return Intl.message(
      'Select Item',
      name: 'select_item_title',
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

  /// `Select Servant`
  String get select_servant {
    return Intl.message(
      'Select Servant',
      name: 'select_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Skill`
  String get select_skill {
    return Intl.message(
      'Select Skill',
      name: 'select_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select none to skip this effect`
  String get select_skip {
    return Intl.message(
      'Select none to skip this effect',
      name: 'select_skip',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Select Support`
  String get select_support_servant {
    return Intl.message(
      'Select Support',
      name: 'select_support_servant',
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

  /// `Coin`
  String get servant_coin_short {
    return Intl.message(
      'Coin',
      name: 'servant_coin_short',
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

  /// `SET ALL`
  String get set_all {
    return Intl.message(
      'SET ALL',
      name: 'set_all',
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

  /// `Allow mouse to drag scrollables`
  String get setting_drag_by_mouse {
    return Intl.message(
      'Allow mouse to drag scrollables',
      name: 'setting_drag_by_mouse',
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

  /// `Split Screen Ratio`
  String get setting_split_ratio {
    return Intl.message(
      'Split Screen Ratio',
      name: 'setting_split_ratio',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `For wide screen`
  String get setting_split_ratio_hint {
    return Intl.message(
      'For wide screen',
      name: 'setting_split_ratio_hint',
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

  /// `Shops`
  String get shop {
    return Intl.message(
      'Shops',
      name: 'shop',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Carousel`
  String get show_carousel {
    return Intl.message(
      'Show Carousel',
      name: 'show_carousel',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Empty Event`
  String get show_empty_event {
    return Intl.message(
      'Show Empty Event',
      name: 'show_empty_event',
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

  /// `Show Fullscreen`
  String get show_fullscreen {
    return Intl.message(
      'Show Fullscreen',
      name: 'show_fullscreen',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Less`
  String get show_less {
    return Intl.message(
      'Show Less',
      name: 'show_less',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show More`
  String get show_more {
    return Intl.message(
      'Show More',
      name: 'show_more',
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

  /// `Show in System Tray`
  String get show_system_tray {
    return Intl.message(
      'Show in System Tray',
      name: 'show_system_tray',
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

  /// `Smulate Enemy Actions`
  String get simulate_enemy_actions {
    return Intl.message(
      'Smulate Enemy Actions',
      name: 'simulate_enemy_actions',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Simulate Simple AI`
  String get simulate_simple_ai {
    return Intl.message(
      'Simulate Simple AI',
      name: 'simulate_simple_ai',
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

  /// `Skill List`
  String get skill_list {
    return Intl.message(
      'Skill List',
      name: 'skill_list',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skill Upgrade`
  String get skill_rankup {
    return Intl.message(
      'Skill Upgrade',
      name: 'skill_rankup',
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

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Skip Current Turn`
  String get skip_current_turn {
    return Intl.message(
      'Skip Current Turn',
      name: 'skip_current_turn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Battle Count`
  String get solution_battle_count {
    return Intl.message(
      'Battle Count',
      name: 'solution_battle_count',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Target Count`
  String get solution_target_count {
    return Intl.message(
      'Target Count',
      name: 'solution_target_count',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Total {battles} battles, {ap} AP`
  String solution_total_battles_ap(Object battles, Object ap) {
    return Intl.message(
      'Total $battles battles, $ap AP',
      name: 'solution_total_battles_ap',
      desc: '',
      locale: localeName,
      args: [battles, ap],
    );
  }

  /// `Sort`
  String get sort_order {
    return Intl.message(
      'Sort',
      name: 'sort_order',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Sound Effect`
  String get sound_effect {
    return Intl.message(
      'Sound Effect',
      name: 'sound_effect',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hide Special Rewards`
  String get special_reward_hide {
    return Intl.message(
      'Hide Special Rewards',
      name: 'special_reward_hide',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Special Rewards`
  String get special_reward_show {
    return Intl.message(
      'Show Special Rewards',
      name: 'special_reward_show',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Spoiler Setting`
  String get spoiler_setting {
    return Intl.message(
      'Spoiler Setting',
      name: 'spoiler_setting',
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

  /// `Pack(s)`
  String get sq_buy_pack_unit {
    return Intl.message(
      'Pack(s)',
      name: 'sq_buy_pack_unit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `21 Fragments = 3 Quartzs`
  String get sq_fragment_convert {
    return Intl.message(
      '21 Fragments = 3 Quartzs',
      name: 'sq_fragment_convert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `SQ`
  String get sq_short {
    return Intl.message(
      'SQ',
      name: 'sq_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Opening Movie`
  String get stage_opening_movie {
    return Intl.message(
      'Opening Movie',
      name: 'stage_opening_movie',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
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

  /// `Story CE`
  String get story_ce {
    return Intl.message(
      'Story CE',
      name: 'story_ce',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Strength Status`
  String get strength_status {
    return Intl.message(
      'Strength Status',
      name: 'strength_status',
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

  /// `Daily`
  String get summon_daily {
    return Intl.message(
      'Daily',
      name: 'summon_daily',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Expectation`
  String get summon_expectation_btn {
    return Intl.message(
      'Expectation',
      name: 'summon_expectation_btn',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Just for entertainment`
  String get summon_gacha_footer {
    return Intl.message(
      'Just for entertainment',
      name: 'summon_gacha_footer',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Results`
  String get summon_gacha_result {
    return Intl.message(
      'Results',
      name: 'summon_gacha_result',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `JP summon data from Mooncell. Reference only for other regions.`
  String get summon_info_hint {
    return Intl.message(
      'JP summon data from Mooncell. Reference only for other regions.',
      name: 'summon_info_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Pull(s)`
  String get summon_pull_unit {
    return Intl.message(
      'Pull(s)',
      name: 'summon_pull_unit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Banner`
  String get summon_show_banner {
    return Intl.message(
      'Show Banner',
      name: 'summon_show_banner',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ticket`
  String get summon_ticket_short {
    return Intl.message(
      'Ticket',
      name: 'summon_ticket_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `SP.DMG`
  String get super_effective_damage {
    return Intl.message(
      'SP.DMG',
      name: 'super_effective_damage',
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

  /// `Support Servant`
  String get support_servant {
    return Intl.message(
      'Support Servant',
      name: 'support_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Forced`
  String get support_servant_forced {
    return Intl.message(
      'Forced',
      name: 'support_servant_forced',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Support`
  String get support_servant_short {
    return Intl.message(
      'Support',
      name: 'support_servant_short',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Svt AI`
  String get svt_ai {
    return Intl.message(
      'Svt AI',
      name: 'svt_ai',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Ascension Icon`
  String get svt_ascension_icon {
    return Intl.message(
      'Ascension Icon',
      name: 'svt_ascension_icon',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Info`
  String get svt_basic_info {
    return Intl.message(
      'Info',
      name: 'svt_basic_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Enemy's card deck may be incorrect, the hits distribution shall prevail.`
  String get svt_card_deck_incorrect {
    return Intl.message(
      'Enemy\'s card deck may be incorrect, the hits distribution shall prevail.',
      name: 'svt_card_deck_incorrect',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Class`
  String get svt_class {
    return Intl.message(
      'Class',
      name: 'svt_class',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Svt Class`
  String get svt_class_dist {
    return Intl.message(
      'Svt Class',
      name: 'svt_class_dist',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Auto`
  String get svt_class_filter_auto {
    return Intl.message(
      'Auto',
      name: 'svt_class_filter_auto',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Hidden`
  String get svt_class_filter_hide {
    return Intl.message(
      'Hidden',
      name: 'svt_class_filter_hide',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `<Extra Class> Collapsed\nSingle Row`
  String get svt_class_filter_single_row {
    return Intl.message(
      '<Extra Class> Collapsed\nSingle Row',
      name: 'svt_class_filter_single_row',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `<Extra Class> Expanded\nSingle Row`
  String get svt_class_filter_single_row_expanded {
    return Intl.message(
      '<Extra Class> Expanded\nSingle Row',
      name: 'svt_class_filter_single_row_expanded',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `<Extra Class> in Second Row`
  String get svt_class_filter_two_row {
    return Intl.message(
      '<Extra Class> in Second Row',
      name: 'svt_class_filter_two_row',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Remember`
  String get svt_fav_btn_remember {
    return Intl.message(
      'Remember',
      name: 'svt_fav_btn_remember',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show All`
  String get svt_fav_btn_show_all {
    return Intl.message(
      'Show All',
      name: 'svt_fav_btn_show_all',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Show Favorite`
  String get svt_fav_btn_show_favorite {
    return Intl.message(
      'Show Favorite',
      name: 'svt_fav_btn_show_favorite',
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

  /// `1. Servant options are independent from Chaldea's plan data once imported, if need to resync planned options please use the Resync option from the dropdown menu in the top right corner\n2. Skill/NP strengthen status can be set manually via options below\n3. You can manually add custom effect/buff\n4. Svt/ce can be pinged to top in the popup menu from their detail pages`
  String get svt_option_edit_tips {
    return Intl.message(
      '1. Servant options are independent from Chaldea\'s plan data once imported, if need to resync planned options please use the Resync option from the dropdown menu in the top right corner\n2. Skill/NP strengthen status can be set manually via options below\n3. You can manually add custom effect/buff\n4. Svt/ce can be pinged to top in the popup menu from their detail pages',
      name: 'svt_option_edit_tips',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Resync Options`
  String get svt_option_resync {
    return Intl.message(
      'Resync Options',
      name: 'svt_option_resync',
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

  /// `Profile`
  String get svt_profile {
    return Intl.message(
      'Profile',
      name: 'svt_profile',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Character Info`
  String get svt_profile_info {
    return Intl.message(
      'Character Info',
      name: 'svt_profile_info',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Profile {n}`
  String svt_profile_n(Object n) {
    return Intl.message(
      'Profile $n',
      name: 'svt_profile_n',
      desc: '',
      locale: localeName,
      args: [n],
    );
  }

  /// `Related CEs`
  String get svt_related_ce {
    return Intl.message(
      'Related CEs',
      name: 'svt_related_ce',
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

  /// `Second Archive`
  String get svt_second_archive {
    return Intl.message(
      'Second Archive',
      name: 'svt_second_archive',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `(SkillMax) Owned/Total`
  String get svt_stat_own_total {
    return Intl.message(
      '(SkillMax) Owned/Total',
      name: 'svt_stat_own_total',
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

  /// `Switch Region`
  String get switch_region {
    return Intl.message(
      'Switch Region',
      name: 'switch_region',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Minimize window for close button`
  String get system_tray_close_hint {
    return Intl.message(
      'Minimize window for close button',
      name: 'system_tray_close_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Target`
  String get target {
    return Intl.message(
      'Target',
      name: 'target',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `NP Animation`
  String get td_animation {
    return Intl.message(
      'NP Animation',
      name: 'td_animation',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `For the same NP id, different owners may have different card type and hit distributions.`
  String get td_base_hits_hint {
    return Intl.message(
      'For the same NP id, different owners may have different card type and hit distributions.',
      name: 'td_base_hits_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `This Nobel Phantasm is displayed as a {color} card, but doesn't have [{trait}] trait.`
  String td_cardcolor_hint(Object color, Object trait) {
    return Intl.message(
      'This Nobel Phantasm is displayed as a $color card, but doesn\'t have [$trait] trait.',
      name: 'td_cardcolor_hint',
      desc: '',
      locale: localeName,
      args: [color, trait],
    );
  }

  /// `This is a Nobel Phantasm, but doesn't have [{trait}] trait.`
  String td_cardnp_hint(Object trait) {
    return Intl.message(
      'This is a Nobel Phantasm, but doesn\'t have [$trait] trait.',
      name: 'td_cardnp_hint',
      desc: '',
      locale: localeName,
      args: [trait],
    );
  }

  /// `NP Upgrade`
  String get td_rankup {
    return Intl.message(
      'NP Upgrade',
      name: 'td_rankup',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Team`
  String get team {
    return Intl.message(
      'Team',
      name: 'team',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Backup`
  String get team_backup_member {
    return Intl.message(
      'Backup',
      name: 'team_backup_member',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Block CE`
  String get team_block_ce {
    return Intl.message(
      'Block CE',
      name: 'team_block_ce',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Block Servant`
  String get team_block_servant {
    return Intl.message(
      'Block Servant',
      name: 'team_block_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Allow MLB`
  String get team_ce_allow_mlb {
    return Intl.message(
      'Allow MLB',
      name: 'team_ce_allow_mlb',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Allow non-MLB`
  String get team_ce_allow_non_mlb {
    return Intl.message(
      'Allow non-MLB',
      name: 'team_ce_allow_non_mlb',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Local Teams`
  String get team_local {
    return Intl.message(
      'Local Teams',
      name: 'team_local',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Append Skill`
  String get team_no_append_skill {
    return Intl.message(
      'No Append Skill',
      name: 'team_no_append_skill',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Grail/☆4 Fou`
  String get team_no_grail_fou {
    return Intl.message(
      'No Grail/☆4 Fou',
      name: 'team_no_grail_fou',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Lv.100+`
  String get team_no_lv100 {
    return Intl.message(
      'No Lv.100+',
      name: 'team_no_lv100',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Order Change`
  String get team_no_order_change {
    return Intl.message(
      'No Order Change',
      name: 'team_no_order_change',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No Same Svt`
  String get team_no_same_svt {
    return Intl.message(
      'No Same Svt',
      name: 'team_no_same_svt',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `[With Details] Unreleased servant xxx/low success rate/cannot clear quest/etc.\nAsk admin to delete team rather to edit team.`
  String get team_report_reason_hint {
    return Intl.message(
      '[With Details] Unreleased servant xxx/low success rate/cannot clear quest/etc.\nAsk admin to delete team rather to edit team.',
      name: 'team_report_reason_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Shared Teams`
  String get team_shared {
    return Intl.message(
      'Shared Teams',
      name: 'team_shared',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Frontline`
  String get team_starting_member {
    return Intl.message(
      'Frontline',
      name: 'team_starting_member',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Use Servant`
  String get team_use_servant {
    return Intl.message(
      'Use Servant',
      name: 'team_use_servant',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Test`
  String get test {
    return Intl.message(
      'Test',
      name: 'test',
      desc: '',
      locale: localeName,
      args: [],
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

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Close`
  String get time_close {
    return Intl.message(
      'Close',
      name: 'time_close',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `End`
  String get time_end {
    return Intl.message(
      'End',
      name: 'time_end',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Start`
  String get time_start {
    return Intl.message(
      'Start',
      name: 'time_start',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Tips`
  String get tips {
    return Intl.message(
      'Tips',
      name: 'tips',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Toggle Dark Mode`
  String get toggle_dark_mode {
    return Intl.message(
      'Toggle Dark Mode',
      name: 'toggle_dark_mode',
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

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
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

  /// `Total NP`
  String get total_np {
    return Intl.message(
      'Total NP',
      name: 'total_np',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Trait`
  String get trait {
    return Intl.message(
      'Trait',
      name: 'trait',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Draw Cost`
  String get treasure_box_draw_cost {
    return Intl.message(
      'Draw Cost',
      name: 'treasure_box_draw_cost',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Extra Gifts per box`
  String get treasure_box_extra_gift {
    return Intl.message(
      'Extra Gifts per box',
      name: 'treasure_box_extra_gift',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Max Draws at once:`
  String get treasure_box_max_draw_once {
    return Intl.message(
      'Max Draws at once:',
      name: 'treasure_box_max_draw_once',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Trial Quest`
  String get trial_quest {
    return Intl.message(
      'Trial Quest',
      name: 'trial_quest',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Turn Remaining Limit`
  String get turn_remain_limit {
    return Intl.message(
      'Turn Remaining Limit',
      name: 'turn_remain_limit',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Considered Lose after turn countdown is over`
  String get turn_remain_limit_lose {
    return Intl.message(
      'Considered Lose after turn countdown is over',
      name: 'turn_remain_limit_lose',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Considered Win after turn countdown is over`
  String get turn_remain_limit_win {
    return Intl.message(
      'Considered Win after turn countdown is over',
      name: 'turn_remain_limit_win',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Usually for w-Koyan team`
  String get twice_skill_hint {
    return Intl.message(
      'Usually for w-Koyan team',
      name: 'twice_skill_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Twice skills if Cool Down after 2 turns`
  String get twice_skill_if_cd2 {
    return Intl.message(
      'Twice skills if Cool Down after 2 turns',
      name: 'twice_skill_if_cd2',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unlock`
  String get unlock {
    return Intl.message(
      'Unlock',
      name: 'unlock',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Unlock Quest`
  String get unlock_quest {
    return Intl.message(
      'Unlock Quest',
      name: 'unlock_quest',
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

  /// `Update on Startup`
  String get update_data_at_start {
    return Intl.message(
      'Update on Startup',
      name: 'update_data_at_start',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Load local data then background update, apply updates at next startup`
  String get update_data_at_start_off_hint {
    return Intl.message(
      'Load local data then background update, apply updates at next startup',
      name: 'update_data_at_start_off_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `May take more time to startup`
  String get update_data_at_start_on_hint {
    return Intl.message(
      'May take more time to startup',
      name: 'update_data_at_start_on_hint',
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

  /// `Update failed`
  String get update_msg_error {
    return Intl.message(
      'Update failed',
      name: 'update_msg_error',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `No update available`
  String get update_msg_no_update {
    return Intl.message(
      'No update available',
      name: 'update_msg_no_update',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Updated`
  String get updated {
    return Intl.message(
      'Updated',
      name: 'updated',
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

  /// `Upload & Close`
  String get upload_and_close_app {
    return Intl.message(
      'Upload & Close',
      name: 'upload_and_close_app',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Upload data before closing the app?`
  String get upload_and_close_app_alert {
    return Intl.message(
      'Upload data before closing the app?',
      name: 'upload_and_close_app_alert',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Upload before closing`
  String get upload_before_close_app {
    return Intl.message(
      'Upload before closing',
      name: 'upload_before_close_app',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Current team is not eligible for upload due to:`
  String get upload_not_eligible_hint {
    return Intl.message(
      'Current team is not eligible for upload due to:',
      name: 'upload_not_eligible_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Need to wait {pause} seconds between uploads ({remain}s remain).`
  String upload_paused(Object pause, Object remain) {
    return Intl.message(
      'Need to wait $pause seconds between uploads (${remain}s remain).',
      name: 'upload_paused',
      desc: '',
      locale: localeName,
      args: [pause, remain],
    );
  }

  /// `Upload current team?\n\nAttention: don't upload team which contains unreleased servants!\nUploaded data may be deleted due to future updates, data incompatibility etc.`
  String get upload_team_confirmation {
    return Intl.message(
      'Upload current team?\n\nAttention: don\'t upload team which contains unreleased servants!\nUploaded data may be deleted due to future updates, data incompatibility etc.',
      name: 'upload_team_confirmation',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Usage`
  String get usage {
    return Intl.message(
      'Usage',
      name: 'usage',
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

  /// `Userdata (Local)`
  String get userdata_local {
    return Intl.message(
      'Userdata (Local)',
      name: 'userdata_local',
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

  /// `Only update account data, not include local settings`
  String get userdata_sync_hint {
    return Intl.message(
      'Only update account data, not include local settings',
      name: 'userdata_sync_hint',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Data synchronization(Server)`
  String get userdata_sync_server {
    return Intl.message(
      'Data synchronization(Server)',
      name: 'userdata_sync_server',
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

  /// `Valentine Script`
  String get valentine_script {
    return Intl.message(
      'Valentine Script',
      name: 'valentine_script',
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

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
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

  /// `War`
  String get war {
    return Intl.message(
      'War',
      name: 'war',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Age`
  String get war_age {
    return Intl.message(
      'Age',
      name: 'war_age',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Banner`
  String get war_banner {
    return Intl.message(
      'Banner',
      name: 'war_banner',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `War Board`
  String get war_board {
    return Intl.message(
      'War Board',
      name: 'war_board',
      desc: '',
      locale: localeName,
      args: [],
    );
  }

  /// `Map`
  String get war_map {
    return Intl.message(
      'Map',
      name: 'war_map',
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

  /// `CN endpoint for China mainland\nWeb app is only recommended for PC users, Mobile website is laggy and may refresh unexpectedly.`
  String get web_domain_choice_hint {
    return Intl.message(
      'CN endpoint for China mainland\nWeb app is only recommended for PC users, Mobile website is laggy and may refresh unexpectedly.',
      name: 'web_domain_choice_hint',
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
