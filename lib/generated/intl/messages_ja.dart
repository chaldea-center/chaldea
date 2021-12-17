// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static String m0(email, logPath) =>
      "エラーページのスクリーンショットとログファイルをこのメールボックスに送信してください：\n${email}\nログファイルパス：${logPath}";

  static String m1(curVersion, newVersion, releaseNote) =>
      "現在のバージョン：${curVersion} \n最新のバージョン：${newVersion}\n詳細:\n${releaseNote}";

  static String m2(name) => "ソース${name}";

  static String m3(n) => "最大${n}ボックス";

  static String m4(n) => "聖杯は伝承結晶に置き換える${n}個";

  static String m5(error) => "インポートに失敗しました、エラー:\n${error}";

  static String m6(account) => "アカウント ${account} に切り替える";

  static String m7(itemNum, svtNum) => "どのアカウントに？${itemNum}アイテム&${svtNum}サーバント";

  static String m8(name) => "${name}はすでに存在します";

  static String m9(site) => "${site}にジャンプ";

  static String m10(first) => "${Intl.select(first, {
            'true': '最初のもの',
            'false': '最後のもの',
            'other': '最後のもの',
          })}";

  static String m11(version) => "データバージョンが${version}に更新されました";

  static String m12(index) => "プラン${index}";

  static String m13(n) => "プラン${n}をリセット(すべて)";

  static String m14(n) => "プラン${n}をリセット(表示のみ)";

  static String m15(total) => "合計：${total}";

  static String m16(total, hidden) => "合計：${total} (非表示: ${hidden})";

  static String m17(server) => "同步${server}";

  static String m18(a, b) => "${a}${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("ついて"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "　このアプリケーションで使用されるデータは、ゲームおよび次のサイトからのものです。ゲーム画像およびその他のテキストの著作権はTYPE MOON / FGO PROJECTに帰属します。\n　プログラムの機能と設計はWeChatアプリ「素材规划」とiOSアプリのGudaを参照しています。\n"),
        "about_appstore_rating":
            MessageLookupByLibrary.simpleMessage("App Storeに評価"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("データソース"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "マークされていないソースまたは侵害がある場合はお知らせください"),
        "about_email_dialog": m0,
        "about_email_subtitle": MessageLookupByLibrary.simpleMessage(
            "エラーページのスクリーンショットとログファイルを添付してください"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("フィードバック"),
        "about_update_app": MessageLookupByLibrary.simpleMessage("アプリを更新"),
        "about_update_app_alert_ios_mac":
            MessageLookupByLibrary.simpleMessage("App Storeでアップデートを確認してください"),
        "about_update_app_detail": m1,
        "active_skill": MessageLookupByLibrary.simpleMessage("保有スキル"),
        "add": MessageLookupByLibrary.simpleMessage("追加"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("ブラックリストに追加"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("口算不及格的咕朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("AP計算"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP効率"),
        "ap_overflow_time": MessageLookupByLibrary.simpleMessage("APフル時間"),
        "append_skill": MessageLookupByLibrary.simpleMessage("アペンドスキル"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("アペンド"),
        "ascension": MessageLookupByLibrary.simpleMessage("霊基"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("霊基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("霊基再臨"),
        "attachment": MessageLookupByLibrary.simpleMessage("アタッチメント"),
        "auto_update": MessageLookupByLibrary.simpleMessage("自動更新"),
        "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
        "backup_data_alert":
            MessageLookupByLibrary.simpleMessage("Timely backup wanted"),
        "backup_history": MessageLookupByLibrary.simpleMessage("バックアップ履歴"),
        "backup_success": MessageLookupByLibrary.simpleMessage("バックアップは成功しました"),
        "blacklist": MessageLookupByLibrary.simpleMessage("ブラックリスト"),
        "bond": MessageLookupByLibrary.simpleMessage("絆"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("絆礼装"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("絆効率"),
        "bronze": MessageLookupByLibrary.simpleMessage("銅"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("重み"),
        "calculate": MessageLookupByLibrary.simpleMessage("計算する"),
        "calculator": MessageLookupByLibrary.simpleMessage("電卓"),
        "campaign_event": MessageLookupByLibrary.simpleMessage("キャンペーン"),
        "cancel": MessageLookupByLibrary.simpleMessage("キャセル"),
        "card_description": MessageLookupByLibrary.simpleMessage("解説"),
        "card_info": MessageLookupByLibrary.simpleMessage("資料"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("カルーセル設定"),
        "change_log": MessageLookupByLibrary.simpleMessage("更新履歴"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("キャラクター"),
        "check_update": MessageLookupByLibrary.simpleMessage("更新の確認"),
        "choose_quest_hint": MessageLookupByLibrary.simpleMessage("フリークエストを選択"),
        "clear": MessageLookupByLibrary.simpleMessage("クリア"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("キャッシュを消去"),
        "clear_cache_finish":
            MessageLookupByLibrary.simpleMessage("キャッシュがクリアされました"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("イラスト、ボイスなど"),
        "clear_userdata": MessageLookupByLibrary.simpleMessage("ユーザーデータをクリア"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("指令紋章"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令紋章"),
        "confirm": MessageLookupByLibrary.simpleMessage("確認"),
        "consumed": MessageLookupByLibrary.simpleMessage("消費済"),
        "copied": MessageLookupByLibrary.simpleMessage("コピー済み"),
        "copy": MessageLookupByLibrary.simpleMessage("コピー"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("他のプランからコピー"),
        "costume": MessageLookupByLibrary.simpleMessage("霊衣"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("霊衣開放"),
        "counts": MessageLookupByLibrary.simpleMessage("カウント"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("2号機を生成"),
        "critical_attack": MessageLookupByLibrary.simpleMessage("クリティカル"),
        "cur_account": MessageLookupByLibrary.simpleMessage("アカウント"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("既存のAP"),
        "current_": MessageLookupByLibrary.simpleMessage("現在"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("ダウンロードページに移動"),
        "dataset_goto_download_page_hint":
            MessageLookupByLibrary.simpleMessage("ダウンロード後に手動でインポート"),
        "dataset_management": MessageLookupByLibrary.simpleMessage("データベース"),
        "dataset_type_image":
            MessageLookupByLibrary.simpleMessage("画像データパッケージ"),
        "dataset_type_text":
            MessageLookupByLibrary.simpleMessage("テキストデータパッケージ"),
        "delete": MessageLookupByLibrary.simpleMessage("削除"),
        "demands": MessageLookupByLibrary.simpleMessage("要件"),
        "display_setting": MessageLookupByLibrary.simpleMessage("表示設定"),
        "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
        "download_complete": MessageLookupByLibrary.simpleMessage("ダウンロード完了"),
        "download_full_gamedata":
            MessageLookupByLibrary.simpleMessage("最新のデータをダウンロード"),
        "download_full_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("フルzipデータパッケージ"),
        "download_latest_gamedata":
            MessageLookupByLibrary.simpleMessage("最新のデータをダウンロード"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "互換性を確保するために、更新する前にAPPの最新バージョンにアップグレードしてください"),
        "download_source": MessageLookupByLibrary.simpleMessage("ダウンロードソース"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("ゲームデータとアプリケーションの更新"),
        "download_source_of": m2,
        "downloaded": MessageLookupByLibrary.simpleMessage("ダウンロード済み"),
        "downloading": MessageLookupByLibrary.simpleMessage("ダウンロード"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("＋をクリックしてアイテムを追加"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("最低AP"),
        "drop_calc_optimize": MessageLookupByLibrary.simpleMessage("最適化"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("解決する"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("ドロップ率"),
        "edit": MessageLookupByLibrary.simpleMessage("編集"),
        "effect_search": MessageLookupByLibrary.simpleMessage("バフ検索"),
        "efficiency": MessageLookupByLibrary.simpleMessage("効率"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("効率タイプ"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP効率"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("ドロップ率"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("エネミー"),
        "enhance": MessageLookupByLibrary.simpleMessage("強化"),
        "enhance_warning":
            MessageLookupByLibrary.simpleMessage("強化すると、次の資アイテムが差し引かれます"),
        "error_no_network":
            MessageLookupByLibrary.simpleMessage("インターネットに接続できません"),
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "すべてのアイテムを倉庫に追加し、プランからイベントを削除します"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("アイテムの収集"),
        "event_item_default":
            MessageLookupByLibrary.simpleMessage("ショップ/タスク/ポイント/ドロップ報酬"),
        "event_item_extra": MessageLookupByLibrary.simpleMessage("その他入手方法 "),
        "event_lottery_limit_hint": m3,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("ボックスガチャ"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage(""),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("ボックスガチャ"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("イベントはプランされていません"),
        "event_progress": MessageLookupByLibrary.simpleMessage("現在のイベント"),
        "event_rerun_replace_grail": m4,
        "event_title": MessageLookupByLibrary.simpleMessage("イベント"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交換券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交換券"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("Lv."),
        "exp_card_rarity5": MessageLookupByLibrary.simpleMessage("星5種火"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("同じクラス"),
        "exp_card_select_lvs":
            MessageLookupByLibrary.simpleMessage("レベルの範囲を選択"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("種火コスト"),
        "failed": MessageLookupByLibrary.simpleMessage("失敗"),
        "favorite": MessageLookupByLibrary.simpleMessage("フォロー"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("画像とファイルを追加"),
        "feedback_add_crash_log":
            MessageLookupByLibrary.simpleMessage("クラッシュログを追加"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("連絡先情報"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("フィードバックと提案"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("送信"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("件名"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("背景"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("体"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("切り抜く "),
        "ffo_head": MessageLookupByLibrary.simpleMessage("頭"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "最初にFFOリソースをダウンロードまたはインポートしてください↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("同じサーヴァント"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("FGOアイテム効率劇場"),
        "filename": MessageLookupByLibrary.simpleMessage("ファイル名"),
        "filter": MessageLookupByLibrary.simpleMessage("フィルター"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("属性"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("相性"),
        "filter_category": MessageLookupByLibrary.simpleMessage("分類"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("効果"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("すべて選択"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("入手方法"),
        "filter_plan_not_reached": MessageLookupByLibrary.simpleMessage("未完成"),
        "filter_plan_reached": MessageLookupByLibrary.simpleMessage("達成"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("逆選択"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("表示"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("スキルレベル"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("ソート"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("クラス"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("番号"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("スター"),
        "filter_special_trait": MessageLookupByLibrary.simpleMessage("特殊特性"),
        "free_efficiency": MessageLookupByLibrary.simpleMessage("フリー効率"),
        "free_progress": MessageLookupByLibrary.simpleMessage("クエスト"),
        "free_progress_newest": MessageLookupByLibrary.simpleMessage("最新"),
        "free_quest": MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "free_quest_calculator":
            MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("ホーム"),
        "game_drop": MessageLookupByLibrary.simpleMessage("ドロップ"),
        "game_experience": MessageLookupByLibrary.simpleMessage("EXP"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("絆"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("クリア報酬"),
        "gamedata": MessageLookupByLibrary.simpleMessage("ゲームデータ"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("聖杯"),
        "grail_level": MessageLookupByLibrary.simpleMessage("聖杯レベル"),
        "grail_up": MessageLookupByLibrary.simpleMessage("聖杯転臨"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("成長曲線"),
        "guda_item_data": MessageLookupByLibrary.simpleMessage("Gudaアイテムデータ"),
        "guda_servant_data":
            MessageLookupByLibrary.simpleMessage("Gudaサーヴァントデータ"),
        "hello": MessageLookupByLibrary.simpleMessage("こんにちは、マスタ。"),
        "help": MessageLookupByLibrary.simpleMessage("ヘルプ"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("期限切れの非表示"),
        "hint_no_bond_craft": MessageLookupByLibrary.simpleMessage("絆礼装なし"),
        "hint_no_valentine_craft":
            MessageLookupByLibrary.simpleMessage("チョコ礼装なし"),
        "icons": MessageLookupByLibrary.simpleMessage("アイコン"),
        "ignore": MessageLookupByLibrary.simpleMessage("無視"),
        "illustration": MessageLookupByLibrary.simpleMessage("イラスト"),
        "illustrator": MessageLookupByLibrary.simpleMessage("イラスト"),
        "image_analysis": MessageLookupByLibrary.simpleMessage("画像分析"),
        "import_data": MessageLookupByLibrary.simpleMessage("インポート"),
        "import_data_error": m5,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("インポートは成功しました"),
        "import_guda_data": MessageLookupByLibrary.simpleMessage("Gudaデータ"),
        "import_guda_hint": MessageLookupByLibrary.simpleMessage(
            "更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据"),
        "import_guda_items":
            MessageLookupByLibrary.simpleMessage("Gudaアイテムをインポート"),
        "import_guda_servants":
            MessageLookupByLibrary.simpleMessage("サーヴァントをインポート"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("重複サーバント"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "インポートボタンをクリックして、復号化されたHTTPS応答をインポートします"),
        "import_http_body_hint_hide":
            MessageLookupByLibrary.simpleMessage("サーバントをクリックして非表示/再表示"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("ロックのみ"),
        "import_http_body_success_switch": m6,
        "import_http_body_target_account_header": m7,
        "import_screenshot":
            MessageLookupByLibrary.simpleMessage("スクリーンショットをインポート"),
        "import_screenshot_hint":
            MessageLookupByLibrary.simpleMessage("識別された資料のみを更新する"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("更新素材"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("ソースファイルをインポート"),
        "info_agility": MessageLookupByLibrary.simpleMessage("敏捷"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("属性"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("絆ポイント"),
        "info_bond_points_single": MessageLookupByLibrary.simpleMessage("ポイント"),
        "info_bond_points_sum": MessageLookupByLibrary.simpleMessage("累計"),
        "info_cards": MessageLookupByLibrary.simpleMessage("カード"),
        "info_critical_rate": MessageLookupByLibrary.simpleMessage("スター集中度"),
        "info_cv": MessageLookupByLibrary.simpleMessage("CV"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("即死率"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("耐久"),
        "info_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "info_height": MessageLookupByLibrary.simpleMessage("身長"),
        "info_human": MessageLookupByLibrary.simpleMessage("人型"),
        "info_luck": MessageLookupByLibrary.simpleMessage("幸運"),
        "info_mana": MessageLookupByLibrary.simpleMessage("魔力"),
        "info_np": MessageLookupByLibrary.simpleMessage("宝具"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP率"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("スター発生率"),
        "info_strength": MessageLookupByLibrary.simpleMessage("筋力"),
        "info_trait": MessageLookupByLibrary.simpleMessage("特性"),
        "info_value": MessageLookupByLibrary.simpleMessage("数值"),
        "info_weak_to_ea": MessageLookupByLibrary.simpleMessage("EAに特攻"),
        "info_weight": MessageLookupByLibrary.simpleMessage("体重"),
        "input_invalid_hint": MessageLookupByLibrary.simpleMessage("入力が無効です"),
        "install": MessageLookupByLibrary.simpleMessage("インスト"),
        "interlude_and_rankup": MessageLookupByLibrary.simpleMessage("幕間・強化"),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"ファイル\"アプリ/このiPhone内/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("問題"),
        "item": MessageLookupByLibrary.simpleMessage("アイテム"),
        "item_already_exist_hint": m8,
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("霊基再臨用素材"),
        "item_category_bronze": MessageLookupByLibrary.simpleMessage("銅素材"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("イベントサーバント霊基再臨用アイテム"),
        "item_category_gem": MessageLookupByLibrary.simpleMessage("輝石"),
        "item_category_gems": MessageLookupByLibrary.simpleMessage("スキル強化素材"),
        "item_category_gold": MessageLookupByLibrary.simpleMessage("金素材"),
        "item_category_magic_gem": MessageLookupByLibrary.simpleMessage("魔石"),
        "item_category_monument":
            MessageLookupByLibrary.simpleMessage("モニュメント"),
        "item_category_others": MessageLookupByLibrary.simpleMessage("その他"),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("ピース"),
        "item_category_secret_gem": MessageLookupByLibrary.simpleMessage("秘石"),
        "item_category_silver": MessageLookupByLibrary.simpleMessage("銀素材"),
        "item_category_special": MessageLookupByLibrary.simpleMessage("特殊素材"),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("共通素材"),
        "item_eff": MessageLookupByLibrary.simpleMessage("アイテム効率"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "プランを計算する前に、材料の余剰を設定できます（フリークエストプランの場合のみ）"),
        "item_left": MessageLookupByLibrary.simpleMessage("残り"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("フリークエストはありません"),
        "item_only_show_lack": MessageLookupByLibrary.simpleMessage("不足しているのみ"),
        "item_own": MessageLookupByLibrary.simpleMessage("持って"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("アイテムキャプチャー"),
        "item_title": MessageLookupByLibrary.simpleMessage("アイテム"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("合計"),
        "join_beta": MessageLookupByLibrary.simpleMessage("ベータ版に参加する"),
        "jump_to": m9,
        "language": MessageLookupByLibrary.simpleMessage("日本語"),
        "language_en": MessageLookupByLibrary.simpleMessage("Japanese"),
        "level": MessageLookupByLibrary.simpleMessage("レベル"),
        "limited_event": MessageLookupByLibrary.simpleMessage("期間限定イベント"),
        "link": MessageLookupByLibrary.simpleMessage("リンク"),
        "list_end_hint": m10,
        "load_dataset_error": MessageLookupByLibrary.simpleMessage("読み取りエラー"),
        "load_dataset_error_hint": MessageLookupByLibrary.simpleMessage(
            "設定-ゲームデータでデフォルトのリソースをリロードしてください"),
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("パスワードを変更する"),
        "login_first_hint":
            MessageLookupByLibrary.simpleMessage("最初にログインしてください"),
        "login_forget_pwd": MessageLookupByLibrary.simpleMessage("パスワードを忘れる"),
        "login_login": MessageLookupByLibrary.simpleMessage("ログイン"),
        "login_logout": MessageLookupByLibrary.simpleMessage("ログアウト"),
        "login_new_password": MessageLookupByLibrary.simpleMessage("新しいパスワード"),
        "login_password": MessageLookupByLibrary.simpleMessage("パスワード"),
        "login_password_error":
            MessageLookupByLibrary.simpleMessage("4桁以上の文字と数字のみ"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage("古いパスワードと同じ"),
        "login_signup": MessageLookupByLibrary.simpleMessage("登録"),
        "login_state_not_login":
            MessageLookupByLibrary.simpleMessage("ログインしていない"),
        "login_username": MessageLookupByLibrary.simpleMessage("ユーザー名"),
        "login_username_error":
            MessageLookupByLibrary.simpleMessage("4桁以上の文字と数字のみ、文字で始まる"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("長押しして保存"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("福袋"),
        "main_record": MessageLookupByLibrary.simpleMessage("シナリオ"),
        "main_record_bonus": MessageLookupByLibrary.simpleMessage("報酬"),
        "main_record_bonus_short": MessageLookupByLibrary.simpleMessage("報酬"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("タイトル"),
        "main_record_fixed_drop": MessageLookupByLibrary.simpleMessage("ドロップ"),
        "main_record_fixed_drop_short":
            MessageLookupByLibrary.simpleMessage("ドロップ"),
        "master_mission": MessageLookupByLibrary.simpleMessage("マスターミッション"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("関連クエスト"),
        "master_mission_solution": MessageLookupByLibrary.simpleMessage("対策"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("ミッション"),
        "max_ap": MessageLookupByLibrary.simpleMessage("最大のAP"),
        "more": MessageLookupByLibrary.simpleMessage("もっと"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("魔術礼装"),
        "new_account": MessageLookupByLibrary.simpleMessage("新しいアカウント"),
        "next_card": MessageLookupByLibrary.simpleMessage("次のカード"),
        "nga": MessageLookupByLibrary.simpleMessage("NGA"),
        "nga_fgo": MessageLookupByLibrary.simpleMessage("NGA-FGO"),
        "no": MessageLookupByLibrary.simpleMessage("いいえ"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("幕間の物語や強化クエストはありません"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("♡をクリックして、すべてのクエストを表示します"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("宝具"),
        "noble_phantasm_level": MessageLookupByLibrary.simpleMessage("宝具レベル"),
        "obtain_methods": MessageLookupByLibrary.simpleMessage("入手方法"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("開く"),
        "open_condition": MessageLookupByLibrary.simpleMessage("開放条件"),
        "overview": MessageLookupByLibrary.simpleMessage("概要"),
        "overwrite": MessageLookupByLibrary.simpleMessage("上書き"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("クラススキル"),
        "patch_gamedata": MessageLookupByLibrary.simpleMessage("ゲームデータを更新"),
        "patch_gamedata_error_no_compatible":
            MessageLookupByLibrary.simpleMessage(
                "このAPPバージョンと互換性のあるデータバージョンが見つかりません"),
        "patch_gamedata_error_unknown_version":
            MessageLookupByLibrary.simpleMessage(
                "サーバーの現在のバージョンが存在せず、完全なデータパッケージをダウンロード"),
        "patch_gamedata_hint": MessageLookupByLibrary.simpleMessage("パッチのみ"),
        "patch_gamedata_success_to": m11,
        "plan": MessageLookupByLibrary.simpleMessage("プラン"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("プラン最大化する(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("プラン最大化する(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("プラン目標"),
        "plan_title": MessageLookupByLibrary.simpleMessage("プラン"),
        "plan_x": m12,
        "planning_free_quest_btn": MessageLookupByLibrary.simpleMessage("クエスト"),
        "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
        "previous_card": MessageLookupByLibrary.simpleMessage("前のカード"),
        "priority": MessageLookupByLibrary.simpleMessage("優先順位"),
        "project_homepage":
            MessageLookupByLibrary.simpleMessage("プロジェクトホームページ"),
        "query_failed": MessageLookupByLibrary.simpleMessage("クエリに失敗しました"),
        "quest": MessageLookupByLibrary.simpleMessage("クエスト"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("開放条件"),
        "rarity": MessageLookupByLibrary.simpleMessage("レアリティ"),
        "release_page": MessageLookupByLibrary.simpleMessage("ウェブサイト"),
        "reload_data_success":
            MessageLookupByLibrary.simpleMessage("インポートに成功しました"),
        "reload_default_gamedata":
            MessageLookupByLibrary.simpleMessage("プリインストールされたバージョンをリロードします"),
        "reloading_data": MessageLookupByLibrary.simpleMessage("インポート中"),
        "remove_duplicated_svt": MessageLookupByLibrary.simpleMessage("2号機を削除"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("ブラックリストから削除"),
        "rename": MessageLookupByLibrary.simpleMessage("名前変更"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("復刻イベント"),
        "reset": MessageLookupByLibrary.simpleMessage("リセット"),
        "reset_plan_all": m13,
        "reset_plan_shown": m14,
        "reset_success": MessageLookupByLibrary.simpleMessage("リセットしました"),
        "reset_svt_enhance_state":
            MessageLookupByLibrary.simpleMessage("サーヴァント強化状态をリセット"),
        "reset_svt_enhance_state_hint":
            MessageLookupByLibrary.simpleMessage("宝具/スキル強化"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "再起動してアプリを更新します。更新に失敗した場合は、ソースフォルダをコピー先に手動でコピーしてください"),
        "restore": MessageLookupByLibrary.simpleMessage("復元"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("アルバムに保存"),
        "saved": MessageLookupByLibrary.simpleMessage("保存しました"),
        "search": MessageLookupByLibrary.simpleMessage("検索"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("基本情報"),
        "search_options": MessageLookupByLibrary.simpleMessage("検索範囲"),
        "search_result_count": m15,
        "search_result_count_hide": m16,
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("コピー元を選択"),
        "select_plan": MessageLookupByLibrary.simpleMessage("プランを選択"),
        "servant": MessageLookupByLibrary.simpleMessage("サーヴァント"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("サーヴァントコイン"),
        "servant_title": MessageLookupByLibrary.simpleMessage("サーヴァント"),
        "server": MessageLookupByLibrary.simpleMessage("サーバー"),
        "server_cn": MessageLookupByLibrary.simpleMessage("中国"),
        "server_jp": MessageLookupByLibrary.simpleMessage("日本"),
        "server_na": MessageLookupByLibrary.simpleMessage("北米"),
        "server_tw": MessageLookupByLibrary.simpleMessage("台湾"),
        "set_plan_name": MessageLookupByLibrary.simpleMessage("プラン名を設定"),
        "setting_auto_rotate": MessageLookupByLibrary.simpleMessage("自動回転"),
        "settings_data": MessageLookupByLibrary.simpleMessage("データ"),
        "settings_data_management":
            MessageLookupByLibrary.simpleMessage("データベース"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("使い方"),
        "settings_general": MessageLookupByLibrary.simpleMessage("一般"),
        "settings_language": MessageLookupByLibrary.simpleMessage("言語"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("設定"),
        "settings_use_mobile_network":
            MessageLookupByLibrary.simpleMessage("モバイルデータを使用"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置"),
        "share": MessageLookupByLibrary.simpleMessage("共有"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("期限切れを表示"),
        "silver": MessageLookupByLibrary.simpleMessage("銀"),
        "simulator": MessageLookupByLibrary.simpleMessage("エミュレータ"),
        "skill": MessageLookupByLibrary.simpleMessage("スキル"),
        "skill_up": MessageLookupByLibrary.simpleMessage("スキル強化"),
        "skilled_max10":
            MessageLookupByLibrary.simpleMessage("スキルレベル最大化する(310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("モデル"),
        "statistics_include_checkbox":
            MessageLookupByLibrary.simpleMessage("既存のアイテムを含める"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("統計"),
        "storage_permission_title":
            MessageLookupByLibrary.simpleMessage("ストレージ権限"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "summon": MessageLookupByLibrary.simpleMessage("ガチャ"),
        "summon_simulator": MessageLookupByLibrary.simpleMessage("ガチャシミュ"),
        "summon_title": MessageLookupByLibrary.simpleMessage("ガチャ"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("サポートと寄付"),
        "support_party": MessageLookupByLibrary.simpleMessage("サポート編成"),
        "svt_info_tab_base": MessageLookupByLibrary.simpleMessage("ステータス"),
        "svt_info_tab_bond_story":
            MessageLookupByLibrary.simpleMessage("プロファイル"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("フォローされていません"),
        "svt_obtain_event": MessageLookupByLibrary.simpleMessage("配布"),
        "svt_obtain_friend_point": MessageLookupByLibrary.simpleMessage("フレポ"),
        "svt_obtain_initial": MessageLookupByLibrary.simpleMessage("初期"),
        "svt_obtain_limited": MessageLookupByLibrary.simpleMessage("限定"),
        "svt_obtain_permanent": MessageLookupByLibrary.simpleMessage("恒常"),
        "svt_obtain_story": MessageLookupByLibrary.simpleMessage("スト限"),
        "svt_obtain_unavailable": MessageLookupByLibrary.simpleMessage("召喚不可"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("非表示"),
        "svt_related_cards": MessageLookupByLibrary.simpleMessage("関連カード"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("プランをリセット"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("Slider/Dropdownを切り替え"),
        "sync_server": m17,
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("スライドを更新"),
        "total_ap": MessageLookupByLibrary.simpleMessage("合計AP"),
        "total_counts": MessageLookupByLibrary.simpleMessage("合計カウント"),
        "update": MessageLookupByLibrary.simpleMessage("更新"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("すでに最新バージョン"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("ゲームデータを更新"),
        "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
        "userdata": MessageLookupByLibrary.simpleMessage("ユーザーデータ"),
        "userdata_cleared":
            MessageLookupByLibrary.simpleMessage("ユーザーデータがクリアされました"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("ダウンロードのバックアップ"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("バックアップを選択"),
        "userdata_sync": MessageLookupByLibrary.simpleMessage("同期データ"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("アップロードバックアップ"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("チョコ礼装"),
        "version": MessageLookupByLibrary.simpleMessage("バージョン"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("カードの画像を表示"),
        "voice": MessageLookupByLibrary.simpleMessage("ボイス"),
        "words_separate": m18,
        "yes": MessageLookupByLibrary.simpleMessage("はい")
      };
}
