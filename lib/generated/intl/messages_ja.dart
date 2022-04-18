// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(curVersion, newVersion, releaseNote) =>
      "現在のバージョン：${curVersion} \n最新のバージョン：${newVersion}\n詳細:\n${releaseNote}";

  static String m1(url) =>
      "Chaldea - クロスプラットフォームのFate/GOアイテム計画アプリ。ゲーム情報の閲覧、サーヴァント/イベント/アイテム計画、マスターミッション計画、ガチャシミュレーターなどの機能をサポートします。\n\n詳細はこちら: \n${url}\n";

  static String m2(version) => "Required app version: ≥ ${version}";

  static String m3(n) => "最大${n}ボックス";

  static String m4(n) => "聖杯は伝承結晶${n}個に置き換わります";

  static String m5(filename, hash, localHash) =>
      "File ${filename} not found or mismatched hash: ${hash} - ${localHash}";

  static String m6(error) => "インポートに失敗しました、エラー:\n${error}";

  static String m7(name) => "${name}はすでにあります";

  static String m8(site) => "${site}にジャンプします";

  static String m9(shown, total) => "表示${shown}/合計${total}";

  static String m10(shown, ignore, total) =>
      "表示${shown}/無視${ignore}/合計${total}";

  static String m11(first) => "${Intl.select(first, {
            'true': '最初のもの',
            'false': '最後のもの',
            'other': '最後のもの',
          })}";

  static String m12(n) => "プラン${n}をリセット(すべて)";

  static String m13(n) => "プラン${n}をリセット(表示のみ)";

  static String m14(a, b) => "${a}${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("ついて"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "　このアプリケーションで使用されるデータは、ゲームおよび次のサイトからのものです。ゲーム画像およびその他のテキストの著作権はTYPE MOON / FGO PROJECTに帰属します。\n　プログラムの機能と設計はWeChatアプリ「素材规划」とiOSアプリのGudaを参照しています。\n"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("データソース"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "マークされていないソースまたは侵害がある場合はお知らせください"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("フィードバック"),
        "about_update_app_detail": m0,
        "account_title": MessageLookupByLibrary.simpleMessage("アカウント"),
        "active_skill": MessageLookupByLibrary.simpleMessage("保有スキル"),
        "add": MessageLookupByLibrary.simpleMessage("追加"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("フィードバックの内容を記入してください"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("ブラックリストに追加"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP効率"),
        "append_skill": MessageLookupByLibrary.simpleMessage("アペンドスキル"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("アペンド"),
        "ascension": MessageLookupByLibrary.simpleMessage("霊基"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("霊基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("霊基再臨"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("ファイルから"),
        "attach_from_photos": MessageLookupByLibrary.simpleMessage("アルバムから"),
        "attach_help": MessageLookupByLibrary.simpleMessage(
            "アルバムで画像をインポートする時問題があれば、ファイルでインポートしてください"),
        "attachment": MessageLookupByLibrary.simpleMessage("アタッチメント"),
        "auto_reset": MessageLookupByLibrary.simpleMessage("自動リセット"),
        "auto_update": MessageLookupByLibrary.simpleMessage("自動更新"),
        "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
        "backup_failed": MessageLookupByLibrary.simpleMessage("バックアップに失敗しました"),
        "backup_history": MessageLookupByLibrary.simpleMessage("バックアップ履歴"),
        "blacklist": MessageLookupByLibrary.simpleMessage("ブラックリスト"),
        "bond": MessageLookupByLibrary.simpleMessage("絆"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("絆礼装"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("絆効率"),
        "bootstrap_page_title": MessageLookupByLibrary.simpleMessage("ご案内"),
        "bronze": MessageLookupByLibrary.simpleMessage("銅"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("構成比"),
        "cancel": MessageLookupByLibrary.simpleMessage("キャセル"),
        "card_description": MessageLookupByLibrary.simpleMessage("解説"),
        "card_info": MessageLookupByLibrary.simpleMessage("資料"),
        "card_name": MessageLookupByLibrary.simpleMessage("カード名"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("カルーセル設定"),
        "chaldea_account":
            MessageLookupByLibrary.simpleMessage("Chaldea Account"),
        "chaldea_share_msg": m1,
        "change_log": MessageLookupByLibrary.simpleMessage("更新履歴"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("キャラクター"),
        "check_update": MessageLookupByLibrary.simpleMessage("更新の確認"),
        "clear": MessageLookupByLibrary.simpleMessage("クリア"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("キャッシュクリア"),
        "clear_cache_finish":
            MessageLookupByLibrary.simpleMessage("キャッシュクリアが完了しました"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("イラスト、ボイスなど"),
        "clear_data": MessageLookupByLibrary.simpleMessage("Clear Data"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令紋章"),
        "confirm": MessageLookupByLibrary.simpleMessage("確認"),
        "consumed": MessageLookupByLibrary.simpleMessage("消費済み"),
        "contact_information_not_filled":
            MessageLookupByLibrary.simpleMessage("連絡先情報が入力されていません"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage(
                "開発者はあなたのフィードバックに応答することができなくなります"),
        "copied": MessageLookupByLibrary.simpleMessage("コピー済み"),
        "copy": MessageLookupByLibrary.simpleMessage("コピー"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("他のプランからコピーします"),
        "costume": MessageLookupByLibrary.simpleMessage("霊衣"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("霊衣開放"),
        "counts": MessageLookupByLibrary.simpleMessage("カウント"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "You can add more accounts later in Settings"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("2号機を生成"),
        "cur_account": MessageLookupByLibrary.simpleMessage("アカウント"),
        "current_": MessageLookupByLibrary.simpleMessage("現在"),
        "current_version": MessageLookupByLibrary.simpleMessage("現在のバージョン"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("ダックモード"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("ダック"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("ライト"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("システム"),
        "database": MessageLookupByLibrary.simpleMessage("データベース"),
        "database_not_downloaded":
            MessageLookupByLibrary.simpleMessage("データベースはダウンロードしませんが、続きますか？"),
        "dataset_version": MessageLookupByLibrary.simpleMessage("データセットのバージョン"),
        "date": MessageLookupByLibrary.simpleMessage("日付"),
        "debug": MessageLookupByLibrary.simpleMessage("ディバッグ"),
        "debug_fab": MessageLookupByLibrary.simpleMessage("Debug FAB"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("Debug Menu"),
        "delete": MessageLookupByLibrary.simpleMessage("削除"),
        "demands": MessageLookupByLibrary.simpleMessage("要件"),
        "display_setting": MessageLookupByLibrary.simpleMessage("設定表示"),
        "done": MessageLookupByLibrary.simpleMessage("DONE"),
        "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "互換性を確保するために、更新する前にアプリの最新バージョンにアップデードしてください"),
        "download_source": MessageLookupByLibrary.simpleMessage("ダウンロードソース"),
        "downloaded": MessageLookupByLibrary.simpleMessage("ダウンロード済み"),
        "downloading": MessageLookupByLibrary.simpleMessage("ダウンロード中"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("＋をクリックしてアイテムを追加"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("APの最低限"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("解答する"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("ドロップ率"),
        "edit": MessageLookupByLibrary.simpleMessage("編集"),
        "effect_search": MessageLookupByLibrary.simpleMessage("バフ検索"),
        "efficiency": MessageLookupByLibrary.simpleMessage("効率"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("効率タイプ"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP効率"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("ドロップ率"),
        "email": MessageLookupByLibrary.simpleMessage("メール"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("エネミー"),
        "enhance": MessageLookupByLibrary.simpleMessage("強化"),
        "enhance_warning":
            MessageLookupByLibrary.simpleMessage("強化すると、次のアイテムが控除されます"),
        "error_no_internet":
            MessageLookupByLibrary.simpleMessage("インターネットに接続できません"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("No network"),
        "error_no_version_data_found":
            MessageLookupByLibrary.simpleMessage("No version data found"),
        "error_required_app_version": m2,
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "すべてのアイテムを倉庫に追加し、プランからイベントを削除します"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("アイテムの収集"),
        "event_item_extra":
            MessageLookupByLibrary.simpleMessage("他の入手可能のアイテム "),
        "event_lottery_limit_hint": m3,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("有限なボックスガチャ"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("ボックス"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("無限なボックスガチャ"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("イベントはプランされていません"),
        "event_progress": MessageLookupByLibrary.simpleMessage("現在のイベント"),
        "event_rerun_replace_grail": m4,
        "event_title": MessageLookupByLibrary.simpleMessage("イベント"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交換券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交換券"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("レベルのプラン"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("同じクラス"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("必要な種火数"),
        "failed": MessageLookupByLibrary.simpleMessage("失敗"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("フォロー"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("e.g. スクリーンショットとその他のファイル"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("連絡先情報"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("フィードバックと提案"),
        "feedback_form_alert":
            MessageLookupByLibrary.simpleMessage("フィードバックフォームは送信されませんが、終了します？"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "フィードバックを送信する前に、<**FAQ**>を確認してください。 フィードバックを提供する際は、詳しく説明してください。\n- 再現方法/期待されるパフォーマンス\n- アプリ/データのバージョン、デバイスシステム/バージョン\n- スクリーンショットとログを添付する\n- そして、連絡先情報（電子メールなど）を提供するようにしてください"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("送信"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("件名"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("背景"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("体"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("切り抜く "),
        "ffo_head": MessageLookupByLibrary.simpleMessage("頭"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "まずFFOリソースをダウンロードまたはインポートしてください↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("同じサーヴァント"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("効率劇場"),
        "file_not_found_or_mismatched_hash": m5,
        "filename": MessageLookupByLibrary.simpleMessage("ファイル名"),
        "fill_email_warning":
            MessageLookupByLibrary.simpleMessage("連絡先情報がない場合は、返信することはできません。"),
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
        "free_progress": MessageLookupByLibrary.simpleMessage("クエスト"),
        "free_progress_newest": MessageLookupByLibrary.simpleMessage("最新"),
        "free_quest": MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "free_quest_calculator":
            MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("ホーム"),
        "game_data_not_found": MessageLookupByLibrary.simpleMessage(
            "Game data not found, please download data first"),
        "game_drop": MessageLookupByLibrary.simpleMessage("ドロップ"),
        "game_experience": MessageLookupByLibrary.simpleMessage("EXP"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("絆"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("クリア報酬"),
        "game_server": MessageLookupByLibrary.simpleMessage("サーバー"),
        "gamedata": MessageLookupByLibrary.simpleMessage("ゲームデータ"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("聖杯"),
        "grail_up": MessageLookupByLibrary.simpleMessage("聖杯転臨"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("成長曲線"),
        "guda_female": MessageLookupByLibrary.simpleMessage("ぐだ子"),
        "guda_male": MessageLookupByLibrary.simpleMessage("ぐだ男"),
        "help": MessageLookupByLibrary.simpleMessage("ヘルプ"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("期限切れを非表示"),
        "http_sniff_hint": MessageLookupByLibrary.simpleMessage(
            "(JP/NA/CN/TW)アカウントがログインしているときにデータ"),
        "https_sniff": MessageLookupByLibrary.simpleMessage("Httpsスニッフィング"),
        "icons": MessageLookupByLibrary.simpleMessage("アイコン"),
        "ignore": MessageLookupByLibrary.simpleMessage("無視"),
        "illustration": MessageLookupByLibrary.simpleMessage("イラスト"),
        "illustrator": MessageLookupByLibrary.simpleMessage("イラスレーター"),
        "import_active_skill_hint":
            MessageLookupByLibrary.simpleMessage("強化 - サーヴァントスキル強化"),
        "import_active_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("保有スキルのスクリーンショット"),
        "import_append_skill_hint":
            MessageLookupByLibrary.simpleMessage("強化 - アペンドスキル強化"),
        "import_append_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("アペンドスキルのスクリーンショット"),
        "import_backup": MessageLookupByLibrary.simpleMessage("バックアップのインポート"),
        "import_data": MessageLookupByLibrary.simpleMessage("インポート"),
        "import_data_error": m6,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("インポートは成功しました"),
        "import_from_clipboard":
            MessageLookupByLibrary.simpleMessage("クリップボードから"),
        "import_from_file": MessageLookupByLibrary.simpleMessage("ファイルから"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("複数のサーバントはオーケーです"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "アカウントデータをインポートために、右上隅をクリックして、復号化したHTTPS応答パッケージをインポートしてください\nヘルプをクリックして、HTTPS応答内容をキャプチャ・復号化する方法を確認してください"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            "サーバントをクリックして、そちらを非表示/再表示することができます"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("ロックしたもののみ"),
        "import_item_hint":
            MessageLookupByLibrary.simpleMessage("マイルーム - 所持アイテム一覧"),
        "import_item_screenshots":
            MessageLookupByLibrary.simpleMessage("アイテムのスクリーンショット"),
        "import_screenshot":
            MessageLookupByLibrary.simpleMessage("スクリーンショットをインポートします"),
        "import_screenshot_hint":
            MessageLookupByLibrary.simpleMessage("識別されたアイテムのみをアップデートします"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("アイテムをアップデートします"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("ソースデータをインポートします"),
        "import_userdata_more":
            MessageLookupByLibrary.simpleMessage("その他のインポート方法"),
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
        "info_luck": MessageLookupByLibrary.simpleMessage("幸運"),
        "info_mana": MessageLookupByLibrary.simpleMessage("魔力"),
        "info_np": MessageLookupByLibrary.simpleMessage("宝具"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP率"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("スター発生率"),
        "info_strength": MessageLookupByLibrary.simpleMessage("筋力"),
        "info_trait": MessageLookupByLibrary.simpleMessage("特性"),
        "info_value": MessageLookupByLibrary.simpleMessage("数值"),
        "input_invalid_hint": MessageLookupByLibrary.simpleMessage("入力が無効です"),
        "install": MessageLookupByLibrary.simpleMessage("インスト"),
        "interlude_and_rankup": MessageLookupByLibrary.simpleMessage("幕間・強化"),
        "invalid_input": MessageLookupByLibrary.simpleMessage("Invalid input."),
        "invalid_startup_path":
            MessageLookupByLibrary.simpleMessage("Invalid startup path!"),
        "invalid_startup_path_info": MessageLookupByLibrary.simpleMessage(
            "Please, extract zip to non-system path then start the app. \"C:\\\", \"C:\\Program Files\" are not allowed."),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"ファイル\"アプリ/My iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("FAQ"),
        "item": MessageLookupByLibrary.simpleMessage("アイテム"),
        "item_already_exist_hint": m7,
        "item_apple": MessageLookupByLibrary.simpleMessage("果実"),
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("霊基再臨素材"),
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
            "プランを計算する前に、材料の残量を設定することはできます（フリークエストプランの場合のみ）"),
        "item_left": MessageLookupByLibrary.simpleMessage("残量"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("フリークエストはありません"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("不足なアイテムのみ"),
        "item_own": MessageLookupByLibrary.simpleMessage("持ったアイテム"),
        "item_screenshot":
            MessageLookupByLibrary.simpleMessage("アイテムのスクリーンショット"),
        "item_title": MessageLookupByLibrary.simpleMessage("アイテム"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("合計"),
        "join_beta": MessageLookupByLibrary.simpleMessage("ベータ版に参加します"),
        "jump_to": m8,
        "language": MessageLookupByLibrary.simpleMessage("日本語"),
        "language_en": MessageLookupByLibrary.simpleMessage("Japanese"),
        "level": MessageLookupByLibrary.simpleMessage("レベル"),
        "limited_event": MessageLookupByLibrary.simpleMessage("期間限定イベント"),
        "link": MessageLookupByLibrary.simpleMessage("リンク"),
        "list_count_shown_all": m9,
        "list_count_shown_hidden_all": m10,
        "list_end_hint": m11,
        "login_change_name": MessageLookupByLibrary.simpleMessage("ユーザー名を変更"),
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("パスワードを変更"),
        "login_confirm_password":
            MessageLookupByLibrary.simpleMessage("パスワードを確認"),
        "login_first_hint":
            MessageLookupByLibrary.simpleMessage("まずログインしてください"),
        "login_forget_pwd": MessageLookupByLibrary.simpleMessage("パスワードを忘れた場合"),
        "login_login": MessageLookupByLibrary.simpleMessage("ログイン"),
        "login_logout": MessageLookupByLibrary.simpleMessage("ログアウト"),
        "login_new_name": MessageLookupByLibrary.simpleMessage("新しいユーザー名"),
        "login_new_password": MessageLookupByLibrary.simpleMessage("新しいパスワード"),
        "login_password": MessageLookupByLibrary.simpleMessage("パスワード"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage("以前のパスワードと同じのはならない"),
        "login_signup": MessageLookupByLibrary.simpleMessage("登録"),
        "login_state_not_login":
            MessageLookupByLibrary.simpleMessage("ログインしていません"),
        "login_username": MessageLookupByLibrary.simpleMessage("ユーザー名"),
        "login_username_error": MessageLookupByLibrary.simpleMessage(
            "4桁以上の文字と数字のみ、さらに英語文字で始まりしてください"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("長押しして保存します"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("福袋"),
        "main_record": MessageLookupByLibrary.simpleMessage("シナリオ"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("タイトル"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Master-Detail width"),
        "master_mission": MessageLookupByLibrary.simpleMessage("マスターミッション"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("関連クエスト"),
        "master_mission_solution": MessageLookupByLibrary.simpleMessage("対策"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("ミッションリスト"),
        "master_mission_weekly":
            MessageLookupByLibrary.simpleMessage("ウィークリーミッション"),
        "move_down": MessageLookupByLibrary.simpleMessage("ダウン"),
        "move_up": MessageLookupByLibrary.simpleMessage("アップ"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("魔術礼装"),
        "new_account": MessageLookupByLibrary.simpleMessage("アカウントの新規登録"),
        "next_card": MessageLookupByLibrary.simpleMessage("次のカード"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("幕間も強化クエストもはありません"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("♡をクリックして、すべてのクエストを表示します"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("宝具"),
        "noble_phantasm_level": MessageLookupByLibrary.simpleMessage("宝具レベル"),
        "not_found": MessageLookupByLibrary.simpleMessage("Not Found"),
        "not_implemented": MessageLookupByLibrary.simpleMessage("お楽しみに"),
        "np_short": MessageLookupByLibrary.simpleMessage("NP"),
        "obtain_time": MessageLookupByLibrary.simpleMessage("時間"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("開く"),
        "open_condition": MessageLookupByLibrary.simpleMessage("開放条件"),
        "open_in_file_manager":
            MessageLookupByLibrary.simpleMessage("ファイルマネージャで開いてください"),
        "overview": MessageLookupByLibrary.simpleMessage("概要"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("クラススキル"),
        "plan": MessageLookupByLibrary.simpleMessage("プラン"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("プラン最大化(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("プラン最大化(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("プランの目標"),
        "plan_title": MessageLookupByLibrary.simpleMessage("プラン"),
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("クエストをプラン"),
        "preferred_translation":
            MessageLookupByLibrary.simpleMessage("お気に入りの訳文"),
        "preferred_translation_footer": MessageLookupByLibrary.simpleMessage(
            "ドラッグしてオーダー変更してください。\nUIの言語ではなく、ゲームのデータ記述で使用されます。すべてのゲームデータは、5つの公用語へ翻訳されたことがありません。"),
        "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
        "previous_card": MessageLookupByLibrary.simpleMessage("前のカード"),
        "priority": MessageLookupByLibrary.simpleMessage("優先順位"),
        "project_homepage":
            MessageLookupByLibrary.simpleMessage("プロジェクトホームページ"),
        "quest": MessageLookupByLibrary.simpleMessage("クエスト"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("開放条件"),
        "quest_fixed_drop": MessageLookupByLibrary.simpleMessage("必定のドロップ"),
        "quest_fixed_drop_short": MessageLookupByLibrary.simpleMessage("ドロップ"),
        "quest_reward": MessageLookupByLibrary.simpleMessage("クエスト報酬"),
        "quest_reward_short": MessageLookupByLibrary.simpleMessage("報酬"),
        "rarity": MessageLookupByLibrary.simpleMessage("レアリティ"),
        "rate_app_store":
            MessageLookupByLibrary.simpleMessage("App Storeで評価しよう"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Google Playで評価しよう"),
        "remove_duplicated_svt": MessageLookupByLibrary.simpleMessage("2号機を削除"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("ブラックリストから削除"),
        "rename": MessageLookupByLibrary.simpleMessage("名前変更"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("復刻イベント"),
        "reset": MessageLookupByLibrary.simpleMessage("リセット"),
        "reset_plan_all": m12,
        "reset_plan_shown": m13,
        "restart_to_apply_changes":
            MessageLookupByLibrary.simpleMessage("再起動して設定を有効にしてください"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "再起動してアプリを更新します。更新に失敗した場合は、手動でsourceフォルダをdestinationへコピーペーストしてください"),
        "restore": MessageLookupByLibrary.simpleMessage("復元"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("貯石計画"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("アルバムに保存"),
        "saved": MessageLookupByLibrary.simpleMessage("保存済み"),
        "screen_size": MessageLookupByLibrary.simpleMessage("画面サイズ"),
        "search": MessageLookupByLibrary.simpleMessage("検索"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("基本情報"),
        "search_options": MessageLookupByLibrary.simpleMessage("検索範囲"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("コピー元を選択"),
        "select_lang": MessageLookupByLibrary.simpleMessage("言語を選択"),
        "select_plan": MessageLookupByLibrary.simpleMessage("プランを選択"),
        "servant": MessageLookupByLibrary.simpleMessage("サーヴァント"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("サーヴァントコイン"),
        "servant_coin_short": MessageLookupByLibrary.simpleMessage("コイン"),
        "servant_detail_page":
            MessageLookupByLibrary.simpleMessage("サーヴァント詳細ページ"),
        "servant_list_page":
            MessageLookupByLibrary.simpleMessage("サーヴァントリストページ"),
        "servant_title": MessageLookupByLibrary.simpleMessage("サーヴァント"),
        "set_plan_name": MessageLookupByLibrary.simpleMessage("プラン名を設定"),
        "setting_always_on_top": MessageLookupByLibrary.simpleMessage("一番上で表示"),
        "setting_auto_rotate": MessageLookupByLibrary.simpleMessage("自動回転"),
        "setting_auto_turn_on_plan_not_reach":
            MessageLookupByLibrary.simpleMessage("Auto Turn on PlanNotReach"),
        "setting_home_plan_list_page":
            MessageLookupByLibrary.simpleMessage("ホーム-プランリストページ"),
        "setting_only_change_second_append_skill":
            MessageLookupByLibrary.simpleMessage("アペンドスキル2のみを変更"),
        "setting_priority_tagging":
            MessageLookupByLibrary.simpleMessage("優先順位ノート"),
        "setting_servant_class_filter_style":
            MessageLookupByLibrary.simpleMessage("クラスフィルタースのタイル"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage("「フォロー」ボタンでディフォルトします"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage("ホームページで現在のアカウントを表示します"),
        "setting_tabs_sorting": MessageLookupByLibrary.simpleMessage("ページ表示順序"),
        "settings_data": MessageLookupByLibrary.simpleMessage("データ"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("ドキュメント"),
        "settings_general": MessageLookupByLibrary.simpleMessage("全般"),
        "settings_language": MessageLookupByLibrary.simpleMessage("言語"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("設定"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "アップデート/バッグが大量あう時、お先にバックアップしてください。アプリのアンインストールで内部バックアップが失われることがありますから、頼りになった位置へ移動するようにしてください"),
        "share": MessageLookupByLibrary.simpleMessage("シェア"),
        "show_frame_rate": MessageLookupByLibrary.simpleMessage("フレームレートを表示"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("期限切れのを表示"),
        "silver": MessageLookupByLibrary.simpleMessage("銀"),
        "simulator": MessageLookupByLibrary.simpleMessage("エミュレータ"),
        "skill": MessageLookupByLibrary.simpleMessage("スキル"),
        "skill_up": MessageLookupByLibrary.simpleMessage("スキル強化"),
        "skilled_max10": MessageLookupByLibrary.simpleMessage("スキルレベル最大化(310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("モデル"),
        "sq_fragment_convert":
            MessageLookupByLibrary.simpleMessage("21聖晶片=3聖晶石"),
        "sq_short": MessageLookupByLibrary.simpleMessage("石"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("統計"),
        "still_send": MessageLookupByLibrary.simpleMessage("送信し続けます"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "summon": MessageLookupByLibrary.simpleMessage("ガチャ"),
        "summon_daily": MessageLookupByLibrary.simpleMessage("日替"),
        "summon_ticket_short": MessageLookupByLibrary.simpleMessage("呼符"),
        "summon_title": MessageLookupByLibrary.simpleMessage("ガチャ"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("サポートと寄付"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("フォローされていません"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("非表示"),
        "svt_related_ce": MessageLookupByLibrary.simpleMessage("関連礼装"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("プランをリセット"),
        "svt_second_archive": MessageLookupByLibrary.simpleMessage("保管室"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("Slider/Dropdownを切り替え"),
        "toogle_dark_mode":
            MessageLookupByLibrary.simpleMessage("Toggle Dark Mode"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("スライドを更新"),
        "total_ap": MessageLookupByLibrary.simpleMessage("AP合計"),
        "total_counts": MessageLookupByLibrary.simpleMessage("総数"),
        "update": MessageLookupByLibrary.simpleMessage("アップデート"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("すでに最新バージョンになります"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("データセットをアップデート"),
        "userdata": MessageLookupByLibrary.simpleMessage("ユーザーデータ"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("バックアップをダウンロード"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("バックアップを選択"),
        "userdata_sync": MessageLookupByLibrary.simpleMessage("データを同期します"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("バックアップをアップロード"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("チョコ礼装"),
        "version": MessageLookupByLibrary.simpleMessage("バージョン"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("イラストを表示します"),
        "voice": MessageLookupByLibrary.simpleMessage("ボイス"),
        "warning": MessageLookupByLibrary.simpleMessage("ワーニング"),
        "web_renderer": MessageLookupByLibrary.simpleMessage("Webレンダラ"),
        "words_separate": m14
      };
}
