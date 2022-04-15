// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hant locale. All the
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
  String get localeName => 'zh_Hant';

  static String m0(email, logPath) =>
      "請將出錯頁面的截圖以及日誌文件發送到以下郵箱:\n ${email}\n日誌文件路徑: ${logPath}";

  static String m1(curVersion, newVersion, releaseNote) =>
      "當前版本: ${curVersion}\n最新版本: ${newVersion}\n更新內容:\n${releaseNote}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("關於"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "本應用所使用數據均來源於遊戲及以下網站，遊戲圖片文本原文等版權屬於TYPE MOON/FGO PROJECT。\n 程序功能與介面設計參考微信小程序\"素材規劃\"以及iOS版Guda。"),
        "about_appstore_rating":
            MessageLookupByLibrary.simpleMessage("App Store評分"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("數據來源"),
        "about_data_source_footer":
            MessageLookupByLibrary.simpleMessage("若存在未標註的來源或侵權敬請告知"),
        "about_email_dialog": m0,
        "about_email_subtitle":
            MessageLookupByLibrary.simpleMessage("請附上出錯頁面截圖和日誌"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("反饋"),
        "about_update_app": MessageLookupByLibrary.simpleMessage("應用更新"),
        "about_update_app_alert_ios_mac":
            MessageLookupByLibrary.simpleMessage("請在App Store中檢查更新"),
        "about_update_app_detail": m1,
        "account_title": MessageLookupByLibrary.simpleMessage("Account"),
        "active_skill": MessageLookupByLibrary.simpleMessage("保有技能"),
        "add": MessageLookupByLibrary.simpleMessage("添加"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("請填寫反饋內容"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("加入黑名單"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("心算不及各地咕朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("AP計算"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP效率"),
        "ap_overflow_time": MessageLookupByLibrary.simpleMessage("AP溢出時間"),
        "append_skill": MessageLookupByLibrary.simpleMessage("附加技能"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("附加"),
        "ascension": MessageLookupByLibrary.simpleMessage("靈基"),
        "ascension_icon":
            MessageLookupByLibrary.simpleMessage("Ascension Icon"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("靈基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("靈基再臨"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("從文件選取"),
        "attach_from_photos": MessageLookupByLibrary.simpleMessage("從相簿選取"),
        "attach_help":
            MessageLookupByLibrary.simpleMessage("如果圖片模式存在問題，請使用文件模式"),
        "attachment": MessageLookupByLibrary.simpleMessage("附件"),
        "auto_reset": MessageLookupByLibrary.simpleMessage("自動重設"),
        "auto_update": MessageLookupByLibrary.simpleMessage("自動更新"),
        "backup": MessageLookupByLibrary.simpleMessage("備份"),
        "backup_data_alert": MessageLookupByLibrary.simpleMessage("及！時！備！份！"),
        "backup_history": MessageLookupByLibrary.simpleMessage("歷史備份"),
        "backup_success": MessageLookupByLibrary.simpleMessage("備份成功"),
        "blacklist": MessageLookupByLibrary.simpleMessage("黑名單"),
        "bond": MessageLookupByLibrary.simpleMessage("羈絆"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("羈絆禮裝"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("羈絆效率"),
        "bootstrap_page_title":
            MessageLookupByLibrary.simpleMessage("Bootstrap Page"),
        "bronze": MessageLookupByLibrary.simpleMessage("銅"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("權重"),
        "calculate": MessageLookupByLibrary.simpleMessage("計算"),
        "calculator": MessageLookupByLibrary.simpleMessage("計算機"),
        "campaign_event": MessageLookupByLibrary.simpleMessage("紀念活動"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "card_description": MessageLookupByLibrary.simpleMessage("解說"),
        "card_info": MessageLookupByLibrary.simpleMessage("資料"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("輪播設置"),
        "chaldea_user": MessageLookupByLibrary.simpleMessage("Chaldea User"),
        "change_log": MessageLookupByLibrary.simpleMessage("更新歷史"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("出場角色"),
        "check_update": MessageLookupByLibrary.simpleMessage("檢查更新"),
        "choose_quest_hint": MessageLookupByLibrary.simpleMessage("選擇Free本"),
        "clear": MessageLookupByLibrary.simpleMessage("清空"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("清除緩存"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage("緩存已清除"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("包括卡面語音等"),
        "clear_data": MessageLookupByLibrary.simpleMessage("Clear Data"),
        "clear_userdata": MessageLookupByLibrary.simpleMessage("清空用戶數據"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("紋章"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令紋章"),
        "confirm": MessageLookupByLibrary.simpleMessage("確定"),
        "consumed": MessageLookupByLibrary.simpleMessage("已消耗"),
        "contact_information_not_filled":
            MessageLookupByLibrary.simpleMessage("聯繫方式未填寫"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage("將無法無法無法無法無法回覆你的問題"),
        "copied": MessageLookupByLibrary.simpleMessage("已複製"),
        "copy": MessageLookupByLibrary.simpleMessage("複製"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("複製自其他規劃"),
        "costume": MessageLookupByLibrary.simpleMessage("靈衣"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("靈衣開放"),
        "counts": MessageLookupByLibrary.simpleMessage("計數"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念禮裝"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("概念禮裝"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "You can add more accounts later in Settings"),
        "create_account_textfield_hint":
            MessageLookupByLibrary.simpleMessage("Any name"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("生成2號機"),
        "critical_attack": MessageLookupByLibrary.simpleMessage("暴擊"),
        "cur_account": MessageLookupByLibrary.simpleMessage("當前帳號"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("現有AP"),
        "current_": MessageLookupByLibrary.simpleMessage("當前"),
        "current_version":
            MessageLookupByLibrary.simpleMessage("Current Version"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("深色模式"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("深色"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("淺色"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("系統"),
        "database": MessageLookupByLibrary.simpleMessage("Database"),
        "database_not_downloaded": MessageLookupByLibrary.simpleMessage(
            "Database is not downloaded, still continue?"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("前往下載頁"),
        "dataset_goto_download_page_hint":
            MessageLookupByLibrary.simpleMessage("下載後手動導入"),
        "dataset_management": MessageLookupByLibrary.simpleMessage("數據管理"),
        "dataset_type_image": MessageLookupByLibrary.simpleMessage("圖片數據包"),
        "dataset_type_text": MessageLookupByLibrary.simpleMessage("文件數據包"),
        "dataset_version":
            MessageLookupByLibrary.simpleMessage("Dataset version"),
        "language": MessageLookupByLibrary.simpleMessage("繁體中文"),
        "language_en":
            MessageLookupByLibrary.simpleMessage("Traditional Chinese")
      };
}
