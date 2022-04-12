// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(email, logPath) =>
      "Please send screenshot and log file to email:\n ${email}\nLog filepath: ${logPath}";

  static String m1(curVersion, newVersion, releaseNote) =>
      "Current version: ${curVersion}\nLatest version: ${newVersion}\nRelease Note:\n${releaseNote}";

  static String m2(name) => "Source ${name}";

  static String m3(version) => "Required app version: ≥ ${version}";

  static String m4(n) => "Max ${n} lottery";

  static String m5(n) => "Grail to crystal: ${n}";

  static String m6(filename, hash, localHash) =>
      "File ${filename} not found or mismatched hash: ${hash} - ${localHash}";

  static String m7(filename, hash, dataHash) =>
      "Hash mismatch: ${filename}: ${hash} - ${dataHash}";

  static String m8(error) => "Import failed. Error:\n${error}";

  static String m9(account) => "Switched to account ${account}";

  static String m10(itemNum, svtNum) =>
      "Import ${itemNum} items and ${svtNum} svts to";

  static String m11(name) => "${name} already exist";

  static String m12(site) => "Jump to ${site}";

  static String m13(first) => "${Intl.select(first, {
            'true': 'Already the first one',
            'false': 'Already the last one',
            'other': 'No more',
          })}";

  static String m14(version) => "Updated dataset to ${version}";

  static String m15(index) => "Plan ${index}";

  static String m16(n) => "Reset Plan ${n}(All)";

  static String m17(n) => "Reset Plan ${n}(Shown)";

  static String m18(total) => "Total ${total} results";

  static String m19(total, hidden) =>
      "Total ${total} results (${hidden} hidden)";

  static String m20(server) => "Sync with ${server}";

  static String m21(e) => "Update slides failed\n${e}";

  static String m22(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("About"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "The data used in this application comes from game Fate/GO and the following websites. The copyright of the original texts, pictures and voices of game belongs to TYPE MOON/FGO PROJECT.\n\nThe design of program is based on the WeChat mini program \"Material Programe\" and the iOS application \"Guda\".\n"),
        "about_appstore_rating":
            MessageLookupByLibrary.simpleMessage("App Store Rating"),
        "about_data_source":
            MessageLookupByLibrary.simpleMessage("Data source"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "Please inform us if there is unmarked source or infringement."),
        "about_email_dialog": m0,
        "about_email_subtitle": MessageLookupByLibrary.simpleMessage(
            "Please attach screenshot and log file"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "about_update_app": MessageLookupByLibrary.simpleMessage("App Update"),
        "about_update_app_alert_ios_mac": MessageLookupByLibrary.simpleMessage(
            "Please check update in App Store"),
        "about_update_app_detail": m1,
        "account_title": MessageLookupByLibrary.simpleMessage("Account"),
        "active_skill": MessageLookupByLibrary.simpleMessage("Active Skill"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("Please add feedback details"),
        "add_to_blacklist":
            MessageLookupByLibrary.simpleMessage("Add to blacklist"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("口算不及格的咕朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("AP Calc"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP rate"),
        "ap_overflow_time":
            MessageLookupByLibrary.simpleMessage("Time of AP Full"),
        "append_skill": MessageLookupByLibrary.simpleMessage("Append Skill"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("Append"),
        "ascension": MessageLookupByLibrary.simpleMessage("Ascension"),
        "ascension_icon":
            MessageLookupByLibrary.simpleMessage("Ascension Icon"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("Ascen"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("Ascension"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("From Files"),
        "attach_from_photos":
            MessageLookupByLibrary.simpleMessage("From Photos"),
        "attach_help": MessageLookupByLibrary.simpleMessage(
            "If you have trouble picking images, use files instead"),
        "attachment": MessageLookupByLibrary.simpleMessage("Attachment"),
        "auto_reset": MessageLookupByLibrary.simpleMessage("Auto reset"),
        "auto_update": MessageLookupByLibrary.simpleMessage("Auto Update"),
        "backup": MessageLookupByLibrary.simpleMessage("Backup"),
        "backup_data_alert":
            MessageLookupByLibrary.simpleMessage("Timely backup wanted"),
        "backup_history":
            MessageLookupByLibrary.simpleMessage("Backup History"),
        "backup_success":
            MessageLookupByLibrary.simpleMessage("Backup successfully"),
        "blacklist": MessageLookupByLibrary.simpleMessage("Blacklist"),
        "bond": MessageLookupByLibrary.simpleMessage("Bond"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("Bond Craft"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("Bond Eff"),
        "boostrap_page_title":
            MessageLookupByLibrary.simpleMessage("Bootstrap Page"),
        "bronze": MessageLookupByLibrary.simpleMessage("Bronze"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("Wight"),
        "calculate": MessageLookupByLibrary.simpleMessage("Calculate"),
        "calculator": MessageLookupByLibrary.simpleMessage("Calculator"),
        "campaign_event": MessageLookupByLibrary.simpleMessage("Campaign"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "card_description": MessageLookupByLibrary.simpleMessage("Description"),
        "card_info": MessageLookupByLibrary.simpleMessage("Info"),
        "carousel_setting":
            MessageLookupByLibrary.simpleMessage("Carousel Setting"),
        "chaldea_user": MessageLookupByLibrary.simpleMessage("Chaldea User"),
        "change_log": MessageLookupByLibrary.simpleMessage("Change Log"),
        "characters_in_card":
            MessageLookupByLibrary.simpleMessage("Characters"),
        "check_update": MessageLookupByLibrary.simpleMessage("Check update"),
        "choose_quest_hint":
            MessageLookupByLibrary.simpleMessage("Choose Free Quest"),
        "clear": MessageLookupByLibrary.simpleMessage("Clear"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("Clear cache"),
        "clear_cache_finish":
            MessageLookupByLibrary.simpleMessage("Cache cleared"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage(
            "Including illustrations, voices"),
        "clear_data": MessageLookupByLibrary.simpleMessage("Clear Data"),
        "clear_userdata":
            MessageLookupByLibrary.simpleMessage("Clear Userdata"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("Command Code"),
        "command_code": MessageLookupByLibrary.simpleMessage("Command Code"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "consumed": MessageLookupByLibrary.simpleMessage("Consumed"),
        "contact_information_not_filled": MessageLookupByLibrary.simpleMessage(
            "Contact information is not filled in"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage(
                "The developer will not be able to respond to your feedback"),
        "copied": MessageLookupByLibrary.simpleMessage("Copied"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "copy_plan_menu":
            MessageLookupByLibrary.simpleMessage("Copy Plan from..."),
        "costume": MessageLookupByLibrary.simpleMessage("Costume"),
        "costume_unlock":
            MessageLookupByLibrary.simpleMessage("Costume Unlock"),
        "counts": MessageLookupByLibrary.simpleMessage("Counts"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("Craft Essence"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("Craft"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "You can add more accounts later in Settings"),
        "create_account_textfield_hint":
            MessageLookupByLibrary.simpleMessage("Any name"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("Create duplicated"),
        "critical_attack": MessageLookupByLibrary.simpleMessage("Critical"),
        "cur_account": MessageLookupByLibrary.simpleMessage("Current Account"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("Current AP"),
        "current_": MessageLookupByLibrary.simpleMessage("Current"),
        "current_version":
            MessageLookupByLibrary.simpleMessage("Current Version"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Dark mode"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("Light color"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("System"),
        "database": MessageLookupByLibrary.simpleMessage("Database"),
        "database_not_downloaded": MessageLookupByLibrary.simpleMessage(
            "Database is not downloaded, still continue?"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("Goto download webpage"),
        "dataset_goto_download_page_hint":
            MessageLookupByLibrary.simpleMessage("Import after downloaded"),
        "dataset_management":
            MessageLookupByLibrary.simpleMessage("Data Management"),
        "dataset_type_image":
            MessageLookupByLibrary.simpleMessage("Icon dataset"),
        "dataset_type_text":
            MessageLookupByLibrary.simpleMessage("Text dataset"),
        "dataset_version":
            MessageLookupByLibrary.simpleMessage("Dataset version"),
        "debug": MessageLookupByLibrary.simpleMessage("Debug"),
        "debug_fab": MessageLookupByLibrary.simpleMessage("Debug FAB"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("Debug Menu"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "demands": MessageLookupByLibrary.simpleMessage("Demands"),
        "display_setting":
            MessageLookupByLibrary.simpleMessage("Display Settings"),
        "done": MessageLookupByLibrary.simpleMessage("DONE"),
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "download_complete": MessageLookupByLibrary.simpleMessage("Downloaded"),
        "download_full_gamedata":
            MessageLookupByLibrary.simpleMessage("Download latest Gamedata"),
        "download_full_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("Full size zip file"),
        "download_latest_gamedata":
            MessageLookupByLibrary.simpleMessage("Download latest"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "To ensure compatibility, please upgrade to the latest APP version before updating"),
        "download_source":
            MessageLookupByLibrary.simpleMessage("Download source"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("update dataset and app"),
        "download_source_of": m2,
        "downloaded": MessageLookupByLibrary.simpleMessage("Downloaded"),
        "downloading": MessageLookupByLibrary.simpleMessage("Downloading"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("Click + to add items"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("Min AP"),
        "drop_calc_optimize": MessageLookupByLibrary.simpleMessage("Optimize"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("Solve"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("Drop rate"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "effect_search": MessageLookupByLibrary.simpleMessage("Buff Search"),
        "efficiency": MessageLookupByLibrary.simpleMessage("Efficiency"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("Efficient"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP Rate"),
        "efficiency_type_drop":
            MessageLookupByLibrary.simpleMessage("Drop Rate"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("Enemies"),
        "enhance": MessageLookupByLibrary.simpleMessage("Enhance"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage(
            "The following items will be consumed for enhancement"),
        "error_no_internet":
            MessageLookupByLibrary.simpleMessage("No internet"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("No network"),
        "error_no_version_data_found":
            MessageLookupByLibrary.simpleMessage("No version data found"),
        "error_required_app_version": m3,
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "All items will be added to bag and remove the event out of plan"),
        "event_collect_items":
            MessageLookupByLibrary.simpleMessage("Collect Items"),
        "event_item_default":
            MessageLookupByLibrary.simpleMessage("Shop/Task/Points/Quests"),
        "event_item_extra":
            MessageLookupByLibrary.simpleMessage("Extra Obtains"),
        "event_lottery_limit_hint": m4,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("Limited lottery"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("Lottery"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("Unlimited lottery"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("Event not planned"),
        "event_progress": MessageLookupByLibrary.simpleMessage("Progress"),
        "event_rerun_replace_grail": m5,
        "event_title": MessageLookupByLibrary.simpleMessage("Event"),
        "exchange_ticket":
            MessageLookupByLibrary.simpleMessage("Exchange Ticket"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("Ticket"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("Levels"),
        "exp_card_rarity5": MessageLookupByLibrary.simpleMessage("5☆ Exp Card"),
        "exp_card_same_class":
            MessageLookupByLibrary.simpleMessage("Same Class"),
        "exp_card_select_lvs":
            MessageLookupByLibrary.simpleMessage("Select Level Range"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("Exp Card"),
        "failed": MessageLookupByLibrary.simpleMessage("Failed"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("Favorite"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("e.g. screenshots, files."),
        "feedback_add_crash_log":
            MessageLookupByLibrary.simpleMessage("Add crash log"),
        "feedback_contact":
            MessageLookupByLibrary.simpleMessage("Contact information"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("Feedback or Suggestion"),
        "feedback_form_alert": MessageLookupByLibrary.simpleMessage(
            "Feedback form is not empty, still exist?"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "Please check <**FAQ**> first before sending feedback. And following detail is desired:\n- How to reproduce, expected behaviour\n- App/dataset version, device system and version\n- Attach screenshots and logs\n- It\'s better to provide contact info (e.g. Email)"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("Send"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("Subject"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("Background"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("Body"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("Crop"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("Head"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "Please download or import FFO data first↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("Same Servant"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("Domus Aurea"),
        "file_not_found_or_mismatched_hash": m6,
        "filename": MessageLookupByLibrary.simpleMessage("filename"),
        "fill_email_warning": MessageLookupByLibrary.simpleMessage(
            "Please fill in email address. Otherwise NO reply."),
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("Type"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("Attribute"),
        "filter_category": MessageLookupByLibrary.simpleMessage("Category"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("Effects"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("Match All"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("Obtains"),
        "filter_plan_not_reached":
            MessageLookupByLibrary.simpleMessage("Plan-not-reach"),
        "filter_plan_reached":
            MessageLookupByLibrary.simpleMessage("Plan-reached"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("Revert"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("Display"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("Skills"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("Sort"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("Class"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("No"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("Rarity"),
        "filter_special_trait":
            MessageLookupByLibrary.simpleMessage("Special Trait"),
        "free_efficiency":
            MessageLookupByLibrary.simpleMessage("Free Efficiency"),
        "free_progress": MessageLookupByLibrary.simpleMessage("Quest Limit"),
        "free_progress_newest":
            MessageLookupByLibrary.simpleMessage("Latest(JP)"),
        "free_quest": MessageLookupByLibrary.simpleMessage("Free Quest"),
        "free_quest_calculator":
            MessageLookupByLibrary.simpleMessage("Free Quest"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("Free Quest"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("Home"),
        "game_data_not_found": MessageLookupByLibrary.simpleMessage(
            "Game data not found, please download data first"),
        "game_drop": MessageLookupByLibrary.simpleMessage("Drop"),
        "game_experience": MessageLookupByLibrary.simpleMessage("Experience"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("Bond"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("Rewards"),
        "game_server": MessageLookupByLibrary.simpleMessage("Game Server"),
        "game_server_cn":
            MessageLookupByLibrary.simpleMessage("Chinese(Simplified)"),
        "game_server_jp": MessageLookupByLibrary.simpleMessage("Japanese"),
        "game_server_na": MessageLookupByLibrary.simpleMessage("English(NA)"),
        "game_server_tw":
            MessageLookupByLibrary.simpleMessage("Chinese(Traditional)"),
        "gamedata": MessageLookupByLibrary.simpleMessage("Gamedata"),
        "gold": MessageLookupByLibrary.simpleMessage("Gold"),
        "grail": MessageLookupByLibrary.simpleMessage("Grail"),
        "grail_level": MessageLookupByLibrary.simpleMessage("Grail"),
        "grail_up": MessageLookupByLibrary.simpleMessage("Palingenesis"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("Growth Curve"),
        "guda_item_data":
            MessageLookupByLibrary.simpleMessage("Guda Item Data"),
        "guda_servant_data":
            MessageLookupByLibrary.simpleMessage("Guda Servant Data"),
        "hash_mismatch": m7,
        "hello": MessageLookupByLibrary.simpleMessage("Hello! Master!"),
        "help": MessageLookupByLibrary.simpleMessage("Help"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("Hide Outdated"),
        "hint_no_bond_craft":
            MessageLookupByLibrary.simpleMessage("No bond craft"),
        "hint_no_valentine_craft":
            MessageLookupByLibrary.simpleMessage("No valentine craft"),
        "icons": MessageLookupByLibrary.simpleMessage("Icons"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignore"),
        "illustration": MessageLookupByLibrary.simpleMessage("Illustration"),
        "illustrator": MessageLookupByLibrary.simpleMessage("Illustrator"),
        "image_analysis":
            MessageLookupByLibrary.simpleMessage("Image analysis"),
        "import_data": MessageLookupByLibrary.simpleMessage("Import"),
        "import_data_error": m8,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("Import data successfully"),
        "import_guda_data": MessageLookupByLibrary.simpleMessage("Guda Data"),
        "import_guda_hint": MessageLookupByLibrary.simpleMessage(
            "Update：remain current userdata and update(Recommended)\nOverride：clear userdata then updatee"),
        "import_guda_items":
            MessageLookupByLibrary.simpleMessage("Import Item"),
        "import_guda_servants":
            MessageLookupByLibrary.simpleMessage("Import Servant"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("Duplicated"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "Click import button to import decrypted HTTPS response"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            "Click servant to hide/unhide"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("Locked Only"),
        "import_http_body_success_switch": m9,
        "import_http_body_target_account_header": m10,
        "import_screenshot":
            MessageLookupByLibrary.simpleMessage("Import Screenshots"),
        "import_screenshot_hint": MessageLookupByLibrary.simpleMessage(
            "Only update recognized items"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("Update Items"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("Import Source File"),
        "info_agility": MessageLookupByLibrary.simpleMessage("Agility"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("Alignment"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("Bond Points"),
        "info_bond_points_single":
            MessageLookupByLibrary.simpleMessage("Point"),
        "info_bond_points_sum": MessageLookupByLibrary.simpleMessage("Sum"),
        "info_cards": MessageLookupByLibrary.simpleMessage("Cards"),
        "info_critical_rate":
            MessageLookupByLibrary.simpleMessage("Critical Rate"),
        "info_cv": MessageLookupByLibrary.simpleMessage("Voice Actor"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("Death Rate"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("Endurance"),
        "info_gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "info_height": MessageLookupByLibrary.simpleMessage("Height"),
        "info_human": MessageLookupByLibrary.simpleMessage("Human"),
        "info_luck": MessageLookupByLibrary.simpleMessage("Luck"),
        "info_mana": MessageLookupByLibrary.simpleMessage("Mana"),
        "info_np": MessageLookupByLibrary.simpleMessage("NP"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP Rate"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("Star Rate"),
        "info_strength": MessageLookupByLibrary.simpleMessage("Strength"),
        "info_trait": MessageLookupByLibrary.simpleMessage("Traits"),
        "info_value": MessageLookupByLibrary.simpleMessage("Value"),
        "info_weak_to_ea": MessageLookupByLibrary.simpleMessage("Weak to EA"),
        "info_weight": MessageLookupByLibrary.simpleMessage("Weight"),
        "input_invalid_hint":
            MessageLookupByLibrary.simpleMessage("Invalid inputs"),
        "install": MessageLookupByLibrary.simpleMessage("Install"),
        "interlude_and_rankup":
            MessageLookupByLibrary.simpleMessage("Interlude & Rank Up"),
        "invalid_input": MessageLookupByLibrary.simpleMessage("Invalid input."),
        "invalid_startup_path":
            MessageLookupByLibrary.simpleMessage("Invalid startup path!"),
        "invalid_startup_path_info": MessageLookupByLibrary.simpleMessage(
            "Please, extract zip to non-system path then start the app. \"C:\\\", \"C:\\Program Files\" are not allowed."),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"Files\" app/On My iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("Issues"),
        "item": MessageLookupByLibrary.simpleMessage("Item"),
        "item_already_exist_hint": m11,
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("Ascension Items"),
        "item_category_bronze":
            MessageLookupByLibrary.simpleMessage("Bronze Items"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("Event Item"),
        "item_category_gem": MessageLookupByLibrary.simpleMessage("Gem"),
        "item_category_gems":
            MessageLookupByLibrary.simpleMessage("Skill Items"),
        "item_category_gold":
            MessageLookupByLibrary.simpleMessage("Gold Items"),
        "item_category_magic_gem":
            MessageLookupByLibrary.simpleMessage("Magic Gem"),
        "item_category_monument":
            MessageLookupByLibrary.simpleMessage("Monument"),
        "item_category_others": MessageLookupByLibrary.simpleMessage("Others"),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("Piece"),
        "item_category_secret_gem":
            MessageLookupByLibrary.simpleMessage("Secret Gem"),
        "item_category_silver":
            MessageLookupByLibrary.simpleMessage("Silver Items"),
        "item_category_special":
            MessageLookupByLibrary.simpleMessage("Special Items"),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("Items"),
        "item_eff": MessageLookupByLibrary.simpleMessage("Item Eff"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "Before planning, you can set exceeded num for items(Only used for free quest planning)"),
        "item_left": MessageLookupByLibrary.simpleMessage("Left"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("No Free Quests"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("Only show lacked"),
        "item_own": MessageLookupByLibrary.simpleMessage("Owned"),
        "item_screenshot":
            MessageLookupByLibrary.simpleMessage("Item Screenshot"),
        "item_title": MessageLookupByLibrary.simpleMessage("Item"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("Total"),
        "join_beta": MessageLookupByLibrary.simpleMessage("Join Beta Program"),
        "jump_to": m12,
        "language": MessageLookupByLibrary.simpleMessage("English"),
        "language_en": MessageLookupByLibrary.simpleMessage("English"),
        "level": MessageLookupByLibrary.simpleMessage("Level"),
        "limited_event": MessageLookupByLibrary.simpleMessage("Limited Event"),
        "link": MessageLookupByLibrary.simpleMessage("link"),
        "list_end_hint": m13,
        "load_dataset_error":
            MessageLookupByLibrary.simpleMessage("Error loading dataset"),
        "load_dataset_error_hint": MessageLookupByLibrary.simpleMessage(
            "Please reload default gamedata in Settings-Gamedata"),
        "loading_data_failed":
            MessageLookupByLibrary.simpleMessage("Loading Data Failed"),
        "login_change_name":
            MessageLookupByLibrary.simpleMessage("Change Name"),
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "login_confirm_password":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "login_first_hint":
            MessageLookupByLibrary.simpleMessage("Please login first"),
        "login_forget_pwd":
            MessageLookupByLibrary.simpleMessage("Forget Password"),
        "login_login": MessageLookupByLibrary.simpleMessage("Login"),
        "login_logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "login_new_name": MessageLookupByLibrary.simpleMessage("New Name"),
        "login_new_password":
            MessageLookupByLibrary.simpleMessage("New Password"),
        "login_password": MessageLookupByLibrary.simpleMessage("Password"),
        "login_password_error": MessageLookupByLibrary.simpleMessage(
            "Can only contain letters and numbers, no less than 4 digits"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage(
                "Cannot be the same as the old password"),
        "login_signup": MessageLookupByLibrary.simpleMessage("Signup"),
        "login_state_not_login":
            MessageLookupByLibrary.simpleMessage("Not logged in"),
        "login_username": MessageLookupByLibrary.simpleMessage("Username"),
        "login_username_error": MessageLookupByLibrary.simpleMessage(
            "Can only contain letters and numbers, starting with a letter, no less than 4 digits"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("Long press to save"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("Lucky Bag"),
        "main_record": MessageLookupByLibrary.simpleMessage("Main Record"),
        "main_record_bonus": MessageLookupByLibrary.simpleMessage("Bonus"),
        "main_record_bonus_short":
            MessageLookupByLibrary.simpleMessage("Bonus"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("Chapter"),
        "main_record_fixed_drop": MessageLookupByLibrary.simpleMessage("Drops"),
        "main_record_fixed_drop_short":
            MessageLookupByLibrary.simpleMessage("Drops"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Master-Detail width"),
        "master_mission":
            MessageLookupByLibrary.simpleMessage("Master Mission"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("Related Quests"),
        "master_mission_solution":
            MessageLookupByLibrary.simpleMessage("Solution"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("Missions"),
        "max_ap": MessageLookupByLibrary.simpleMessage("Maximum AP"),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "move_down": MessageLookupByLibrary.simpleMessage("Move down"),
        "move_up": MessageLookupByLibrary.simpleMessage("Move up"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("Mystic Code"),
        "new_account": MessageLookupByLibrary.simpleMessage("New account"),
        "next": MessageLookupByLibrary.simpleMessage("NEXT"),
        "next_card": MessageLookupByLibrary.simpleMessage("Next"),
        "nga": MessageLookupByLibrary.simpleMessage("NGA"),
        "nga_fgo": MessageLookupByLibrary.simpleMessage("NGA-FGO"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "no_servant_quest_hint": MessageLookupByLibrary.simpleMessage(
            "There is no interlude or rank up quest"),
        "no_servant_quest_hint_subtitle": MessageLookupByLibrary.simpleMessage(
            "Click ♡ to view all servants\' quests"),
        "noble_phantasm":
            MessageLookupByLibrary.simpleMessage("Noble Phantasm"),
        "noble_phantasm_level":
            MessageLookupByLibrary.simpleMessage("Noble Phantasm"),
        "not_available": MessageLookupByLibrary.simpleMessage("Not Available"),
        "not_found": MessageLookupByLibrary.simpleMessage("Not Found"),
        "not_implemented":
            MessageLookupByLibrary.simpleMessage("Not yet implemented"),
        "obtain_methods": MessageLookupByLibrary.simpleMessage("Obtains"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("Open"),
        "open_condition": MessageLookupByLibrary.simpleMessage("Condition"),
        "overview": MessageLookupByLibrary.simpleMessage("Overview"),
        "overwrite": MessageLookupByLibrary.simpleMessage("Override"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("Passive Skill"),
        "patch_gamedata":
            MessageLookupByLibrary.simpleMessage("Patch Gamedata"),
        "patch_gamedata_error_no_compatible":
            MessageLookupByLibrary.simpleMessage(
                "No compatible version with current app version"),
        "patch_gamedata_error_unknown_version":
            MessageLookupByLibrary.simpleMessage(
                "Cannot found current version on server, downloading full size package"),
        "patch_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("Only patch downloaded"),
        "patch_gamedata_success_to": m14,
        "plan": MessageLookupByLibrary.simpleMessage("Plan"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("Plan Max(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("Plan Max(999)"),
        "plan_objective":
            MessageLookupByLibrary.simpleMessage("Plan Objective"),
        "plan_title": MessageLookupByLibrary.simpleMessage("Plan"),
        "plan_x": m15,
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("Planning Quests"),
        "preferred_translation":
            MessageLookupByLibrary.simpleMessage("Preferred Translation"),
        "preferred_translation_footer": MessageLookupByLibrary.simpleMessage(
            "Drag to change the order.\nUsed for game data description, not UI language. Not all game data is translated for all 5 official languages."),
        "prev": MessageLookupByLibrary.simpleMessage("PREV"),
        "preview": MessageLookupByLibrary.simpleMessage("Preview"),
        "previous_card": MessageLookupByLibrary.simpleMessage("Previous"),
        "priority": MessageLookupByLibrary.simpleMessage("Priority"),
        "project_homepage":
            MessageLookupByLibrary.simpleMessage("Project Homepage"),
        "query_failed": MessageLookupByLibrary.simpleMessage("Query failed"),
        "quest": MessageLookupByLibrary.simpleMessage("Quest"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("Conditions"),
        "rarity": MessageLookupByLibrary.simpleMessage("Rarity"),
        "rate_app_store":
            MessageLookupByLibrary.simpleMessage("Rate on App Store"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Rate on Google Play"),
        "release_page": MessageLookupByLibrary.simpleMessage("Release Page"),
        "reload_data_success":
            MessageLookupByLibrary.simpleMessage("Import successfully"),
        "reload_default_gamedata":
            MessageLookupByLibrary.simpleMessage("Reload default"),
        "reloading_data": MessageLookupByLibrary.simpleMessage("Importing"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("Remove duplicated"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("Remove from blacklist"),
        "rename": MessageLookupByLibrary.simpleMessage("Rename"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("Rerun"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "reset_plan_all": m16,
        "reset_plan_shown": m17,
        "reset_success":
            MessageLookupByLibrary.simpleMessage("Reset successfully"),
        "reset_svt_enhance_state":
            MessageLookupByLibrary.simpleMessage("Reset default skill/NP"),
        "reset_svt_enhance_state_hint": MessageLookupByLibrary.simpleMessage(
            "Reset rank up of skills and noble phantasm"),
        "restart_to_take_effect":
            MessageLookupByLibrary.simpleMessage("Restart to take effect"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "Restart to upgrade. If the update fails, please manually copy the source folder to destination"),
        "restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("SQ Plan"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "save_to_photos":
            MessageLookupByLibrary.simpleMessage("Save to Photos"),
        "saved": MessageLookupByLibrary.simpleMessage("Saved"),
        "screen_size": MessageLookupByLibrary.simpleMessage("Screen Size"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("Basic"),
        "search_options": MessageLookupByLibrary.simpleMessage("Search Scopes"),
        "search_result_count": m18,
        "search_result_count_hide": m19,
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("Select copy source"),
        "select_lang": MessageLookupByLibrary.simpleMessage("Select Language"),
        "select_plan": MessageLookupByLibrary.simpleMessage("Select Plan"),
        "send_email_to": MessageLookupByLibrary.simpleMessage("Send email to"),
        "sending": MessageLookupByLibrary.simpleMessage("Sending"),
        "sending_failed":
            MessageLookupByLibrary.simpleMessage("Sending failed"),
        "sent": MessageLookupByLibrary.simpleMessage("Sent"),
        "servant": MessageLookupByLibrary.simpleMessage("Servant"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("Servant Coin"),
        "servant_detail_page":
            MessageLookupByLibrary.simpleMessage("Servant Detail Page"),
        "servant_list_page":
            MessageLookupByLibrary.simpleMessage("Servant List Page"),
        "servant_title": MessageLookupByLibrary.simpleMessage("Servant"),
        "set_plan_name": MessageLookupByLibrary.simpleMessage("Set Plan Name"),
        "setting_always_on_top":
            MessageLookupByLibrary.simpleMessage("Always On Top"),
        "setting_auto_rotate":
            MessageLookupByLibrary.simpleMessage("Auto Rotate"),
        "setting_auto_turn_on_plan_not_reach":
            MessageLookupByLibrary.simpleMessage("Auto Turn on PlanNotReach"),
        "setting_home_plan_list_page":
            MessageLookupByLibrary.simpleMessage("Home-Plan List Page"),
        "setting_only_change_second_append_skill":
            MessageLookupByLibrary.simpleMessage(
                "Only Change 2nd Append Skill"),
        "setting_plans_list_page":
            MessageLookupByLibrary.simpleMessage("Plans List Page"),
        "setting_priority_tagging":
            MessageLookupByLibrary.simpleMessage("Priority Tagging"),
        "setting_servant_class_filter_style":
            MessageLookupByLibrary.simpleMessage("Servant Class Filter Style"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage("Favorite Button Default"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage("Show Account at Homepage"),
        "setting_tabs_sorting":
            MessageLookupByLibrary.simpleMessage("Tabs Sorting"),
        "settings_data": MessageLookupByLibrary.simpleMessage("Data"),
        "settings_data_management":
            MessageLookupByLibrary.simpleMessage("Data Management"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("Documents"),
        "settings_general": MessageLookupByLibrary.simpleMessage("General"),
        "settings_language": MessageLookupByLibrary.simpleMessage("Language"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("Settings"),
        "settings_use_mobile_network":
            MessageLookupByLibrary.simpleMessage("Allow mobile network"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "Backup userdata before upgrading application, and move backups to safe locations outside app\'s document folder"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "show_frame_rate":
            MessageLookupByLibrary.simpleMessage("Show Frame Rate"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("Show Outdated"),
        "silver": MessageLookupByLibrary.simpleMessage("Silver"),
        "simulator": MessageLookupByLibrary.simpleMessage("Simulator"),
        "skill": MessageLookupByLibrary.simpleMessage("Skill"),
        "skill_up": MessageLookupByLibrary.simpleMessage("Skill Up"),
        "skilled_max10":
            MessageLookupByLibrary.simpleMessage("Skills Max(310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("Sprites"),
        "statistics_include_checkbox":
            MessageLookupByLibrary.simpleMessage("Including owned items"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("Statistics"),
        "still_send": MessageLookupByLibrary.simpleMessage("Still Send"),
        "storage_permission_title":
            MessageLookupByLibrary.simpleMessage("Storage Permission"),
        "success": MessageLookupByLibrary.simpleMessage("Success"),
        "summon": MessageLookupByLibrary.simpleMessage("Summon"),
        "summon_simulator":
            MessageLookupByLibrary.simpleMessage("Summon Simulator"),
        "summon_title": MessageLookupByLibrary.simpleMessage("Summons"),
        "support_chaldea":
            MessageLookupByLibrary.simpleMessage("Support and Donation"),
        "support_party": MessageLookupByLibrary.simpleMessage("Support Setup"),
        "svt_info_tab_base": MessageLookupByLibrary.simpleMessage("Basic Info"),
        "svt_info_tab_bond_story": MessageLookupByLibrary.simpleMessage("Lore"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("Not favorite"),
        "svt_obtain_event": MessageLookupByLibrary.simpleMessage("Event"),
        "svt_obtain_friend_point":
            MessageLookupByLibrary.simpleMessage("FriendPoint"),
        "svt_obtain_initial": MessageLookupByLibrary.simpleMessage("Initial"),
        "svt_obtain_limited": MessageLookupByLibrary.simpleMessage("Limited"),
        "svt_obtain_permanent": MessageLookupByLibrary.simpleMessage("Summon"),
        "svt_obtain_story": MessageLookupByLibrary.simpleMessage("Story"),
        "svt_obtain_unavailable":
            MessageLookupByLibrary.simpleMessage("Unavailable"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("Hidden"),
        "svt_related_cards":
            MessageLookupByLibrary.simpleMessage("Related Cards"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("Reset Plan"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("Switch Slider/Dropdown"),
        "sync_server": m20,
        "test_info_pad": MessageLookupByLibrary.simpleMessage("Test Info Pad"),
        "toogle_dark_mode":
            MessageLookupByLibrary.simpleMessage("Toggle Dark Mode"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("Refresh slides"),
        "total_ap": MessageLookupByLibrary.simpleMessage("Total AP"),
        "total_counts": MessageLookupByLibrary.simpleMessage("Total counts"),
        "translations": MessageLookupByLibrary.simpleMessage("Translations"),
        "unsupported_type":
            MessageLookupByLibrary.simpleMessage("Unsupported type"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("Already the latest version"),
        "update_dataset":
            MessageLookupByLibrary.simpleMessage("Update Dataset"),
        "update_now": MessageLookupByLibrary.simpleMessage("Update Now"),
        "update_slides_status_msg_error": m21,
        "update_slides_status_msg_info":
            MessageLookupByLibrary.simpleMessage("Not updated"),
        "update_slides_status_msg_success":
            MessageLookupByLibrary.simpleMessage("Slides updated"),
        "upload": MessageLookupByLibrary.simpleMessage("Upload"),
        "userdata": MessageLookupByLibrary.simpleMessage("Userdata"),
        "userdata_cleared":
            MessageLookupByLibrary.simpleMessage("Userdata cleared"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("Download Backup"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("Choose one backup"),
        "userdata_sync":
            MessageLookupByLibrary.simpleMessage("Data synchronization"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("Upload Backup"),
        "valentine_craft":
            MessageLookupByLibrary.simpleMessage("Valentine craft"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "view_illustration":
            MessageLookupByLibrary.simpleMessage("View Illustration"),
        "voice": MessageLookupByLibrary.simpleMessage("Voice"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "web_renderer": MessageLookupByLibrary.simpleMessage("Web Renderer"),
        "words_separate": m22,
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
