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
      "النسخة الحالية : ${curVersion}\nاخر نسخة : ${newVersion}\nملاحظة الاصدار :\n${releaseNote}";

  static String m1(url) =>
      "\"Chaldea - أداة مساعدة عبر الأنظمة الأساسية لـ Fate / GO. دعم مراجعة بيانات اللعبة ، وتخطيط الخادم / الحدث / العنصر ، وتخطيط المهمة الرئيسية ، ومحاكاة الاستدعاء ، وما إلى ذلك.\n\n للتفاصيل:\n ${url}\n \"";

  static String m2(version) => "نسخة التطبيق المطلوبة : ≥ ${version}";

  static String m3(n) => "اقصى ${n} يانصيب";

  static String m4(n, total) => "كريستال الى لور : ${n}";

  static String m5(error) => "فشل الاستيراد. الخطأ:\n${error}";

  static String m6(name) => "${name} موجود مسبقا";

  static String m7(site) => "اقفز الى${site}";

  static String m8(first) => "${Intl.select(first, {
            'true': 'Already the first one',
            'false': 'Already the last one',
            'other': 'No more',
          })}";

  static String m9(n) => "القسم ${n}";

  static String m10(region) => "${region} ميّز";

  static String m11(n) => "إعادة الخطة ${n}(All)";

  static String m12(n) => "إعادة الخطة${n}(Shown)";

  static String m13(n) => "الملف الشخصي ${n}";

  static String m14(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("عن التطبيق"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "البيانات ضمن هذا التطبيق مصدرها لعبة Fate/GO والمواقع الاكترونية التابعة. حقوق نشر النصوص الأصلية، الصور، والصوتيات تنتمي الى TYPE MOON/FGO PROJECT.\n\n تصميم التطبيق مبني على التطبيق المصغر ل وي شات \"material programe\" وتطبيق ال آي او اس \"GUDA\". \n"),
        "about_data_source":
            MessageLookupByLibrary.simpleMessage("مصدر البيانات"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "الرجاء إعلامنا في حالة وجود مصادر غير مذكورة او تم التعدي عليها."),
        "about_feedback": MessageLookupByLibrary.simpleMessage("المرجعية"),
        "about_update_app_detail": m0,
        "account_title": MessageLookupByLibrary.simpleMessage("الحساب"),
        "active_skill": MessageLookupByLibrary.simpleMessage("المهارة النشطة"),
        "active_skill_short": MessageLookupByLibrary.simpleMessage("النشط"),
        "add": MessageLookupByLibrary.simpleMessage("أضف"),
        "add_condition": MessageLookupByLibrary.simpleMessage("أضافة شرط"),
        "add_feedback_details_warning": MessageLookupByLibrary.simpleMessage(
            "رجاءا ،أضف تفاصيل إلى المرجعية"),
        "add_to_blacklist":
            MessageLookupByLibrary.simpleMessage("ضف الى اللائحة السوداء"),
        "anniversary": MessageLookupByLibrary.simpleMessage("الذكرى السنوية"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP نسبة"),
        "app_data_folder":
            MessageLookupByLibrary.simpleMessage("مجلد البيانات"),
        "app_data_use_external_storage": MessageLookupByLibrary.simpleMessage(
            "استخدم تخزين خارجي (بطاقة SD)"),
        "append_skill": MessageLookupByLibrary.simpleMessage("الباسيڨ سكيل"),
        "append_skill_short":
            MessageLookupByLibrary.simpleMessage("باسيف سكيل"),
        "april_fool": MessageLookupByLibrary.simpleMessage("كذبة أبريل"),
        "ascension": MessageLookupByLibrary.simpleMessage("أسينشن"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("أسينشن"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("أسينشن"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("من الملفات"),
        "attach_from_photos": MessageLookupByLibrary.simpleMessage("من الصور"),
        "attach_help": MessageLookupByLibrary.simpleMessage(
            "اذا كنت تواجه مشكله في اختيار الصور، اختر ملفات بدلا عن ذلك"),
        "attachment": MessageLookupByLibrary.simpleMessage("مرفق"),
        "auth_data_hints": MessageLookupByLibrary.simpleMessage(
            "\"تلميحات:\n - معرف المستخدم \"ID\" هنا ليس كود الصداقه الذي تراه في صفحة تسجيل الدخول / صفحة الاصدقاء\n - لا تشارك المفاتيح أعلاه أو لقطة الشاشة للآخرين !!!\n - اختر إحدى الطرق التالية للاستيراد \""),
        "auto_reset": MessageLookupByLibrary.simpleMessage("إعادة ضبط تلقائي"),
        "auto_update": MessageLookupByLibrary.simpleMessage("تحديث تلقائي"),
        "autoplay": MessageLookupByLibrary.simpleMessage("تشغيل تلقائي"),
        "background": MessageLookupByLibrary.simpleMessage("خلفية"),
        "backup": MessageLookupByLibrary.simpleMessage("النسخ احتياطي"),
        "backup_failed":
            MessageLookupByLibrary.simpleMessage("فشل النسخ الاحتياطي"),
        "backup_history":
            MessageLookupByLibrary.simpleMessage("تاريخ النسخ الاحتياطي"),
        "blacklist": MessageLookupByLibrary.simpleMessage("القائمة السوداء"),
        "bond": MessageLookupByLibrary.simpleMessage("البوند"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("كرافت البوند"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("تأثير البوند"),
        "bond_limit": MessageLookupByLibrary.simpleMessage("حد البوند"),
        "bootstrap_page_title":
            MessageLookupByLibrary.simpleMessage("الصفحة التمهيدية"),
        "branch_quest": MessageLookupByLibrary.simpleMessage("المهام الفرعية"),
        "bronze": MessageLookupByLibrary.simpleMessage("برونز"),
        "buff_check_opponent": MessageLookupByLibrary.simpleMessage("الخصم"),
        "buff_check_self": MessageLookupByLibrary.simpleMessage("شخصي"),
        "cache_icons": MessageLookupByLibrary.simpleMessage("حفظ الأيقونات"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("وزن"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "card_asset_chara_figure":
            MessageLookupByLibrary.simpleMessage("الشخصية"),
        "card_asset_command":
            MessageLookupByLibrary.simpleMessage("الكوماند كارد"),
        "card_asset_face":
            MessageLookupByLibrary.simpleMessage("الصورة المصغرة"),
        "card_asset_narrow_figure":
            MessageLookupByLibrary.simpleMessage("تكوين"),
        "card_asset_status": MessageLookupByLibrary.simpleMessage("رمز الحالة"),
        "card_description": MessageLookupByLibrary.simpleMessage("الوصف"),
        "card_info": MessageLookupByLibrary.simpleMessage("عن"),
        "card_name": MessageLookupByLibrary.simpleMessage("اسم البطاقة"),
        "card_status_owned": MessageLookupByLibrary.simpleMessage("مملوك"),
        "carousel_setting":
            MessageLookupByLibrary.simpleMessage("اعدادات المكتبة"),
        "chaldea_account": MessageLookupByLibrary.simpleMessage("حساب كاليديا"),
        "chaldea_account_system_hint": MessageLookupByLibrary.simpleMessage(
            "غير متوافق مع بيانات الاصدار V1.\n نظام الحساب البسيط للنسخ الاحتياطي لبيانات المستخدم إلى الخادم والتزامن متعدد الأجهزة\n لا يوجد ضمان أمني ، يرجى عدم تعيين كلمات المرور التي تستخدمها بشكل متكرر !!!\n لا حاجة للتسجيل إذا كنت لا تحتاج إلى هاتين الميزتين."),
        "chaldea_backup": MessageLookupByLibrary.simpleMessage(
            "النسخ الاحتياطي لتطبيق كاليديا"),
        "chaldea_server": MessageLookupByLibrary.simpleMessage("سيرفر كاليديا"),
        "chaldea_server_cn": MessageLookupByLibrary.simpleMessage("الصين"),
        "chaldea_server_global":
            MessageLookupByLibrary.simpleMessage("العالمي"),
        "chaldea_server_hint": MessageLookupByLibrary.simpleMessage(
            "تستخدم لبيانات اللعبة ولقطات الشاشة"),
        "chaldea_share_msg": m1,
        "change_log": MessageLookupByLibrary.simpleMessage("سجل التغييرات"),
        "characters_in_card":
            MessageLookupByLibrary.simpleMessage("الشخصية التي بالكرافت"),
        "check_update": MessageLookupByLibrary.simpleMessage("تفقد عن تحديث"),
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
        "contact_information_not_filled":
            MessageLookupByLibrary.simpleMessage("لم يتم ملء معلومات الاتصال"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage(
                "لن يتمكن المطور من الرد على ملاحظاتك"),
        "copied": MessageLookupByLibrary.simpleMessage("منسوخ"),
        "copy": MessageLookupByLibrary.simpleMessage("نسخ"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("نسخ خطة من…"),
        "costume": MessageLookupByLibrary.simpleMessage("زي خاص"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("فتح زي خاص"),
        "counts": MessageLookupByLibrary.simpleMessage("عد"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("الكرافتز"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "يمكنك إضافة المزيد من الحسابات لاحقا في الاعدادات"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("اصنع تكرار"),
        "cur_account": MessageLookupByLibrary.simpleMessage("الحساب الحالي"),
        "current_": MessageLookupByLibrary.simpleMessage("حالي"),
        "current_version":
            MessageLookupByLibrary.simpleMessage("النسخة الحالية"),
        "custom_mission": MessageLookupByLibrary.simpleMessage("مهمة مخصصة"),
        "custom_mission_nothing_hint":
            MessageLookupByLibrary.simpleMessage("لا مهام اضغط + لأضافة مهمة"),
        "custom_mission_source_mission":
            MessageLookupByLibrary.simpleMessage("مصدر المهمة"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("الوضع المظلم"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("المظلم"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("الوضع المضيئ"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("حسب النظام"),
        "database": MessageLookupByLibrary.simpleMessage("قاعدة البيانات"),
        "database_not_downloaded": MessageLookupByLibrary.simpleMessage(
            "قاعدة البيانات غير محملة ،ترغب بالاستمرار ؟"),
        "dataset_version":
            MessageLookupByLibrary.simpleMessage("إصدار حزمة البيانات"),
        "date": MessageLookupByLibrary.simpleMessage("تاريخ"),
        "debug": MessageLookupByLibrary.simpleMessage("تصحيح"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("قائمة التصحيح"),
        "delete": MessageLookupByLibrary.simpleMessage("حذف"),
        "demands": MessageLookupByLibrary.simpleMessage("متطلبات"),
        "display_setting":
            MessageLookupByLibrary.simpleMessage("إعدادات العرض"),
        "done": MessageLookupByLibrary.simpleMessage("تم"),
        "download": MessageLookupByLibrary.simpleMessage("تحميل"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "لضمان التوافق الرجاء تحديث آخر نسخة من التطبيق قبل تحديث البيانات"),
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
        "edit": MessageLookupByLibrary.simpleMessage("تعديل"),
        "effect_search": MessageLookupByLibrary.simpleMessage("البحث عن بف"),
        "effect_target": MessageLookupByLibrary.simpleMessage("هدف التأثير"),
        "effect_type": MessageLookupByLibrary.simpleMessage("نوع التأثير"),
        "efficiency": MessageLookupByLibrary.simpleMessage("كفاءة"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("كفاءة"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20APنسبة"),
        "efficiency_type_drop":
            MessageLookupByLibrary.simpleMessage("نسبة الدروب"),
        "email": MessageLookupByLibrary.simpleMessage("بريد"),
        "enemy_filter_trait_hint": MessageLookupByLibrary.simpleMessage(
            "فلتر العلامة \"ترايت\" يستخدم فقط للفري كويست من القصة الأساسية."),
        "enemy_list": MessageLookupByLibrary.simpleMessage("الاعداء"),
        "enhance": MessageLookupByLibrary.simpleMessage("تطوير"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage(
            "سيتم استهلاك العناصر التالية للتطوير"),
        "error_no_data_found":
            MessageLookupByLibrary.simpleMessage("لا يوجد بيانات"),
        "error_no_internet": MessageLookupByLibrary.simpleMessage("لا انترنت"),
        "error_required_app_version": m2,
        "event": MessageLookupByLibrary.simpleMessage("حدث"),
        "event_bonus": MessageLookupByLibrary.simpleMessage("إضافي"),
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "ستتم إضافة جميع العناصر إلى الحقيبة وإزالة الحدث خارج الخطة"),
        "event_collect_items":
            MessageLookupByLibrary.simpleMessage("تجميع موارد"),
        "event_item_extra":
            MessageLookupByLibrary.simpleMessage("عناصر إضافية"),
        "event_lottery": MessageLookupByLibrary.simpleMessage("يانصيب"),
        "event_lottery_limit_hint": m3,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("يانصيب محدود"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("اليانصيب"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("يانصيب غير محدود"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("لم يتم التخطيط للحدث"),
        "event_point_reward": MessageLookupByLibrary.simpleMessage("نقاط"),
        "event_progress": MessageLookupByLibrary.simpleMessage("التقدم"),
        "event_quest": MessageLookupByLibrary.simpleMessage("مهام الايفنت"),
        "event_rerun_replace_grail": m4,
        "event_tower": MessageLookupByLibrary.simpleMessage("برج"),
        "event_treasure_box":
            MessageLookupByLibrary.simpleMessage("بطاقة استبدال"),
        "exchange_ticket":
            MessageLookupByLibrary.simpleMessage("تذكرة المبادلة"),
        "exchange_ticket_short":
            MessageLookupByLibrary.simpleMessage("التذكرة"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("المستويات"),
        "exp_card_same_class":
            MessageLookupByLibrary.simpleMessage("نفس الكلاس"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("بطاقة التطوير"),
        "failed": MessageLookupByLibrary.simpleMessage("فشل"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("مفضل"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("أضف لقطات شاشة او ملف مرفق"),
        "feedback_contact":
            MessageLookupByLibrary.simpleMessage("معلومات التواصل"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("المرجعية والاقتراحات"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "يرجى مراجعة <** FAQ **> أولاً قبل التواصل .  والتفاصيل التالية مطلوبة:\n - كيف يجب ان يكون / المتوقع \n - إصدار التطبيق / إصدار حزمة البيانات الحالية ونظام الجهاز والإصدار\n - إرفاق لقطات وسجلات\n - من الأفضل تقديم معلومات الاتصال (مثل البريد الإلكتروني)"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("ارسل"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("هدف"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("جسد"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("تكبير"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("رأس"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "Please download or import FFO data first↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("نفس الخادم"),
        "fgo_domus_aurea":
            MessageLookupByLibrary.simpleMessage("FGO Domus Aurea"),
        "filename": MessageLookupByLibrary.simpleMessage("اسم الملف"),
        "filter": MessageLookupByLibrary.simpleMessage("فلتر"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("نوع"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("ميزة"),
        "filter_category": MessageLookupByLibrary.simpleMessage("فئة"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("التأثير"),
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
        "game_account": MessageLookupByLibrary.simpleMessage("حساب اللعبة"),
        "game_drop": MessageLookupByLibrary.simpleMessage("دروب"),
        "game_experience": MessageLookupByLibrary.simpleMessage("خبرة"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("بوند"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("مكافئات"),
        "game_server": MessageLookupByLibrary.simpleMessage("خادم اللعبة"),
        "gamedata": MessageLookupByLibrary.simpleMessage("بيانات اللعبة"),
        "gender": MessageLookupByLibrary.simpleMessage("الجنس"),
        "general_all": MessageLookupByLibrary.simpleMessage("الكل"),
        "general_default": MessageLookupByLibrary.simpleMessage("الافتراضي"),
        "general_others": MessageLookupByLibrary.simpleMessage("الأخري"),
        "general_special": MessageLookupByLibrary.simpleMessage("خاص"),
        "general_type": MessageLookupByLibrary.simpleMessage("النوع"),
        "gold": MessageLookupByLibrary.simpleMessage("ذهب"),
        "grail": MessageLookupByLibrary.simpleMessage("كأس"),
        "grail_up": MessageLookupByLibrary.simpleMessage("اعطاء كؤوس"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("منحنى النمو"),
        "guda_female": MessageLookupByLibrary.simpleMessage("غوداكو"),
        "guda_male": MessageLookupByLibrary.simpleMessage("غودو"),
        "help": MessageLookupByLibrary.simpleMessage("مساعدة"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("اخفي المنتهية"),
        "icons": MessageLookupByLibrary.simpleMessage("الأيقونات"),
        "ignore": MessageLookupByLibrary.simpleMessage("تجاهل"),
        "illustration": MessageLookupByLibrary.simpleMessage("الرسوميات"),
        "illustrator": MessageLookupByLibrary.simpleMessage("الرسامين"),
        "import_data": MessageLookupByLibrary.simpleMessage("استيراد"),
        "import_data_error": m5,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("نجح استيراد البيانات"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("مكرر"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "Click import button to import decrypted HTTPS response"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            "انقر على الخادم لإخفاء / إظهار"),
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
            MessageLookupByLibrary.simpleMessage("الإجمالي"),
        "info_cards": MessageLookupByLibrary.simpleMessage("بطاقات"),
        "info_critical_rate":
            MessageLookupByLibrary.simpleMessage("نسبة الكريتكال"),
        "info_cv": MessageLookupByLibrary.simpleMessage("مؤدي الأصوات"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("نسبة الموت"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("قدرة التحمل"),
        "info_luck": MessageLookupByLibrary.simpleMessage("الحظ"),
        "info_mana": MessageLookupByLibrary.simpleMessage("المانا"),
        "info_np": MessageLookupByLibrary.simpleMessage("الوهم النبيل"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("نسبة الشحن"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("نسبة النجوم"),
        "info_strength": MessageLookupByLibrary.simpleMessage("القوة"),
        "info_value": MessageLookupByLibrary.simpleMessage("قيمة"),
        "input_invalid_hint":
            MessageLookupByLibrary.simpleMessage("مدخلات غير صالحة"),
        "install": MessageLookupByLibrary.simpleMessage("تنصيب"),
        "interlude_and_rankup":
            MessageLookupByLibrary.simpleMessage("انترلود والرانك اب"),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"Files\" app/On My iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("مشاكل"),
        "item": MessageLookupByLibrary.simpleMessage("المواد"),
        "item_already_exist_hint": m6,
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
        "item_category_others": MessageLookupByLibrary.simpleMessage("أخرى"),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("قطعة"),
        "item_category_secret_gem":
            MessageLookupByLibrary.simpleMessage("جوهرة سحرية"),
        "item_category_silver":
            MessageLookupByLibrary.simpleMessage("مواد فضية"),
        "item_category_special":
            MessageLookupByLibrary.simpleMessage("مواد خاصة"),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("المواد"),
        "item_eff": MessageLookupByLibrary.simpleMessage("Item Eff"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "قبل التخطيط ، يمكنك تعيين العدد المتجاوز للعناصر (تستخدم فقط في تخطيط المهام المجانيه )"),
        "item_left": MessageLookupByLibrary.simpleMessage("متبقي"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("لا فري كويستز"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("أظهر المطلوبة فقط"),
        "item_own": MessageLookupByLibrary.simpleMessage("مملوك"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("المواد"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("الإجمالي"),
        "join_beta": MessageLookupByLibrary.simpleMessage("انضم للبيتا"),
        "jump_to": m7,
        "language": MessageLookupByLibrary.simpleMessage("عربي"),
        "language_en": MessageLookupByLibrary.simpleMessage("Arabic"),
        "level": MessageLookupByLibrary.simpleMessage("مستوى"),
        "limited_event": MessageLookupByLibrary.simpleMessage("أيفنت حصري"),
        "link": MessageLookupByLibrary.simpleMessage("رابط"),
        "list_end_hint": m8,
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
            MessageLookupByLibrary.simpleMessage("لم يتم تسجيل"),
        "login_username": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
        "login_username_error": MessageLookupByLibrary.simpleMessage(
            "لابد ان يحتوي اسم المستخدم على حروف وأرقام وان يبتدئ بحرف وألا يكون أقل من أربع خانات"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("ضغطة مطولة للحفط"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("حقيبة الحظ"),
        "lucky_bag_expectation_short":
            MessageLookupByLibrary.simpleMessage("EXP"),
        "lucky_bag_rating": MessageLookupByLibrary.simpleMessage("تقييم"),
        "lucky_bag_tooltip_unwanted":
            MessageLookupByLibrary.simpleMessage("الغير مطلوب"),
        "lucky_bag_tooltip_wanted":
            MessageLookupByLibrary.simpleMessage("المطلوب"),
        "main_quest": MessageLookupByLibrary.simpleMessage("المهام الرئيسية"),
        "main_story_chapter": MessageLookupByLibrary.simpleMessage("الفصل"),
        "master_mission": MessageLookupByLibrary.simpleMessage("مهام الماستر"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("مهام ذات صلة"),
        "master_mission_solution":
            MessageLookupByLibrary.simpleMessage("التسهيل"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("المهام"),
        "move_down": MessageLookupByLibrary.simpleMessage("تحرك لأسفل"),
        "move_up": MessageLookupByLibrary.simpleMessage("تحرك لأعلى"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("الميستك كود"),
        "network_settings":
            MessageLookupByLibrary.simpleMessage("اعدادت الشبكة"),
        "new_account": MessageLookupByLibrary.simpleMessage("حساب جديد"),
        "new_data_available":
            MessageLookupByLibrary.simpleMessage("بيانات جديدة متاحة"),
        "next_card": MessageLookupByLibrary.simpleMessage("التالي"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("لا يوجد رانك اب او مهمة"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("اضغط ♡ لعرض جميع مهام الخدم"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("الوهم النبيل"),
        "noble_phantasm_level":
            MessageLookupByLibrary.simpleMessage("الوهم النبيل"),
        "not_found": MessageLookupByLibrary.simpleMessage("غير موجود"),
        "not_implemented": MessageLookupByLibrary.simpleMessage("لم تنفذ بعد"),
        "np_charge": MessageLookupByLibrary.simpleMessage("NP شحن ال"),
        "np_gain_mod":
            MessageLookupByLibrary.simpleMessage("غير منتهية الصلاحية"),
        "np_short": MessageLookupByLibrary.simpleMessage("NP"),
        "obtain_time": MessageLookupByLibrary.simpleMessage("الوقت"),
        "ok": MessageLookupByLibrary.simpleMessage("موافق"),
        "open": MessageLookupByLibrary.simpleMessage("فتح"),
        "open_condition": MessageLookupByLibrary.simpleMessage("شرط"),
        "open_in_file_manager": MessageLookupByLibrary.simpleMessage(
            "رجاءا افتح باسخدام مدير الملفات"),
        "outdated": MessageLookupByLibrary.simpleMessage("منتهي الصلاحية"),
        "overview": MessageLookupByLibrary.simpleMessage("ملخص"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("باسيڨ سكل"),
        "plan": MessageLookupByLibrary.simpleMessage("الخطة"),
        "plan_list_set_all": MessageLookupByLibrary.simpleMessage("وضع الكل"),
        "plan_list_set_all_current":
            MessageLookupByLibrary.simpleMessage("الحالي"),
        "plan_list_set_all_target":
            MessageLookupByLibrary.simpleMessage("الهدف"),
        "plan_max10":
            MessageLookupByLibrary.simpleMessage("الحد الأقصى للخطة (310)"),
        "plan_max9":
            MessageLookupByLibrary.simpleMessage("الحد الاقصى للخطة (999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("هدف الخطة"),
        "plan_title": MessageLookupByLibrary.simpleMessage("الخطة"),
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("مهام التخطيط"),
        "preferred_translation_footer": MessageLookupByLibrary.simpleMessage(
            "اسحب لتغيير الأسبقية في اللغة المستخدمة في التوضيحات لبيانات اللعبة،اللغات الخمسة الرسمية غير متوفره بالكامل في بيانات اللعبة"),
        "preview": MessageLookupByLibrary.simpleMessage("عرض"),
        "previous_card": MessageLookupByLibrary.simpleMessage("السابق"),
        "priority": MessageLookupByLibrary.simpleMessage("أفضلية"),
        "priority_tagging_hint": MessageLookupByLibrary.simpleMessage(
            "يجب ألا تكون العلامات - تاغ - طويلة جدًا ، وإلا فلن يتم عرضها بالكامل"),
        "project_homepage":
            MessageLookupByLibrary.simpleMessage("الصفحة الرئيسية للمشروع"),
        "quest": MessageLookupByLibrary.simpleMessage("مهمة"),
        "quest_chapter_n": m9,
        "quest_condition": MessageLookupByLibrary.simpleMessage("الظروف"),
        "quest_detail_btn": MessageLookupByLibrary.simpleMessage("التفاصيل"),
        "rarity": MessageLookupByLibrary.simpleMessage("الندرة"),
        "rate_app_store":
            MessageLookupByLibrary.simpleMessage("قيمنا على آب ستور"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("قيمنا على متجر بلاي"),
        "region_cn": MessageLookupByLibrary.simpleMessage("الصينية"),
        "region_jp": MessageLookupByLibrary.simpleMessage("اليابانية"),
        "region_kr": MessageLookupByLibrary.simpleMessage("الكورية"),
        "region_na": MessageLookupByLibrary.simpleMessage("الأمريكية"),
        "region_notice": m10,
        "region_tw": MessageLookupByLibrary.simpleMessage("التايوانية"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("إزالة المكررة"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("إزالة من القائمة السوداء"),
        "rename": MessageLookupByLibrary.simpleMessage("إعادة التسمية"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("ري رن"),
        "reset": MessageLookupByLibrary.simpleMessage("إعادة"),
        "reset_plan_all": m11,
        "reset_plan_shown": m12,
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "أعد التشغيل للتحديث  إذا فشل التحديث ، يرجى نسخ مجلد المصدر يدويًا إلى الوجهة"),
        "restore": MessageLookupByLibrary.simpleMessage("إعادة"),
        "results": MessageLookupByLibrary.simpleMessage("النتائج"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("خطة ال SQ"),
        "save": MessageLookupByLibrary.simpleMessage("حفط"),
        "save_to_photos":
            MessageLookupByLibrary.simpleMessage("الحفظ في الصور"),
        "saved": MessageLookupByLibrary.simpleMessage("محفوظ"),
        "screen_size": MessageLookupByLibrary.simpleMessage("حجم الشاشة"),
        "screenshots": MessageLookupByLibrary.simpleMessage("لقطات الشاشة"),
        "search": MessageLookupByLibrary.simpleMessage("بحث"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("اساسي"),
        "search_options": MessageLookupByLibrary.simpleMessage("نطاق البحث"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("تحديد مصدر النسخ"),
        "select_item_title":
            MessageLookupByLibrary.simpleMessage("اختيار عنصر"),
        "select_lang": MessageLookupByLibrary.simpleMessage("اختيار اللغة"),
        "select_plan": MessageLookupByLibrary.simpleMessage("تحديد خطة"),
        "send_email_to":
            MessageLookupByLibrary.simpleMessage("إرسال البريد الى"),
        "sending": MessageLookupByLibrary.simpleMessage("جاري الإرسال"),
        "sending_failed": MessageLookupByLibrary.simpleMessage("فشل الإرسال"),
        "sent": MessageLookupByLibrary.simpleMessage("أُرسل"),
        "servant": MessageLookupByLibrary.simpleMessage("الخدم"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("عملة الخدم"),
        "servant_coin_short": MessageLookupByLibrary.simpleMessage("عملة"),
        "servant_detail_page":
            MessageLookupByLibrary.simpleMessage("صفحة تفاصيل الخادم"),
        "servant_list_page":
            MessageLookupByLibrary.simpleMessage("صفحة قائمة الخدم"),
        "set_plan_name":
            MessageLookupByLibrary.simpleMessage("اعداد اسم الخطة"),
        "setting_always_on_top":
            MessageLookupByLibrary.simpleMessage("دائما في الأعلى"),
        "setting_auto_rotate":
            MessageLookupByLibrary.simpleMessage("تدوير تلقائي"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage("الزر المفضل الافتراضي"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage(
                "عرض الحساب في الصفحة الرئيسية"),
        "setting_tabs_sorting":
            MessageLookupByLibrary.simpleMessage("تصنيف الصفحات"),
        "settings_data": MessageLookupByLibrary.simpleMessage("بيانات"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("المستندات"),
        "settings_general": MessageLookupByLibrary.simpleMessage("عام"),
        "settings_language": MessageLookupByLibrary.simpleMessage("اللغة"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "قم بعمل نسخة احتياطية قبل التحديث واحفظها خارج مجلدات التطبيق احتياطا"),
        "share": MessageLookupByLibrary.simpleMessage("مشاركة"),
        "shop": MessageLookupByLibrary.simpleMessage("المتاجر"),
        "show_frame_rate":
            MessageLookupByLibrary.simpleMessage("عرض نسبة الاطارات"),
        "show_fullscreen":
            MessageLookupByLibrary.simpleMessage("عرض ملئ الشاشة"),
        "show_outdated":
            MessageLookupByLibrary.simpleMessage("عرض المنتهى منه"),
        "silver": MessageLookupByLibrary.simpleMessage("فضي"),
        "simulator": MessageLookupByLibrary.simpleMessage("المحاكي"),
        "skill": MessageLookupByLibrary.simpleMessage("مهارة"),
        "skill_up": MessageLookupByLibrary.simpleMessage("رفع المهارة"),
        "skilled_max10":
            MessageLookupByLibrary.simpleMessage("المهارات القصوى (310)"),
        "sort_order": MessageLookupByLibrary.simpleMessage("التصنيف"),
        "sprites": MessageLookupByLibrary.simpleMessage("الأرواح"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("احصائيات"),
        "still_send": MessageLookupByLibrary.simpleMessage("أرسل على اي حال"),
        "success": MessageLookupByLibrary.simpleMessage("نجاح"),
        "summon": MessageLookupByLibrary.simpleMessage("استدعاء"),
        "summon_daily": MessageLookupByLibrary.simpleMessage("استدعاء"),
        "summon_expectation_btn": MessageLookupByLibrary.simpleMessage("يومي"),
        "summon_gacha_result": MessageLookupByLibrary.simpleMessage("النتائج"),
        "summon_show_banner":
            MessageLookupByLibrary.simpleMessage("عرض البانر"),
        "summon_ticket_short": MessageLookupByLibrary.simpleMessage("تكت"),
        "support_chaldea":
            MessageLookupByLibrary.simpleMessage("الدعم والتبرعات"),
        "svt_ascension_icon":
            MessageLookupByLibrary.simpleMessage("ايقونه الاسينشن"),
        "svt_basic_info": MessageLookupByLibrary.simpleMessage("عن"),
        "svt_class": MessageLookupByLibrary.simpleMessage("الكلاس"),
        "svt_class_filter_auto": MessageLookupByLibrary.simpleMessage("تلقائي"),
        "svt_class_filter_hide": MessageLookupByLibrary.simpleMessage("مخفي"),
        "svt_fav_btn_remember": MessageLookupByLibrary.simpleMessage("تذكير"),
        "svt_fav_btn_show_all":
            MessageLookupByLibrary.simpleMessage("عرض الكل"),
        "svt_fav_btn_show_favorite":
            MessageLookupByLibrary.simpleMessage("عرض المفضلة"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("غير مفضل"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("مخفي"),
        "svt_profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
        "svt_profile_info":
            MessageLookupByLibrary.simpleMessage("معلومات الملف الشخصي"),
        "svt_profile_n": m13,
        "svt_related_ce":
            MessageLookupByLibrary.simpleMessage("بطاقات كرافت ذات صلة"),
        "svt_reset_plan":
            MessageLookupByLibrary.simpleMessage("إعادة ضبط الخطة"),
        "svt_second_archive":
            MessageLookupByLibrary.simpleMessage("الارشيف الثاني"),
        "svt_stat_own_total":
            MessageLookupByLibrary.simpleMessage("(999) مملوك / الكلي"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("تبديل الشرائح /المهابط"),
        "switch_region": MessageLookupByLibrary.simpleMessage("تغيير المنطقة"),
        "testing": MessageLookupByLibrary.simpleMessage("يختبر"),
        "time_close": MessageLookupByLibrary.simpleMessage("اغلق"),
        "time_end": MessageLookupByLibrary.simpleMessage("نهاية"),
        "time_start": MessageLookupByLibrary.simpleMessage("بداية"),
        "toggle_dark_mode":
            MessageLookupByLibrary.simpleMessage("بدل الى الوضع المظلم"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("تحديث الشرائح"),
        "total_ap": MessageLookupByLibrary.simpleMessage("الاي بي الكلي"),
        "total_counts": MessageLookupByLibrary.simpleMessage("الحساب النهائي"),
        "trait": MessageLookupByLibrary.simpleMessage("علامة"),
        "update": MessageLookupByLibrary.simpleMessage("تحديث"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("النسخة الاعلي مسبقا"),
        "update_dataset":
            MessageLookupByLibrary.simpleMessage("تحديث حزمة البيانات"),
        "upload": MessageLookupByLibrary.simpleMessage("رفع"),
        "userdata": MessageLookupByLibrary.simpleMessage("بيانات المستخدم"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("تحميل نسخة احتياطية"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("اختر نسخة احتياطية"),
        "userdata_sync":
            MessageLookupByLibrary.simpleMessage("مزامنة البيانات"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("رفع نسخة احتياطية"),
        "valentine_craft":
            MessageLookupByLibrary.simpleMessage("كرافت عيد الحب"),
        "version": MessageLookupByLibrary.simpleMessage("النسخة"),
        "view_illustration":
            MessageLookupByLibrary.simpleMessage("عرض الرسومية"),
        "voice": MessageLookupByLibrary.simpleMessage("صوت"),
        "war": MessageLookupByLibrary.simpleMessage("الحروب"),
        "war_age": MessageLookupByLibrary.simpleMessage("العصر"),
        "war_banner": MessageLookupByLibrary.simpleMessage("البانر"),
        "warning": MessageLookupByLibrary.simpleMessage("تحذير"),
        "words_separate": m14
      };
}
