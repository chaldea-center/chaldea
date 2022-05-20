// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(curVersion, newVersion, releaseNote) =>
      "Current version: ${curVersion}\nLatest version: ${newVersion}\nRelease Note:\n${releaseNote}";

  static String m1(n) => "اقصى ${n} يانصيب";

  static String m2(n, total) => "Grail to crystal: ${n}";

  static String m3(error) => "فشل الاستيراد. الخطأ:\n${error}";

  static String m4(name) => "${name} موجود مسبقا";

  static String m5(site) => "اقفز الى${site}";

  static String m6(first) => "${Intl.select(first, {
            'true': 'Already the first one',
            'false': 'Already the last one',
            'other': 'No more',
          })}";

  static String m7(n) => "إعادة الخطة ${n}(All)";

  static String m8(n) => "إعادة الخطة${n}(Shown)";

  static String m9(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("عن التطبيق"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "البيانات ضمن هذا التطبيق مصدرها لعبة Fate/GO والمواقع الاكترونية التابعة. حقوق نشر النصوص الأصلية، الصور، والصوتيات تنتمي الى TYPE MOON/FGO PROJECT.\n\n تصميم التطبيق مبني على التطبيق المصغر ل وي شات \"material programe\" وتطبيق ال آي او اس \"GUDA\". \n"),
        "about_data_source":
            MessageLookupByLibrary.simpleMessage("مصدر البيانات"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "الرجاء إعلامنا في حالة وجود مصادر غير مذكورة او تم التعدي عليها."),
        "about_feedback": MessageLookupByLibrary.simpleMessage("المرجعية "),
        "about_update_app_detail": m0,
        "active_skill": MessageLookupByLibrary.simpleMessage("المهارة النشطة"),
        "add": MessageLookupByLibrary.simpleMessage("أضف "),
        "add_to_blacklist":
            MessageLookupByLibrary.simpleMessage("ضف الى اللائحة السوداء"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP نسبة"),
        "append_skill": MessageLookupByLibrary.simpleMessage(" الباسيڨ سكيل"),
        "append_skill_short":
            MessageLookupByLibrary.simpleMessage("باسيف سكيل"),
        "ascension": MessageLookupByLibrary.simpleMessage("أسينشن "),
        "ascension_short": MessageLookupByLibrary.simpleMessage("أسينشن "),
        "ascension_up": MessageLookupByLibrary.simpleMessage("أسينشن"),
        "attachment": MessageLookupByLibrary.simpleMessage("مرفق"),
        "auto_reset": MessageLookupByLibrary.simpleMessage("إعادة ضبط تلقائي "),
        "auto_update": MessageLookupByLibrary.simpleMessage("تحديث تلقائي"),
        "backup": MessageLookupByLibrary.simpleMessage("النسخ احتياطي "),
        "backup_history":
            MessageLookupByLibrary.simpleMessage("تاريخ النسخ الاحتياطي "),
        "blacklist": MessageLookupByLibrary.simpleMessage("القائمة السوداء "),
        "bond": MessageLookupByLibrary.simpleMessage("البوند"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("كرافت البوند"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("تأثير البوند"),
        "bronze": MessageLookupByLibrary.simpleMessage("برونز"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("وزن"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "card_description": MessageLookupByLibrary.simpleMessage("الوصف"),
        "card_info": MessageLookupByLibrary.simpleMessage("عن"),
        "carousel_setting":
            MessageLookupByLibrary.simpleMessage("اعدادات المكتبة"),
        "change_log": MessageLookupByLibrary.simpleMessage("سجل التغييرات "),
        "characters_in_card":
            MessageLookupByLibrary.simpleMessage("الشخصية في البطاقة"),
        "check_update": MessageLookupByLibrary.simpleMessage("تفقد عن تحديث "),
        "clear": MessageLookupByLibrary.simpleMessage("مسح"),
        "clear_cache":
            MessageLookupByLibrary.simpleMessage("مسح ذاكرة التخزين المؤقت"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage(
            "ذاكرة التخزين المؤقت تم مسحها"),
        "clear_cache_hint":
            MessageLookupByLibrary.simpleMessage("يشمل الصور والصوتيات"),
        "command_code": MessageLookupByLibrary.simpleMessage("كوماند كود"),
        "confirm": MessageLookupByLibrary.simpleMessage("تأكيد"),
        "consumed": MessageLookupByLibrary.simpleMessage("المستهلك"),
        "copied": MessageLookupByLibrary.simpleMessage("منسوخ"),
        "copy": MessageLookupByLibrary.simpleMessage("نسخ"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("نسخ خطة من…"),
        "costume": MessageLookupByLibrary.simpleMessage("زي خاص"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("فتح زي خاص"),
        "counts": MessageLookupByLibrary.simpleMessage("عد"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("الكرافتز"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("اصنع تكرار"),
        "cur_account": MessageLookupByLibrary.simpleMessage("الحساب الحالي"),
        "current_": MessageLookupByLibrary.simpleMessage("حالي "),
        "dark_mode": MessageLookupByLibrary.simpleMessage("الوضع المظلم"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("المظلم"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("الوضع المضيئ"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("حسب النظام"),
        "delete": MessageLookupByLibrary.simpleMessage("حذف"),
        "demands": MessageLookupByLibrary.simpleMessage("متطلبات"),
        "display_setting":
            MessageLookupByLibrary.simpleMessage("إعدادات العرض"),
        "download": MessageLookupByLibrary.simpleMessage("تحميل "),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "لضمان التوافق الرجاء تحديث آخر نسخة من التطبيق قبل تحديث البيانات "),
        "download_source": MessageLookupByLibrary.simpleMessage("مصدر التحميل"),
        "download_source_hint": MessageLookupByLibrary.simpleMessage(
            "تحديث حزمة البيانات والتطبيق"),
        "downloaded": MessageLookupByLibrary.simpleMessage("تم التحميل"),
        "downloading": MessageLookupByLibrary.simpleMessage("جاري التحميل"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("اضغط + لإضافة عنصر"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("متوسط AP"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("احسب"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("نسبة الدروب"),
        "edit": MessageLookupByLibrary.simpleMessage("تعديل "),
        "effect_search": MessageLookupByLibrary.simpleMessage("البحث عن بفف"),
        "efficiency": MessageLookupByLibrary.simpleMessage("كفاءة "),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("كفاءة "),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20APنسبة "),
        "efficiency_type_drop":
            MessageLookupByLibrary.simpleMessage("نسبة الدروب"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("الاعداء"),
        "enhance": MessageLookupByLibrary.simpleMessage("تطوير"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage(
            " سيتم استهلاك العناصر التالية للتطوير"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("لا انترنت"),
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            " ستتم إضافة جميع العناصر إلى الحقيبة وإزالة الحدث خارج الخطة "),
        "event_collect_items":
            MessageLookupByLibrary.simpleMessage("تجميع موارد"),
        "event_lottery_limit_hint": m1,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("يانصيب محدود"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("اليانصيب"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("يانصيب غير محدود"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage(" لم يتم التخطيط للحدث "),
        "event_progress": MessageLookupByLibrary.simpleMessage("التقدم"),
        "event_rerun_replace_grail": m2,
        "event_title": MessageLookupByLibrary.simpleMessage("حدث"),
        "exchange_ticket":
            MessageLookupByLibrary.simpleMessage("تذكرة المبادلة"),
        "exchange_ticket_short":
            MessageLookupByLibrary.simpleMessage("التذكرة"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("المستويات"),
        "exp_card_same_class":
            MessageLookupByLibrary.simpleMessage("نفس الكلاس"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("بطاقة التطوير"),
        "failed": MessageLookupByLibrary.simpleMessage("فشل"),
        "favorite": MessageLookupByLibrary.simpleMessage("مفضل"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("أضف لقطات شاشة او ملف مرفق"),
        "feedback_contact":
            MessageLookupByLibrary.simpleMessage("معلومات التواصل "),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("المرجعية والاقتراحات"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("ارسل"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("هدف"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("خلفية"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("جسد"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("تكبير"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("رأس "),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "Please download or import FFO data first↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("نفس الخادم "),
        "fgo_domus_aurea":
            MessageLookupByLibrary.simpleMessage("FGO Domus Aurea"),
        "filename": MessageLookupByLibrary.simpleMessage("اسم الملف"),
        "filter": MessageLookupByLibrary.simpleMessage("فلتر"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("نوع"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("ميزة"),
        "filter_category": MessageLookupByLibrary.simpleMessage("فئة"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("التأثير "),
        "filter_gender": MessageLookupByLibrary.simpleMessage("الجنس"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("طابق الكل"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("يمتلك"),
        "filter_plan_not_reached":
            MessageLookupByLibrary.simpleMessage("خطة غير محققه"),
        "filter_plan_reached":
            MessageLookupByLibrary.simpleMessage("خطة محققه"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("عكسي"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("عرض"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("سكلز"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("فرز"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("الكلاس"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("رقم"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("الندرة"),
        "free_progress": MessageLookupByLibrary.simpleMessage("مهمة محدودة"),
        "free_progress_newest":
            MessageLookupByLibrary.simpleMessage("أحدث(JP)"),
        "free_quest": MessageLookupByLibrary.simpleMessage("الفري كويست"),
        "free_quest_calculator":
            MessageLookupByLibrary.simpleMessage("الفري كويست"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("فري كويست"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("الرئيسية"),
        "game_drop": MessageLookupByLibrary.simpleMessage("دروب "),
        "game_experience": MessageLookupByLibrary.simpleMessage("خبرة"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("بوند"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("مكافئات"),
        "gamedata": MessageLookupByLibrary.simpleMessage("بيانات اللعبة"),
        "gold": MessageLookupByLibrary.simpleMessage("ذهب"),
        "grail": MessageLookupByLibrary.simpleMessage("كأس"),
        "grail_up": MessageLookupByLibrary.simpleMessage("Palingenesis"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("منحنى النمو"),
        "help": MessageLookupByLibrary.simpleMessage("مساعدة"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("اخفي المنتهية"),
        "icons": MessageLookupByLibrary.simpleMessage("الأيقونات"),
        "ignore": MessageLookupByLibrary.simpleMessage("تجاهل"),
        "illustration": MessageLookupByLibrary.simpleMessage("الرسوميات"),
        "illustrator": MessageLookupByLibrary.simpleMessage("الرسامين"),
        "import_data": MessageLookupByLibrary.simpleMessage("استيراد"),
        "import_data_error": m3,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("نجح استيراد البيانات"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("مكرر"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "Click import button to import decrypted HTTPS response"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            " انقر على الخادم لإخفاء / إظهار "),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("المقفل فقط"),
        "import_screenshot":
            MessageLookupByLibrary.simpleMessage("استورد عن طريق لقطة شاشة"),
        "import_screenshot_hint": MessageLookupByLibrary.simpleMessage(
            "حدث العناصر التي تم التعرف عليها فقط"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("تحديث العناصر"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("استورد ملف المصدر"),
        "info_agility": MessageLookupByLibrary.simpleMessage("الرشاقة"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("التنسيق"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("نقاط البوند"),
        "info_bond_points_single": MessageLookupByLibrary.simpleMessage("نقطة"),
        "info_bond_points_sum":
            MessageLookupByLibrary.simpleMessage("الإجمالي "),
        "info_cards": MessageLookupByLibrary.simpleMessage("بطاقات"),
        "info_critical_rate":
            MessageLookupByLibrary.simpleMessage("نسبة الكريتكال"),
        "info_cv": MessageLookupByLibrary.simpleMessage("مؤدي الأصوات"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("نسبة الموت"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("قدرة التحمل"),
        "info_gender": MessageLookupByLibrary.simpleMessage("الجنس"),
        "info_luck": MessageLookupByLibrary.simpleMessage("الحظ"),
        "info_mana": MessageLookupByLibrary.simpleMessage("المانا"),
        "info_np": MessageLookupByLibrary.simpleMessage("الوهم النبيل"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("نسبة الشحن"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("نسبة النجوم"),
        "info_strength": MessageLookupByLibrary.simpleMessage("القوة"),
        "info_trait": MessageLookupByLibrary.simpleMessage("علامة"),
        "info_value": MessageLookupByLibrary.simpleMessage("قيمة"),
        "input_invalid_hint":
            MessageLookupByLibrary.simpleMessage("مدخلات غير صالحة"),
        "install": MessageLookupByLibrary.simpleMessage("تنصيب"),
        "interlude_and_rankup":
            MessageLookupByLibrary.simpleMessage("انترلود والرانك اب"),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"Files\" app/On My iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("مشاكل "),
        "item": MessageLookupByLibrary.simpleMessage("مواد التطوير "),
        "item_already_exist_hint": m4,
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("مواد الاسينشن"),
        "item_category_bronze":
            MessageLookupByLibrary.simpleMessage("المواد الفضية"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("مواد الايفنت"),
        "item_category_gem": MessageLookupByLibrary.simpleMessage("جوهرة"),
        "item_category_gems":
            MessageLookupByLibrary.simpleMessage("مواد الاسكلز"),
        "item_category_gold":
            MessageLookupByLibrary.simpleMessage("المواد الذهبية"),
        "item_category_magic_gem":
            MessageLookupByLibrary.simpleMessage("جوهرة سحرية"),
        "item_category_monument": MessageLookupByLibrary.simpleMessage("تمثال"),
        "item_category_others": MessageLookupByLibrary.simpleMessage("أخرى "),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("قطعة"),
        "item_category_secret_gem":
            MessageLookupByLibrary.simpleMessage("جوهرة سحرية"),
        "item_category_silver":
            MessageLookupByLibrary.simpleMessage("مواد فضية"),
        "item_category_special":
            MessageLookupByLibrary.simpleMessage("مواد خاصة "),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("المواد"),
        "item_eff": MessageLookupByLibrary.simpleMessage("Item Eff"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            " قبل التخطيط ، يمكنك تعيين العدد المتجاوز للعناصر (تستخدم فقط في تخطيط المهام المجانيه )"),
        "item_left": MessageLookupByLibrary.simpleMessage("متبقي"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("لا فري كويستز"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("أظهر المطلوبة فقط"),
        "item_own": MessageLookupByLibrary.simpleMessage("مملوك"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("المواد"),
        "item_title": MessageLookupByLibrary.simpleMessage("المواد"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("الإجمالي "),
        "join_beta": MessageLookupByLibrary.simpleMessage("انضم للبيتا"),
        "jump_to": m5,
        "language": MessageLookupByLibrary.simpleMessage("عربي"),
        "language_en": MessageLookupByLibrary.simpleMessage("Arabic"),
        "level": MessageLookupByLibrary.simpleMessage("مستوى"),
        "limited_event": MessageLookupByLibrary.simpleMessage("أيفنت حصري"),
        "link": MessageLookupByLibrary.simpleMessage("رابط"),
        "list_end_hint": m6,
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("غير كلمة السر"),
        "login_first_hint":
            MessageLookupByLibrary.simpleMessage("الرجاء تسجيل الدخول اولا"),
        "login_forget_pwd":
            MessageLookupByLibrary.simpleMessage("نسيت كلمة السر"),
        "login_login": MessageLookupByLibrary.simpleMessage("دخول"),
        "login_logout": MessageLookupByLibrary.simpleMessage("خروج"),
        "login_new_password":
            MessageLookupByLibrary.simpleMessage("كلمة سر جديدة"),
        "login_password": MessageLookupByLibrary.simpleMessage("كلمة سر"),
        "login_password_error": MessageLookupByLibrary.simpleMessage(
            "يجب ان تحتوي على حروف وأرقام وألا تقل عن أربعة خانات"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage(
                "لا يمكن ان تكون نفس كلمة السر القديمة"),
        "login_signup": MessageLookupByLibrary.simpleMessage("تسجيل"),
        "login_state_not_login":
            MessageLookupByLibrary.simpleMessage("لم يتم تسجيل "),
        "login_username": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
        "login_username_error": MessageLookupByLibrary.simpleMessage(
            "لابد ان يحتوي اسم المستخدم على حروف وأرقام وان يبتدئ بحرف وألا يكون أقل من أربع خانات"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("ضغطة مطولة للحفط"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage(" حقيبة الحظ "),
        "master_mission": MessageLookupByLibrary.simpleMessage("مهام الماستر"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("مهام ذات صلة"),
        "master_mission_solution":
            MessageLookupByLibrary.simpleMessage("التسهيل"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("المهام"),
        "move_down": MessageLookupByLibrary.simpleMessage("تحرك لأسفل"),
        "move_up": MessageLookupByLibrary.simpleMessage("تحرك لأعلى "),
        "mystic_code": MessageLookupByLibrary.simpleMessage("الميستك كود"),
        "new_account": MessageLookupByLibrary.simpleMessage("حساب جديد "),
        "next_card": MessageLookupByLibrary.simpleMessage("التالي"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("لا يوجد رانك اب او مهمة"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("اضغط ♡ لعرض جميع مهام الخدم"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("الوهم النبيل "),
        "noble_phantasm_level":
            MessageLookupByLibrary.simpleMessage("الوهم النبيل"),
        "not_implemented":
            MessageLookupByLibrary.simpleMessage(" لم تنفذ بعد "),
        "ok": MessageLookupByLibrary.simpleMessage("موافق"),
        "open": MessageLookupByLibrary.simpleMessage("فتح"),
        "open_condition": MessageLookupByLibrary.simpleMessage("شرط"),
        "overview": MessageLookupByLibrary.simpleMessage("ملخص"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("باسيڨ سكل"),
        "plan": MessageLookupByLibrary.simpleMessage("الخطة"),
        "plan_max10":
            MessageLookupByLibrary.simpleMessage("الحد الأقصى للخطة (310)"),
        "plan_max9":
            MessageLookupByLibrary.simpleMessage("الحد الاقصى للخطة (999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage(" هدف الخطة "),
        "plan_title": MessageLookupByLibrary.simpleMessage("الخطة"),
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("مهام التخطيط "),
        "preview": MessageLookupByLibrary.simpleMessage("عرض"),
        "previous_card": MessageLookupByLibrary.simpleMessage("السوابق"),
        "priority": MessageLookupByLibrary.simpleMessage("أفضلية"),
        "project_homepage":
            MessageLookupByLibrary.simpleMessage("الصفحة الرئيسية للمشروع"),
        "quest": MessageLookupByLibrary.simpleMessage("مهمة"),
        "quest_condition": MessageLookupByLibrary.simpleMessage(" الظروف "),
        "rarity": MessageLookupByLibrary.simpleMessage("الندرة"),
        "rate_app_store":
            MessageLookupByLibrary.simpleMessage("قيمنا على آب ستور"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("قيمنا على متجر بلاي"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage(" إزالة المكررة "),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("إزالة من القائمة السوداء"),
        "rename": MessageLookupByLibrary.simpleMessage("إعادة التسمية"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("ري رن"),
        "reset": MessageLookupByLibrary.simpleMessage("إعادة "),
        "reset_plan_all": m7,
        "reset_plan_shown": m8,
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            " أعد التشغيل للتحديث  إذا فشل التحديث ، يرجى نسخ مجلد المصدر يدويًا إلى الوجهة "),
        "restore": MessageLookupByLibrary.simpleMessage("إعادة"),
        "save": MessageLookupByLibrary.simpleMessage("حفط"),
        "save_to_photos":
            MessageLookupByLibrary.simpleMessage("الحفظ في الصور"),
        "saved": MessageLookupByLibrary.simpleMessage("محفوظ "),
        "search": MessageLookupByLibrary.simpleMessage("بحث"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("اساسي"),
        "search_options": MessageLookupByLibrary.simpleMessage("نطاق البحث"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("تحديد مصدر النسخ"),
        "select_plan": MessageLookupByLibrary.simpleMessage("تحديد خطة"),
        "servant": MessageLookupByLibrary.simpleMessage("الخدم"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("عملة الخدم"),
        "servant_title": MessageLookupByLibrary.simpleMessage("الخادم"),
        "set_plan_name":
            MessageLookupByLibrary.simpleMessage("اعداد اسم الخطة"),
        "setting_auto_rotate":
            MessageLookupByLibrary.simpleMessage("تدوير تلقائي"),
        "settings_data": MessageLookupByLibrary.simpleMessage("بيانات"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("المستندات"),
        "settings_general": MessageLookupByLibrary.simpleMessage("عام"),
        "settings_language": MessageLookupByLibrary.simpleMessage("اللغة"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "قم بعمل نسخة احتياطية قبل التحديث واحفظها خارج مجلدات التطبيق احتياطا"),
        "share": MessageLookupByLibrary.simpleMessage("مشاركة"),
        "show_outdated":
            MessageLookupByLibrary.simpleMessage("عرض المنتهى منه"),
        "silver": MessageLookupByLibrary.simpleMessage("فضي "),
        "simulator": MessageLookupByLibrary.simpleMessage("المحاكي"),
        "skill": MessageLookupByLibrary.simpleMessage("مهارة"),
        "skill_up": MessageLookupByLibrary.simpleMessage("رفع المهارة"),
        "skilled_max10":
            MessageLookupByLibrary.simpleMessage("المهارات القصوى (310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("الأرواح"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("احصائيات"),
        "success": MessageLookupByLibrary.simpleMessage("نجاح"),
        "summon": MessageLookupByLibrary.simpleMessage("استدعاء"),
        "summon_title": MessageLookupByLibrary.simpleMessage("الاستدعاءات"),
        "support_chaldea":
            MessageLookupByLibrary.simpleMessage("الدعم والتبرعات"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("غير مفضل"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("مخفي"),
        "svt_reset_plan":
            MessageLookupByLibrary.simpleMessage("إعادة ضبط الخطة"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage(" تبديل الشرائح /المهابط"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("تحديث الشرائح"),
        "total_ap": MessageLookupByLibrary.simpleMessage("الاي بي الكلي"),
        "total_counts": MessageLookupByLibrary.simpleMessage("الحساب النهائي"),
        "update": MessageLookupByLibrary.simpleMessage("تحديث "),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("النسخة الاعلي مسبقا"),
        "update_dataset":
            MessageLookupByLibrary.simpleMessage("تحديث حزمة البيانات "),
        "upload": MessageLookupByLibrary.simpleMessage("رفع"),
        "userdata": MessageLookupByLibrary.simpleMessage("بيانات المستخدم "),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("تحميل نسخة احتياطية"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("اختر نسخة احتياطية "),
        "userdata_sync":
            MessageLookupByLibrary.simpleMessage("مزامنة البيانات"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("رفع نسخة احتياطية "),
        "valentine_craft":
            MessageLookupByLibrary.simpleMessage("كرافت عيد الحب"),
        "version": MessageLookupByLibrary.simpleMessage("النسخة"),
        "view_illustration":
            MessageLookupByLibrary.simpleMessage("عرض الرسومية"),
        "voice": MessageLookupByLibrary.simpleMessage("صوت"),
        "words_separate": m9
      };
}
