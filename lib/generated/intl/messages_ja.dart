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

  static String m10(url) =>
      "Chaldea - クロスプラットフォームのFate/GOアイテム計画アプリ。ゲーム情報の閲覧、サーヴァント/イベント/アイテム計画、マスターミッション計画、ガチャシミュレーターなどの機能をサポートします。\n\n詳細はこちら: \n${url}\n";

  static String m11(version) => "最低限のアプリバージョン: ≥ ${version}";

  static String m1(n) => "最大${n}ボックス";

  static String m2(n, total) => "聖杯は伝承結晶${n}/${total}個に置き換わります";

  static String m12(filename, hash, localHash) =>
      "File ${filename} not found or mismatched hash: ${hash} - ${localHash}";

  static String m3(error) => "インポートに失敗しました、エラー:\n${error}";

  static String m4(name) => "${name}はすでにあります";

  static String m5(site) => "${site}にジャンプします";

  static String m13(shown, total) => "表示${shown}/合計${total}";

  static String m14(shown, ignore, total) =>
      "表示${shown}/無視${ignore}/合計${total}";

  static String m6(first) => "${Intl.select(first, {
            'true': '最初のもの',
            'false': '最後のもの',
            'other': '最後のもの',
          })}";

  static String m15(n) => "第${n}節";

  static String m18(region) => "${region}お知らせ";

  static String m7(n) => "プラン${n}をリセット(すべて)";

  static String m8(n) => "プラン${n}をリセット(表示のみ)";

  static String m19(battles, ap) => "共${battles}回戦闘、${ap} AP";

  static String m20(n) => "プロフィール${n}";

  static String m9(a, b) => "${a}${b}";

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
        "active_skill_short": MessageLookupByLibrary.simpleMessage("保有"),
        "add": MessageLookupByLibrary.simpleMessage("追加"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("フィードバックの内容を記入してください"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("ブラックリストに追加"),
        "anniversary": MessageLookupByLibrary.simpleMessage("周年"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP効率"),
        "app_data_folder": MessageLookupByLibrary.simpleMessage("データフォルダ"),
        "app_data_use_external_storage":
            MessageLookupByLibrary.simpleMessage("外部ストレージ（SDカード）を使用"),
        "append_skill": MessageLookupByLibrary.simpleMessage("アペンドスキル"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("アペンド"),
        "april_fool": MessageLookupByLibrary.simpleMessage("エイプリルフール"),
        "ascension": MessageLookupByLibrary.simpleMessage("霊基"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("霊基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("霊基再臨"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("ファイルから"),
        "attach_from_photos": MessageLookupByLibrary.simpleMessage("アルバムから"),
        "attach_help": MessageLookupByLibrary.simpleMessage(
            "アルバムで画像をインポートする時問題があれば、ファイルでインポートしてください"),
        "attachment": MessageLookupByLibrary.simpleMessage("添付"),
        "auto_reset": MessageLookupByLibrary.simpleMessage("自動リセット"),
        "auto_update": MessageLookupByLibrary.simpleMessage("自動更新"),
        "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
        "backup_failed": MessageLookupByLibrary.simpleMessage("バックアップ失敗"),
        "backup_history": MessageLookupByLibrary.simpleMessage("バックアップ履歴"),
        "blacklist": MessageLookupByLibrary.simpleMessage("ブラックリスト"),
        "bond": MessageLookupByLibrary.simpleMessage("絆"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("絆礼装"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("絆効率"),
        "bond_limit": MessageLookupByLibrary.simpleMessage("絆上限"),
        "bootstrap_page_title": MessageLookupByLibrary.simpleMessage("ガイドページ"),
        "bronze": MessageLookupByLibrary.simpleMessage("銅"),
        "cache_icons": MessageLookupByLibrary.simpleMessage("キャッシュアイコン"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("構成比"),
        "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
        "card_asset_chara_figure":
            MessageLookupByLibrary.simpleMessage("立ち絵差分"),
        "card_asset_command": MessageLookupByLibrary.simpleMessage("コマンドカード"),
        "card_asset_face": MessageLookupByLibrary.simpleMessage("アイコン"),
        "card_asset_narrow_figure":
            MessageLookupByLibrary.simpleMessage("編成画面"),
        "card_asset_status": MessageLookupByLibrary.simpleMessage("ステータスアイコン"),
        "card_description": MessageLookupByLibrary.simpleMessage("解説"),
        "card_info": MessageLookupByLibrary.simpleMessage("資料"),
        "card_name": MessageLookupByLibrary.simpleMessage("カード名"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("カルーセル設定"),
        "ce_status": MessageLookupByLibrary.simpleMessage("所持状態"),
        "ce_status_met": MessageLookupByLibrary.simpleMessage("未所持"),
        "ce_status_not_met": MessageLookupByLibrary.simpleMessage("未遭遇"),
        "ce_status_owned": MessageLookupByLibrary.simpleMessage("所持"),
        "ce_type_mix_hp_atk": MessageLookupByLibrary.simpleMessage("MIX"),
        "ce_type_none_hp_atk": MessageLookupByLibrary.simpleMessage("ATK"),
        "ce_type_pure_atk": MessageLookupByLibrary.simpleMessage("ATK"),
        "ce_type_pure_hp": MessageLookupByLibrary.simpleMessage("HP"),
        "chaldea_account":
            MessageLookupByLibrary.simpleMessage("Chaldea アカウント"),
        "chaldea_account_system_hint": MessageLookupByLibrary.simpleMessage(
            "V1データとの互換性はありません。\nユーザデータのバックアップ及びマルチデバイス同期を行うためのシンプルなアカウントシステムです。\nセキュリティ保証がなければ、常用パスワードを設定しないでください。\n上記のサービスが要らなければ、登録することは必要がありません。"),
        "chaldea_backup":
            MessageLookupByLibrary.simpleMessage("Chaldea バックアップ"),
        "chaldea_server": MessageLookupByLibrary.simpleMessage("Chaldeaサーバー"),
        "chaldea_server_cn": MessageLookupByLibrary.simpleMessage("中国"),
        "chaldea_server_global": MessageLookupByLibrary.simpleMessage("國際"),
        "chaldea_server_hint":
            MessageLookupByLibrary.simpleMessage("ゲームデータ、スクリーンショット認識用"),
        "chaldea_share_msg": m10,
        "change_log": MessageLookupByLibrary.simpleMessage("更新履歴"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("キャラ"),
        "check_update": MessageLookupByLibrary.simpleMessage("更新確認"),
        "clear": MessageLookupByLibrary.simpleMessage("クリア"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("キャッシュクリア"),
        "clear_cache_finish":
            MessageLookupByLibrary.simpleMessage("キャッシュクリアが完了しました"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("イラスト、ボイスなど"),
        "clear_data": MessageLookupByLibrary.simpleMessage("データの消去"),
        "coin_summon_num": MessageLookupByLibrary.simpleMessage("召喚所得"),
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
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("他のプランからコピーした"),
        "costume": MessageLookupByLibrary.simpleMessage("霊衣"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("霊衣開放"),
        "counts": MessageLookupByLibrary.simpleMessage("カウント"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "create_account_textfield_helper":
            MessageLookupByLibrary.simpleMessage("より多くのアカウントを後設定で追加できます"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("2号機を生成"),
        "crit_star_mod": MessageLookupByLibrary.simpleMessage("スター補正"),
        "cur_account": MessageLookupByLibrary.simpleMessage("アカウント"),
        "current_": MessageLookupByLibrary.simpleMessage("現在"),
        "current_version": MessageLookupByLibrary.simpleMessage("現バージョン"),
        "custom_mission": MessageLookupByLibrary.simpleMessage("カスタム任務"),
        "custom_mission_nothing_hint": MessageLookupByLibrary.simpleMessage(
            "ミッションがありません。＋をクリックして追加しましょう。"),
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
        "def_np_gain_mod": MessageLookupByLibrary.simpleMessage("敵攻撃補正"),
        "delete": MessageLookupByLibrary.simpleMessage("削除"),
        "demands": MessageLookupByLibrary.simpleMessage("要件"),
        "display_grid": MessageLookupByLibrary.simpleMessage("グリッド"),
        "display_list": MessageLookupByLibrary.simpleMessage("リスト"),
        "display_setting": MessageLookupByLibrary.simpleMessage("設定表示"),
        "done": MessageLookupByLibrary.simpleMessage("完成"),
        "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "互換性を確保するために、更新する前にアプリの最新バージョンにアップデードしてください"),
        "download_source": MessageLookupByLibrary.simpleMessage("ダウンロードソース"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("中国大陸なら中国エンドポイントを選択"),
        "downloaded": MessageLookupByLibrary.simpleMessage("ダウンロード済み"),
        "downloading": MessageLookupByLibrary.simpleMessage("ダウンロード中"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("＋をクリックしてアイテムを追加"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("APの最低限"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("解答"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("ドロップ率"),
        "edit": MessageLookupByLibrary.simpleMessage("編集"),
        "effect_scope": MessageLookupByLibrary.simpleMessage("効果範囲"),
        "effect_search": MessageLookupByLibrary.simpleMessage("バフ検索"),
        "effect_target": MessageLookupByLibrary.simpleMessage("効果対象"),
        "effect_type": MessageLookupByLibrary.simpleMessage("効果タイプ"),
        "efficiency": MessageLookupByLibrary.simpleMessage("効率"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("効率タイプ"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP効率"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("ドロップ率"),
        "email": MessageLookupByLibrary.simpleMessage("メール"),
        "enemy_filter_trait_hint":
            MessageLookupByLibrary.simpleMessage("特性のフィルターは、フリークエストの敵にのみ適用される"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("エネミー"),
        "enhance": MessageLookupByLibrary.simpleMessage("強化"),
        "enhance_warning":
            MessageLookupByLibrary.simpleMessage("強化すると、次のアイテムが控除されます"),
        "error_no_data_found":
            MessageLookupByLibrary.simpleMessage("データが見つかりません"),
        "error_no_internet":
            MessageLookupByLibrary.simpleMessage("インターネットに接続できません"),
        "error_required_app_version": m11,
        "event_bonus": MessageLookupByLibrary.simpleMessage("ボーナス"),
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "すべてのアイテムを倉庫に追加し、プランからこのイベントを削除します"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("アイテム収集"),
        "event_item_extra": MessageLookupByLibrary.simpleMessage("追加アイテム"),
        "event_item_fixed_extra":
            MessageLookupByLibrary.simpleMessage("追加固定アイテム"),
        "event_lottery": MessageLookupByLibrary.simpleMessage("ボックス"),
        "event_lottery_limit_hint": m1,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("有限なボックスガチャ"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("ボックス"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("無限なボックスガチャ"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("イベントはプランされていません"),
        "event_point_reward": MessageLookupByLibrary.simpleMessage("ポイント"),
        "event_progress": MessageLookupByLibrary.simpleMessage("現在のイベント"),
        "event_quest": MessageLookupByLibrary.simpleMessage("イベントクエスト"),
        "event_rerun_replace_grail": m2,
        "event_shop": MessageLookupByLibrary.simpleMessage("ショップ"),
        "event_title": MessageLookupByLibrary.simpleMessage("イベント"),
        "event_tower": MessageLookupByLibrary.simpleMessage("塔"),
        "event_treasure_box": MessageLookupByLibrary.simpleMessage("宝箱"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交換券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交換券"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("レベル"),
        "exp_card_plan_next": MessageLookupByLibrary.simpleMessage("NEXT"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("同じクラス"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("種火計算"),
        "failed": MessageLookupByLibrary.simpleMessage("失敗"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("フォロー"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("e.g. スクショとその他のファイル"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("連絡先情報"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("フィードバックと提案"),
        "feedback_form_alert":
            MessageLookupByLibrary.simpleMessage("フィードバックフォームは送信されませんが、終了します？"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "フィードバックを送信する前に、<**FAQ**>を確認してください。 フィードバックを提供する際は、詳しく説明してください。\n- 再現方法/期待されるパフォーマンス\n- アプリ/データのバージョン、デバイスシステム/バージョン\n- スクショとログを添付する\n- そして、連絡先情報（電子メールなど）を提供するようにしてください"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("送信"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("件名"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("背景"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("体"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("切り抜く "),
        "ffo_head": MessageLookupByLibrary.simpleMessage("頭"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "まずFFOリソースをダウンロードまたはインポートしてください↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("同じ鯖"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("効率劇場"),
        "file_not_found_or_mismatched_hash": m12,
        "filename": MessageLookupByLibrary.simpleMessage("ファイル名"),
        "fill_email_warning":
            MessageLookupByLibrary.simpleMessage("連絡先情報がない場合は、返信することはできません。"),
        "filter": MessageLookupByLibrary.simpleMessage("フィルター"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("属性"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("隠し属性"),
        "filter_category": MessageLookupByLibrary.simpleMessage("分類"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("効果"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("全て"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("入手方法"),
        "filter_plan_not_reached":
            MessageLookupByLibrary.simpleMessage("プラン未完成"),
        "filter_plan_reached": MessageLookupByLibrary.simpleMessage("達成"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("逆選択"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("表示"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("スキルレベル"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("ソート"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("クラス"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("番号"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("スター"),
        "foukun": MessageLookupByLibrary.simpleMessage("フォウくん"),
        "free_progress": MessageLookupByLibrary.simpleMessage("クエスト"),
        "free_progress_newest": MessageLookupByLibrary.simpleMessage("最新"),
        "free_quest": MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "free_quest_calculator":
            MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("フリークエスト"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("ホーム"),
        "game_account": MessageLookupByLibrary.simpleMessage("ゲームアカウント"),
        "game_data_not_found": MessageLookupByLibrary.simpleMessage(
            "ゲームデータが見つかりませので、まずデータをダウンロードしてください"),
        "game_drop": MessageLookupByLibrary.simpleMessage("ドロップ"),
        "game_experience": MessageLookupByLibrary.simpleMessage("EXP"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("絆"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("クリア報酬"),
        "game_server": MessageLookupByLibrary.simpleMessage("ゲームサーバー"),
        "gamedata": MessageLookupByLibrary.simpleMessage("ゲームデータ"),
        "general_default": MessageLookupByLibrary.simpleMessage("既定"),
        "general_others": MessageLookupByLibrary.simpleMessage("ほか"),
        "general_special": MessageLookupByLibrary.simpleMessage("特殊"),
        "general_type": MessageLookupByLibrary.simpleMessage("タイプ"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("聖杯"),
        "grail_up": MessageLookupByLibrary.simpleMessage("聖杯転臨"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("成長曲線"),
        "guda_female": MessageLookupByLibrary.simpleMessage("ぐだ子"),
        "guda_male": MessageLookupByLibrary.simpleMessage("ぐだ男"),
        "help": MessageLookupByLibrary.simpleMessage("ヘルプ"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("期限切れを非表示"),
        "hide_unreleased_card":
            MessageLookupByLibrary.simpleMessage("未實装サーヴァントを隠す"),
        "high_difficulty_quest":
            MessageLookupByLibrary.simpleMessage("高難易度クエスト"),
        "http_sniff_hint": MessageLookupByLibrary.simpleMessage(
            "(JP/NA/CN/TW)アカウントがログインしているときにデータ"),
        "https_sniff": MessageLookupByLibrary.simpleMessage("Httpsスニッフィング"),
        "hunting_quest": MessageLookupByLibrary.simpleMessage("ハンティングクエスト"),
        "icons": MessageLookupByLibrary.simpleMessage("アイコン"),
        "ignore": MessageLookupByLibrary.simpleMessage("無視"),
        "illustration": MessageLookupByLibrary.simpleMessage("イラスト"),
        "illustrator": MessageLookupByLibrary.simpleMessage("イラスレ"),
        "import_active_skill_hint":
            MessageLookupByLibrary.simpleMessage("強化 - 鯖スキル強化"),
        "import_active_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("保有スキルのスクショ"),
        "import_append_skill_hint":
            MessageLookupByLibrary.simpleMessage("強化 - アペンドスキル強化"),
        "import_append_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("アペンドスキルのスクショ"),
        "import_backup": MessageLookupByLibrary.simpleMessage("バックアップのインポート"),
        "import_csv_export_all":
            MessageLookupByLibrary.simpleMessage("全てのサーヴァント"),
        "import_csv_export_empty":
            MessageLookupByLibrary.simpleMessage("空のテンプレート"),
        "import_csv_export_favorite":
            MessageLookupByLibrary.simpleMessage("フォローしている鯖のみ"),
        "import_csv_export_template":
            MessageLookupByLibrary.simpleMessage("テンプレート書き出し"),
        "import_csv_load_csv": MessageLookupByLibrary.simpleMessage("CSV読み込み"),
        "import_csv_title": MessageLookupByLibrary.simpleMessage("CSVテンプレート"),
        "import_data": MessageLookupByLibrary.simpleMessage("インポート"),
        "import_data_error": m3,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("インポートは成功しました"),
        "import_from_clipboard":
            MessageLookupByLibrary.simpleMessage("クリップボードから"),
        "import_from_file": MessageLookupByLibrary.simpleMessage("ファイルから"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("複数の鯖はOK"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "アカウントデータをインポートために、右上隅をクリックして、復号化したHTTPS応答パッケージをインポートしてください\nヘルプをクリックして、HTTPS応答内容をキャプチャ・復号化する方法を確認してください"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            "サーヴァントをクリックして、そちらを非表示/再表示することができます"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("ロックしたもののみ"),
        "import_image": MessageLookupByLibrary.simpleMessage("画像をインポート"),
        "import_item_hint":
            MessageLookupByLibrary.simpleMessage("マイルーム - 所持アイテム一覧"),
        "import_item_screenshots":
            MessageLookupByLibrary.simpleMessage("アイテムのスクショ"),
        "import_screenshot":
            MessageLookupByLibrary.simpleMessage("スクショをインポートします"),
        "import_screenshot_hint":
            MessageLookupByLibrary.simpleMessage("識別された結果のみをアップデートします"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("素材更新"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("ソースデータをインポート"),
        "import_userdata_more":
            MessageLookupByLibrary.simpleMessage("他のインポート方法"),
        "info_agility": MessageLookupByLibrary.simpleMessage("敏捷"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("属性"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("絆ポイント"),
        "info_bond_points_single": MessageLookupByLibrary.simpleMessage("ポイント"),
        "info_bond_points_sum": MessageLookupByLibrary.simpleMessage("累計"),
        "info_cards": MessageLookupByLibrary.simpleMessage("カード"),
        "info_charge": MessageLookupByLibrary.simpleMessage("チャージ"),
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
        "interlude": MessageLookupByLibrary.simpleMessage("幕間の物語"),
        "interlude_and_rankup": MessageLookupByLibrary.simpleMessage("幕間・強化"),
        "invalid_input": MessageLookupByLibrary.simpleMessage("無効な入力"),
        "invalid_startup_path":
            MessageLookupByLibrary.simpleMessage("無効なスタートアップ！"),
        "invalid_startup_path_info": MessageLookupByLibrary.simpleMessage(
            "非システム・パスへ抽出して、アプリを再起動してください。\"C:\\\", \"C:\\Program Files\"などは無効なパス。"),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"ファイル\"アプリ/My iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("FAQ"),
        "item": MessageLookupByLibrary.simpleMessage("アイテム"),
        "item_already_exist_hint": m4,
        "item_apple": MessageLookupByLibrary.simpleMessage("果実"),
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("霊基再臨素材"),
        "item_category_bronze": MessageLookupByLibrary.simpleMessage("銅素材"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("イベント鯖霊基再臨用アイテム"),
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
            "プランを計算する前に、材料の残量を設定することはできます（フリクエプランの場合のみ）"),
        "item_grail2crystal": MessageLookupByLibrary.simpleMessage("聖杯→伝承結晶"),
        "item_left": MessageLookupByLibrary.simpleMessage("残量"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("フリークエストはありません"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("不足なアイテムのみ"),
        "item_own": MessageLookupByLibrary.simpleMessage("持ってる"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("アイテムのスクショ"),
        "item_stat_include_owned":
            MessageLookupByLibrary.simpleMessage("在庫を含める"),
        "item_stat_sub_event":
            MessageLookupByLibrary.simpleMessage("活動収入を差し引く"),
        "item_stat_sub_owned": MessageLookupByLibrary.simpleMessage("在庫を差し引く"),
        "item_title": MessageLookupByLibrary.simpleMessage("アイテム"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("合計"),
        "join_beta": MessageLookupByLibrary.simpleMessage("ベータ版に参加します"),
        "jump_to": m5,
        "language": MessageLookupByLibrary.simpleMessage("日本語"),
        "language_en": MessageLookupByLibrary.simpleMessage("Japanese"),
        "level": MessageLookupByLibrary.simpleMessage("レベル"),
        "limited_event": MessageLookupByLibrary.simpleMessage("期間限定イベント"),
        "link": MessageLookupByLibrary.simpleMessage("リンク"),
        "list_count_shown_all": m13,
        "list_count_shown_hidden_all": m14,
        "list_end_hint": m6,
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
        "login_password_error": MessageLookupByLibrary.simpleMessage(
            "6-18桁の文字と数字のみ、さらに少なくとも1つの英語文字を含んでください"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage("以前のパスワードと同じのはならない"),
        "login_signup": MessageLookupByLibrary.simpleMessage("登録"),
        "login_state_not_login": MessageLookupByLibrary.simpleMessage("未ログイン"),
        "login_username": MessageLookupByLibrary.simpleMessage("ユーザー名"),
        "login_username_error": MessageLookupByLibrary.simpleMessage(
            "4桁以上の文字と数字のみ、さらに英語文字で始まりしてください"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("長押しして保存します"),
        "lottery_cost_per_roll":
            MessageLookupByLibrary.simpleMessage("ガチャ1回のコスト"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("福袋"),
        "lucky_bag_expectation": MessageLookupByLibrary.simpleMessage("期待値"),
        "lucky_bag_expectation_short":
            MessageLookupByLibrary.simpleMessage("期待値"),
        "lucky_bag_rating": MessageLookupByLibrary.simpleMessage("スコアリング"),
        "lucky_bag_tooltip_unwanted":
            MessageLookupByLibrary.simpleMessage("本当に不要"),
        "lucky_bag_tooltip_wanted":
            MessageLookupByLibrary.simpleMessage("とても欲しい"),
        "main_quest": MessageLookupByLibrary.simpleMessage("メインクエスト"),
        "main_story": MessageLookupByLibrary.simpleMessage("シナリオ"),
        "main_story_chapter": MessageLookupByLibrary.simpleMessage("チャプター"),
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
        "migrate_external_storage_btn_no":
            MessageLookupByLibrary.simpleMessage("移行しない"),
        "migrate_external_storage_btn_yes":
            MessageLookupByLibrary.simpleMessage("移行"),
        "migrate_external_storage_manual_warning":
            MessageLookupByLibrary.simpleMessage(
                "データを手動で移動してください。そうしないと、起動後にデータが空になります。"),
        "migrate_external_storage_title":
            MessageLookupByLibrary.simpleMessage("データの移行"),
        "mission": MessageLookupByLibrary.simpleMessage("ミッション"),
        "move_down": MessageLookupByLibrary.simpleMessage("ダウン"),
        "move_up": MessageLookupByLibrary.simpleMessage("アップ"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("魔術礼装"),
        "new_account": MessageLookupByLibrary.simpleMessage("アカウントの新規登録"),
        "next_card": MessageLookupByLibrary.simpleMessage("次のカード"),
        "next_page": MessageLookupByLibrary.simpleMessage("次のページ"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("幕間も強化クエストもはありません"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("♡をクリックして、すべてのクエストを表示します"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("宝具"),
        "noble_phantasm_level": MessageLookupByLibrary.simpleMessage("宝具レベル"),
        "not_found": MessageLookupByLibrary.simpleMessage("Not Found"),
        "not_implemented": MessageLookupByLibrary.simpleMessage("お楽しみに"),
        "not_outdated": MessageLookupByLibrary.simpleMessage("期限切れなし"),
        "np_gain_mod": MessageLookupByLibrary.simpleMessage("被ダメージ補正"),
        "np_short": MessageLookupByLibrary.simpleMessage("宝具"),
        "obtain_time": MessageLookupByLibrary.simpleMessage("タイム"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("開く"),
        "open_condition": MessageLookupByLibrary.simpleMessage("開放条件"),
        "open_in_file_manager":
            MessageLookupByLibrary.simpleMessage("ファイルマネージャで開いてください"),
        "outdated": MessageLookupByLibrary.simpleMessage("期限切れ"),
        "overview": MessageLookupByLibrary.simpleMessage("概要"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("クラススキル"),
        "passive_skill_short": MessageLookupByLibrary.simpleMessage("クラス"),
        "plan": MessageLookupByLibrary.simpleMessage("プラン"),
        "plan_list_set_all": MessageLookupByLibrary.simpleMessage("一括設定"),
        "plan_list_set_all_current": MessageLookupByLibrary.simpleMessage("現在"),
        "plan_list_set_all_target":
            MessageLookupByLibrary.simpleMessage("ターゲット"),
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
        "prev_page": MessageLookupByLibrary.simpleMessage("前のページ"),
        "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
        "previous_card": MessageLookupByLibrary.simpleMessage("前のカード"),
        "priority": MessageLookupByLibrary.simpleMessage("優先順位"),
        "priority_tagging_hint": MessageLookupByLibrary.simpleMessage(
            "コメントは長すぎないようにすることをお勧めします。長すぎると、表示が不完全になります。"),
        "project_homepage":
            MessageLookupByLibrary.simpleMessage("プロジェクトホームページ"),
        "quest": MessageLookupByLibrary.simpleMessage("クエスト"),
        "quest_chapter_n": m15,
        "quest_condition": MessageLookupByLibrary.simpleMessage("開放条件"),
        "quest_detail_btn": MessageLookupByLibrary.simpleMessage("詳細"),
        "quest_enemy_summary_hint": MessageLookupByLibrary.simpleMessage(
            "フリークエストの敵編成まとめにある各属性は、サーバーによって上書きされる可能性があり、あくまで参考程度に考えてください。\n*特殊*特性とは、敵の一部のみがその特性を持っていることを示します。"),
        "quest_fields": MessageLookupByLibrary.simpleMessage("フィールド"),
        "quest_fixed_drop": MessageLookupByLibrary.simpleMessage("必定のドロップ"),
        "quest_fixed_drop_short": MessageLookupByLibrary.simpleMessage("ドロップ"),
        "quest_reward": MessageLookupByLibrary.simpleMessage("クエスト報酬"),
        "quest_reward_short": MessageLookupByLibrary.simpleMessage("報酬"),
        "rarity": MessageLookupByLibrary.simpleMessage("レアリティ"),
        "rate_app_store": MessageLookupByLibrary.simpleMessage("App Storeで評価"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Google Playで評価"),
        "region_cn": MessageLookupByLibrary.simpleMessage("簡体字版"),
        "region_jp": MessageLookupByLibrary.simpleMessage("日本版"),
        "region_kr": MessageLookupByLibrary.simpleMessage("韓国版"),
        "region_na": MessageLookupByLibrary.simpleMessage("北米版"),
        "region_notice": m18,
        "region_tw": MessageLookupByLibrary.simpleMessage("繁体字版"),
        "remove_duplicated_svt": MessageLookupByLibrary.simpleMessage("2号機を削除"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("ブラックリストから削除"),
        "rename": MessageLookupByLibrary.simpleMessage("名前変更"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("復刻イベント"),
        "reset": MessageLookupByLibrary.simpleMessage("リセット"),
        "reset_plan_all": m7,
        "reset_plan_shown": m8,
        "restart_to_apply_changes":
            MessageLookupByLibrary.simpleMessage("再起動して設定を有効にしてください"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "再起動してアプリを更新します。更新に失敗した場合は、手動でsourceフォルダをdestinationへコピーペーストしてください"),
        "restore": MessageLookupByLibrary.simpleMessage("復元"),
        "results": MessageLookupByLibrary.simpleMessage("結果"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("貯石計画"),
        "same_event_plan": MessageLookupByLibrary.simpleMessage("同じイベントプランを維持"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("アルバムに保存"),
        "saved": MessageLookupByLibrary.simpleMessage("保存済み"),
        "screen_size": MessageLookupByLibrary.simpleMessage("画面サイズ"),
        "screenshots": MessageLookupByLibrary.simpleMessage("スクショ"),
        "search": MessageLookupByLibrary.simpleMessage("検索"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("基本情報"),
        "search_options": MessageLookupByLibrary.simpleMessage("検索範囲"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("コピー元を選択"),
        "select_item_title": MessageLookupByLibrary.simpleMessage("アイテムを選択"),
        "select_lang": MessageLookupByLibrary.simpleMessage("言語を選択"),
        "select_plan": MessageLookupByLibrary.simpleMessage("プランを選択"),
        "send_email_to": MessageLookupByLibrary.simpleMessage("こちらにメールを送信"),
        "sending": MessageLookupByLibrary.simpleMessage("送信中"),
        "sending_failed": MessageLookupByLibrary.simpleMessage("送信失敗"),
        "sent": MessageLookupByLibrary.simpleMessage("済み"),
        "servant": MessageLookupByLibrary.simpleMessage("サーヴァント"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("サーヴァントコイン"),
        "servant_coin_short": MessageLookupByLibrary.simpleMessage("コイン"),
        "servant_detail_page": MessageLookupByLibrary.simpleMessage("鯖詳細ページ"),
        "servant_list_page": MessageLookupByLibrary.simpleMessage("鯖リストページ"),
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
        "show_carousel": MessageLookupByLibrary.simpleMessage("カルーセルを表示"),
        "show_frame_rate": MessageLookupByLibrary.simpleMessage("フレームレートを表示"),
        "show_fullscreen": MessageLookupByLibrary.simpleMessage("フルスクリーンを表示"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("期限切れのを表示"),
        "silver": MessageLookupByLibrary.simpleMessage("銀"),
        "simulator": MessageLookupByLibrary.simpleMessage("エミュ"),
        "skill": MessageLookupByLibrary.simpleMessage("スキル"),
        "skill_up": MessageLookupByLibrary.simpleMessage("スキル強化"),
        "skilled_max10": MessageLookupByLibrary.simpleMessage("スキルレベル最大化(310)"),
        "solution_battle_count": MessageLookupByLibrary.simpleMessage("カウント"),
        "solution_target_count": MessageLookupByLibrary.simpleMessage("目標カウント"),
        "solution_total_battles_ap": m19,
        "sort_order": MessageLookupByLibrary.simpleMessage("ソート"),
        "sprites": MessageLookupByLibrary.simpleMessage("モデル"),
        "sq_fragment_convert":
            MessageLookupByLibrary.simpleMessage("21聖晶片=3聖晶石"),
        "sq_short": MessageLookupByLibrary.simpleMessage("石"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("統計"),
        "still_send": MessageLookupByLibrary.simpleMessage("送信し続けます"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "summon": MessageLookupByLibrary.simpleMessage("ガチャ"),
        "summon_daily": MessageLookupByLibrary.simpleMessage("日替"),
        "summon_expectation_btn": MessageLookupByLibrary.simpleMessage("期待値計算"),
        "summon_gacha_footer": MessageLookupByLibrary.simpleMessage("娯楽のみ"),
        "summon_gacha_result": MessageLookupByLibrary.simpleMessage("ガチャ結果"),
        "summon_show_banner": MessageLookupByLibrary.simpleMessage("バナーを表示"),
        "summon_ticket_short": MessageLookupByLibrary.simpleMessage("呼符"),
        "summon_title": MessageLookupByLibrary.simpleMessage("ガチャ"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("サポートと寄付"),
        "svt_ascension_icon": MessageLookupByLibrary.simpleMessage("霊基再臨アイコン"),
        "svt_basic_info": MessageLookupByLibrary.simpleMessage("情報"),
        "svt_class_filter_auto": MessageLookupByLibrary.simpleMessage("自动"),
        "svt_class_filter_hide": MessageLookupByLibrary.simpleMessage("非表示"),
        "svt_class_filter_single_row":
            MessageLookupByLibrary.simpleMessage("「Extraクラス」展開、単一行"),
        "svt_class_filter_single_row_expanded":
            MessageLookupByLibrary.simpleMessage("単一行、「Extraクラス」を折り畳み"),
        "svt_class_filter_two_row":
            MessageLookupByLibrary.simpleMessage("「Extraクラス」は2行目に表示"),
        "svt_fav_btn_remember": MessageLookupByLibrary.simpleMessage("前の選択"),
        "svt_fav_btn_show_all": MessageLookupByLibrary.simpleMessage("すべて表示"),
        "svt_fav_btn_show_favorite":
            MessageLookupByLibrary.simpleMessage("フォロー表示"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("未フォロー"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("非表示"),
        "svt_profile": MessageLookupByLibrary.simpleMessage("プロフィール"),
        "svt_profile_info": MessageLookupByLibrary.simpleMessage("キャラクター詳細"),
        "svt_profile_n": m20,
        "svt_related_ce": MessageLookupByLibrary.simpleMessage("関連礼装"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("プランをリセット"),
        "svt_second_archive": MessageLookupByLibrary.simpleMessage("保管室"),
        "svt_stat_own_total":
            MessageLookupByLibrary.simpleMessage("（999）所有/合計"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("Slider/Dropdownを切り替え"),
        "switch_region": MessageLookupByLibrary.simpleMessage("サーバーを切り替え"),
        "test_info_pad": MessageLookupByLibrary.simpleMessage("テスト用情報"),
        "testing": MessageLookupByLibrary.simpleMessage("テスト中"),
        "time_close": MessageLookupByLibrary.simpleMessage("閉じる"),
        "time_end": MessageLookupByLibrary.simpleMessage("エンド"),
        "time_start": MessageLookupByLibrary.simpleMessage("スタート"),
        "toggle_dark_mode": MessageLookupByLibrary.simpleMessage("ダークモードに切り替え"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("スライドを更新"),
        "total_ap": MessageLookupByLibrary.simpleMessage("AP合計"),
        "total_counts": MessageLookupByLibrary.simpleMessage("総数"),
        "treasure_box_draw_cost":
            MessageLookupByLibrary.simpleMessage("1個開封のコスト"),
        "treasure_box_extra_gift":
            MessageLookupByLibrary.simpleMessage("1箱あたりのおまけギフト"),
        "treasure_box_max_draw_once":
            MessageLookupByLibrary.simpleMessage("1回最大開封数"),
        "update": MessageLookupByLibrary.simpleMessage("更新"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("すでに最新バージョンになります"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("データセットをアップデート"),
        "update_msg_error": MessageLookupByLibrary.simpleMessage("更新失敗"),
        "update_msg_no_update":
            MessageLookupByLibrary.simpleMessage("利用できる更新がない"),
        "update_msg_succuss": MessageLookupByLibrary.simpleMessage("更新済み"),
        "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
        "usage": MessageLookupByLibrary.simpleMessage("使い方"),
        "userdata": MessageLookupByLibrary.simpleMessage("ユーザーデータ"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("バックアップをダウンロード"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("バックアップを選択"),
        "userdata_local": MessageLookupByLibrary.simpleMessage("ユーザーデータ（ローカル）"),
        "userdata_sync": MessageLookupByLibrary.simpleMessage("データ同期"),
        "userdata_sync_hint":
            MessageLookupByLibrary.simpleMessage("アカウントデータのみを更新し、ローカル設定を含めない"),
        "userdata_sync_server":
            MessageLookupByLibrary.simpleMessage("データ同期(サーバー)"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("バックアップをアップロード"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("チョコ礼装"),
        "version": MessageLookupByLibrary.simpleMessage("バージョン"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("イラストを表示します"),
        "voice": MessageLookupByLibrary.simpleMessage("ボイス"),
        "war_age": MessageLookupByLibrary.simpleMessage("時代"),
        "war_banner": MessageLookupByLibrary.simpleMessage("バナー"),
        "war_title": MessageLookupByLibrary.simpleMessage("クエスト一覧"),
        "warning": MessageLookupByLibrary.simpleMessage("警告"),
        "web_renderer": MessageLookupByLibrary.simpleMessage("Webレンダラ"),
        "words_separate": m9
      };
}
