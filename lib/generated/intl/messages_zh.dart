// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m1(curVersion, newVersion, releaseNote) =>
      "当前版本: ${curVersion}\n最新版本: ${newVersion}\n更新内容:\n${releaseNote}";

  static String m2(url) =>
      "Chaldea——一款跨平台的Fate/GO素材规划客户端，支持游戏信息浏览、从者练度/活动/素材规划、周常规划、抽卡模拟器等功能。\n\n详情请见: \n${url}\n";

  static String m3(version) => "App版本需不低于${version}";

  static String m4(n) => "最多${n}池";

  static String m5(n) => "圣杯替换为传承结晶 ${n} 个";

  static String m6(filename, hash, localHash) =>
      "文件${filename}未找到或错误: ${hash} - ${localHash}";

  static String m7(error) => "导入失败:\n${error}";

  static String m8(name) => "${name}已存在";

  static String m9(site) => "跳转到${site}";

  static String m10(shown, total) => "显示${shown}/总计${total}";

  static String m11(shown, ignore, total) =>
      "显示${shown}/忽略${ignore}/总计${total}";

  static String m12(first) => "${Intl.select(first, {
            'true': '已经是第一张',
            'false': '已经是最后一张',
            'other': '已经到头了',
          })}";

  static String m13(n) => "重置规划${n}(所有)";

  static String m14(n) => "重置规划${n}(已显示)";

  static String m15(battles, ap) => "总计${battles}次战斗, ${ap} AP";

  static String m0(a, b) => "${a}${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("关于"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "　本应用所使用数据均来源于游戏及以下网站，游戏图片文本原文等版权属于TYPE MOON/FGO PROJECT。\n　程序功能与界面设计参考微信小程序\"素材规划\"以及iOS版Guda。"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("数据来源"),
        "about_data_source_footer":
            MessageLookupByLibrary.simpleMessage("若存在未标注的来源或侵权敬请告知"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("反馈"),
        "about_update_app_detail": m1,
        "account_title": MessageLookupByLibrary.simpleMessage("账户"),
        "active_skill": MessageLookupByLibrary.simpleMessage("保有技能"),
        "add": MessageLookupByLibrary.simpleMessage("添加"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("请填写反馈内容"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("加入黑名单"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP效率"),
        "append_skill": MessageLookupByLibrary.simpleMessage("附加技能"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("附加"),
        "ascension": MessageLookupByLibrary.simpleMessage("灵基"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("灵基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("灵基再临"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("从文件选取"),
        "attach_from_photos": MessageLookupByLibrary.simpleMessage("从相册选取"),
        "attach_help":
            MessageLookupByLibrary.simpleMessage("如果图片模式存在问题，请使用文件模式"),
        "attachment": MessageLookupByLibrary.simpleMessage("附件"),
        "auto_reset": MessageLookupByLibrary.simpleMessage("自动重置"),
        "auto_update": MessageLookupByLibrary.simpleMessage("自动更新"),
        "backup": MessageLookupByLibrary.simpleMessage("备份"),
        "backup_failed": MessageLookupByLibrary.simpleMessage("备份失败"),
        "backup_history": MessageLookupByLibrary.simpleMessage("历史备份"),
        "blacklist": MessageLookupByLibrary.simpleMessage("黑名单"),
        "bond": MessageLookupByLibrary.simpleMessage("羁绊"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("羁绊礼装"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("羁绊效率"),
        "bootstrap_page_title": MessageLookupByLibrary.simpleMessage("引导页"),
        "bronze": MessageLookupByLibrary.simpleMessage("铜"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("权重"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "card_description": MessageLookupByLibrary.simpleMessage("解说"),
        "card_info": MessageLookupByLibrary.simpleMessage("资料"),
        "card_name": MessageLookupByLibrary.simpleMessage("卡牌名称"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("轮播设置"),
        "chaldea_account": MessageLookupByLibrary.simpleMessage("Chaldea账号"),
        "chaldea_account_system_hint": MessageLookupByLibrary.simpleMessage(
            "  一个简易的用于数据备份及多设备同步的账户系统。\n  没有安全性保障，请不要设置常用密码！\n  若不需要上述功能，则无需注册。"),
        "chaldea_backup": MessageLookupByLibrary.simpleMessage("Chaldea应用备份"),
        "chaldea_share_msg": m2,
        "change_log": MessageLookupByLibrary.simpleMessage("更新历史"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("出场角色"),
        "check_update": MessageLookupByLibrary.simpleMessage("检查更新"),
        "clear": MessageLookupByLibrary.simpleMessage("清空"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("清除缓存"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage("缓存已清理"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("包括卡面语音等"),
        "clear_data": MessageLookupByLibrary.simpleMessage("清除数据"),
        "coin_summon_num": MessageLookupByLibrary.simpleMessage("召唤所得"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令纹章"),
        "confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "consumed": MessageLookupByLibrary.simpleMessage("已消耗"),
        "contact_information_not_filled":
            MessageLookupByLibrary.simpleMessage("联系方式未填写"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage("将无法无法无法无法无法回复您的问题"),
        "copied": MessageLookupByLibrary.simpleMessage("已复制"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("拷贝自其它规划"),
        "costume": MessageLookupByLibrary.simpleMessage("灵衣"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("灵衣开放"),
        "counts": MessageLookupByLibrary.simpleMessage("计数"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "create_account_textfield_helper":
            MessageLookupByLibrary.simpleMessage("稍后在设置中可以添加更多游戏账号"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("生成2号机"),
        "cur_account": MessageLookupByLibrary.simpleMessage("当前账号"),
        "current_": MessageLookupByLibrary.simpleMessage("当前"),
        "current_version": MessageLookupByLibrary.simpleMessage("当前版本"),
        "custom_mission": MessageLookupByLibrary.simpleMessage("自定义任务"),
        "custom_mission_nothing_hint":
            MessageLookupByLibrary.simpleMessage("无任务，点击+添加"),
        "custom_mission_source_mission":
            MessageLookupByLibrary.simpleMessage("源任务"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("深色模式"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("深色"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("浅色"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("系统"),
        "database": MessageLookupByLibrary.simpleMessage("数据库"),
        "database_not_downloaded":
            MessageLookupByLibrary.simpleMessage("数据库未下载，仍然继续?"),
        "dataset_version": MessageLookupByLibrary.simpleMessage("数据版本"),
        "date": MessageLookupByLibrary.simpleMessage("日期"),
        "debug": MessageLookupByLibrary.simpleMessage("Debug"),
        "debug_fab": MessageLookupByLibrary.simpleMessage("Debug FAB"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("Debug Menu"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "demands": MessageLookupByLibrary.simpleMessage("需求"),
        "display_setting": MessageLookupByLibrary.simpleMessage("显示设置"),
        "done": MessageLookupByLibrary.simpleMessage("完成"),
        "download": MessageLookupByLibrary.simpleMessage("下载"),
        "download_icons": MessageLookupByLibrary.simpleMessage("下载图标"),
        "download_latest_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("为确保兼容性，更新前请升级至最新版APP"),
        "download_source": MessageLookupByLibrary.simpleMessage("下载源"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("大陆地区请选择CN节点"),
        "downloaded": MessageLookupByLibrary.simpleMessage("已下载"),
        "downloading": MessageLookupByLibrary.simpleMessage("下载中"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("点击 + 添加素材"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("最低AP"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("求解"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("掉率"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "effect_search": MessageLookupByLibrary.simpleMessage("Buff检索"),
        "efficiency": MessageLookupByLibrary.simpleMessage("效率"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("效率类型"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP效率"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("每场掉率"),
        "email": MessageLookupByLibrary.simpleMessage("邮箱"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("敌人一览"),
        "enhance": MessageLookupByLibrary.simpleMessage("强化"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage("强化将扣除以下素材"),
        "error_no_internet": MessageLookupByLibrary.simpleMessage("无网络连接"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("没有网络连接"),
        "error_no_version_data_found":
            MessageLookupByLibrary.simpleMessage("未找到数据文件"),
        "error_required_app_version": m3,
        "event_collect_item_confirm":
            MessageLookupByLibrary.simpleMessage("所有素材添加到素材仓库，并将该活动移出规划"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("收取素材"),
        "event_item_extra": MessageLookupByLibrary.simpleMessage("额外可获取素材"),
        "event_lottery": MessageLookupByLibrary.simpleMessage("奖池"),
        "event_lottery_limit_hint": m4,
        "event_lottery_limited": MessageLookupByLibrary.simpleMessage("有限池"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("池"),
        "event_lottery_unlimited": MessageLookupByLibrary.simpleMessage("无限池"),
        "event_not_planned": MessageLookupByLibrary.simpleMessage("活动未列入规划"),
        "event_point_reward": MessageLookupByLibrary.simpleMessage("点数"),
        "event_progress": MessageLookupByLibrary.simpleMessage("进度"),
        "event_quest": MessageLookupByLibrary.simpleMessage("活动关卡"),
        "event_rerun_replace_grail": m5,
        "event_shop": MessageLookupByLibrary.simpleMessage("商店"),
        "event_title": MessageLookupByLibrary.simpleMessage("活动"),
        "event_tower": MessageLookupByLibrary.simpleMessage("塔"),
        "event_treasure_box": MessageLookupByLibrary.simpleMessage("宝箱"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交换券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交换券"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("等级规划"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("相同职阶"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("狗粮需求"),
        "failed": MessageLookupByLibrary.simpleMessage("失败"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("关注"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("e.g. 截图等文件"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("联系方式"),
        "feedback_content_hint": MessageLookupByLibrary.simpleMessage("反馈与建议"),
        "feedback_form_alert":
            MessageLookupByLibrary.simpleMessage("反馈表未提交，仍然退出?"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "提交反馈前，请先查阅<**FAQ**>。反馈时请详细描述:\n- 如何复现/期望表现\n- 应用/数据版本、使用设备系统及版本\n- 附加截图日志\n- 以及最好能够提供联系方式(邮箱等)"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("发送"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("主题"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("背景"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("身体"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("裁剪"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("头部"),
        "ffo_missing_data_hint":
            MessageLookupByLibrary.simpleMessage("请先下载或导入FFO资源包↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("同一从者"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("效率剧场"),
        "file_not_found_or_mismatched_hash": m6,
        "filename": MessageLookupByLibrary.simpleMessage("文件名"),
        "fill_email_warning": MessageLookupByLibrary.simpleMessage(
            "建议填写邮件联系方式，否则将无法得到回复！！！请勿填写QQ/微信/手机号！"),
        "filter": MessageLookupByLibrary.simpleMessage("筛选"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("属性"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("阵营"),
        "filter_category": MessageLookupByLibrary.simpleMessage("分类"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("效果"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("全匹配"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("获取方式"),
        "filter_plan_not_reached": MessageLookupByLibrary.simpleMessage("未满"),
        "filter_plan_reached": MessageLookupByLibrary.simpleMessage("已满"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("反向匹配"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("显示"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("技能练度"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("排序"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("职阶"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("序号"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("星级"),
        "foukun": MessageLookupByLibrary.simpleMessage("芙芙"),
        "free_progress": MessageLookupByLibrary.simpleMessage("Free进度"),
        "free_progress_newest": MessageLookupByLibrary.simpleMessage("日服最新"),
        "free_quest": MessageLookupByLibrary.simpleMessage("Free本"),
        "free_quest_calculator": MessageLookupByLibrary.simpleMessage("Free速查"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("Free速查"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("首页"),
        "game_account": MessageLookupByLibrary.simpleMessage("游戏账号"),
        "game_data_not_found":
            MessageLookupByLibrary.simpleMessage("未加载数据包，请先前往游戏数据页面下载"),
        "game_drop": MessageLookupByLibrary.simpleMessage("掉落"),
        "game_experience": MessageLookupByLibrary.simpleMessage("经验"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("羁绊"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("通关奖励"),
        "game_server": MessageLookupByLibrary.simpleMessage("服务器"),
        "gamedata": MessageLookupByLibrary.simpleMessage("游戏数据"),
        "general_default": MessageLookupByLibrary.simpleMessage("默认"),
        "general_others": MessageLookupByLibrary.simpleMessage("其他"),
        "general_type": MessageLookupByLibrary.simpleMessage("类型"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("圣杯"),
        "grail_up": MessageLookupByLibrary.simpleMessage("圣杯转临"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("成长曲线"),
        "guda_female": MessageLookupByLibrary.simpleMessage("咕哒子"),
        "guda_male": MessageLookupByLibrary.simpleMessage("咕哒夫"),
        "help": MessageLookupByLibrary.simpleMessage("帮助"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("隐藏已过期"),
        "http_sniff_hint":
            MessageLookupByLibrary.simpleMessage("(国/台/日/美)账号登陆时的数据"),
        "https_sniff": MessageLookupByLibrary.simpleMessage("Https抓包"),
        "hunting_quest": MessageLookupByLibrary.simpleMessage("狩猎关卡"),
        "icons": MessageLookupByLibrary.simpleMessage("图标"),
        "ignore": MessageLookupByLibrary.simpleMessage("忽略"),
        "illustration": MessageLookupByLibrary.simpleMessage("卡面"),
        "illustrator": MessageLookupByLibrary.simpleMessage("画师"),
        "import_active_skill_hint":
            MessageLookupByLibrary.simpleMessage("强化 - 从者技能强化"),
        "import_active_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("主动技能截图解析"),
        "import_append_skill_hint":
            MessageLookupByLibrary.simpleMessage("强化 - 被动技能强化"),
        "import_append_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("附加技能截图解析"),
        "import_backup": MessageLookupByLibrary.simpleMessage("导入备份"),
        "import_data": MessageLookupByLibrary.simpleMessage("导入"),
        "import_data_error": m7,
        "import_data_success": MessageLookupByLibrary.simpleMessage("成功导入数据"),
        "import_from_clipboard": MessageLookupByLibrary.simpleMessage("从剪切板"),
        "import_from_file": MessageLookupByLibrary.simpleMessage("从文件"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("允许2号机"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "点击右上角导入解密的HTTPS响应包以导入账户数据\n点击帮助以查看如何捕获并解密HTTPS响应内容"),
        "import_http_body_hint_hide":
            MessageLookupByLibrary.simpleMessage("点击从者可隐藏/取消隐藏该从者"),
        "import_http_body_locked": MessageLookupByLibrary.simpleMessage("仅锁定"),
        "import_image": MessageLookupByLibrary.simpleMessage("导入图片"),
        "import_item_hint": MessageLookupByLibrary.simpleMessage("个人空间 - 道具一览"),
        "import_item_screenshots":
            MessageLookupByLibrary.simpleMessage("素材截图解析"),
        "import_screenshot": MessageLookupByLibrary.simpleMessage("导入截图"),
        "import_screenshot_hint":
            MessageLookupByLibrary.simpleMessage("仅更新识别出的素材"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("更新素材"),
        "import_source_file": MessageLookupByLibrary.simpleMessage("导入源数据"),
        "import_userdata_more": MessageLookupByLibrary.simpleMessage("更多导入方式"),
        "info_agility": MessageLookupByLibrary.simpleMessage("敏捷"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("属性"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("羁绊点数"),
        "info_bond_points_single": MessageLookupByLibrary.simpleMessage("点数"),
        "info_bond_points_sum": MessageLookupByLibrary.simpleMessage("累积"),
        "info_cards": MessageLookupByLibrary.simpleMessage("配卡"),
        "info_critical_rate": MessageLookupByLibrary.simpleMessage("暴击权重"),
        "info_cv": MessageLookupByLibrary.simpleMessage("声优"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("即死率"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("耐久"),
        "info_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "info_luck": MessageLookupByLibrary.simpleMessage("幸运"),
        "info_mana": MessageLookupByLibrary.simpleMessage("魔力"),
        "info_np": MessageLookupByLibrary.simpleMessage("宝具"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP获得率"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("出星率"),
        "info_strength": MessageLookupByLibrary.simpleMessage("筋力"),
        "info_trait": MessageLookupByLibrary.simpleMessage("特性"),
        "info_value": MessageLookupByLibrary.simpleMessage("数值"),
        "input_invalid_hint": MessageLookupByLibrary.simpleMessage("输入无效"),
        "install": MessageLookupByLibrary.simpleMessage("安装"),
        "interlude": MessageLookupByLibrary.simpleMessage("幕间物语"),
        "interlude_and_rankup": MessageLookupByLibrary.simpleMessage("幕间&强化"),
        "invalid_input": MessageLookupByLibrary.simpleMessage("无效输入"),
        "invalid_startup_path": MessageLookupByLibrary.simpleMessage("无效启动路径!"),
        "invalid_startup_path_info": MessageLookupByLibrary.simpleMessage(
            "请解压文件至非系统目录再重新启动应用。\"C:\\\", \"C:\\Program Files\"等路径为无效路径."),
        "ios_app_path":
            MessageLookupByLibrary.simpleMessage("\"文件\"应用/我的iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("常见问题"),
        "item": MessageLookupByLibrary.simpleMessage("素材"),
        "item_already_exist_hint": m8,
        "item_apple": MessageLookupByLibrary.simpleMessage("苹果"),
        "item_category_ascension": MessageLookupByLibrary.simpleMessage("职阶棋子"),
        "item_category_bronze": MessageLookupByLibrary.simpleMessage("铜素材"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("活动从者灵基再临素材"),
        "item_category_gem": MessageLookupByLibrary.simpleMessage("辉石"),
        "item_category_gems": MessageLookupByLibrary.simpleMessage("技能石"),
        "item_category_gold": MessageLookupByLibrary.simpleMessage("金素材"),
        "item_category_magic_gem": MessageLookupByLibrary.simpleMessage("魔石"),
        "item_category_monument": MessageLookupByLibrary.simpleMessage("金像"),
        "item_category_others": MessageLookupByLibrary.simpleMessage("其他"),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("银棋"),
        "item_category_secret_gem": MessageLookupByLibrary.simpleMessage("秘石"),
        "item_category_silver": MessageLookupByLibrary.simpleMessage("银素材"),
        "item_category_special": MessageLookupByLibrary.simpleMessage("特殊素材"),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("普通素材"),
        "item_eff": MessageLookupByLibrary.simpleMessage("素材效率"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "计算规划前，可以设置不同材料的富余量(仅用于Free本规划)"),
        "item_left": MessageLookupByLibrary.simpleMessage("剩余"),
        "item_no_free_quests": MessageLookupByLibrary.simpleMessage("无Free本"),
        "item_only_show_lack": MessageLookupByLibrary.simpleMessage("仅显示不足"),
        "item_own": MessageLookupByLibrary.simpleMessage("拥有"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("素材截图"),
        "item_title": MessageLookupByLibrary.simpleMessage("素材"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("共需"),
        "join_beta": MessageLookupByLibrary.simpleMessage("加入Beta版"),
        "jump_to": m9,
        "language": MessageLookupByLibrary.simpleMessage("简体中文"),
        "language_en": MessageLookupByLibrary.simpleMessage("Chinese"),
        "level": MessageLookupByLibrary.simpleMessage("等级"),
        "limited_event": MessageLookupByLibrary.simpleMessage("限时活动"),
        "link": MessageLookupByLibrary.simpleMessage("链接"),
        "list_count_shown_all": m10,
        "list_count_shown_hidden_all": m11,
        "list_end_hint": m12,
        "login_change_name": MessageLookupByLibrary.simpleMessage("修改用户名"),
        "login_change_password": MessageLookupByLibrary.simpleMessage("修改密码"),
        "login_confirm_password": MessageLookupByLibrary.simpleMessage("确认密码"),
        "login_first_hint": MessageLookupByLibrary.simpleMessage("请先登陆"),
        "login_forget_pwd": MessageLookupByLibrary.simpleMessage("忘记密码"),
        "login_login": MessageLookupByLibrary.simpleMessage("登陆"),
        "login_logout": MessageLookupByLibrary.simpleMessage("登出"),
        "login_new_name": MessageLookupByLibrary.simpleMessage("新用户名"),
        "login_new_password": MessageLookupByLibrary.simpleMessage("新密码"),
        "login_password": MessageLookupByLibrary.simpleMessage("密码"),
        "login_password_error":
            MessageLookupByLibrary.simpleMessage("6-18位字母和数字，至少包含一个字母"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage("不能与旧密码相同"),
        "login_signup": MessageLookupByLibrary.simpleMessage("注册"),
        "login_state_not_login": MessageLookupByLibrary.simpleMessage("未登录"),
        "login_username": MessageLookupByLibrary.simpleMessage("用户名"),
        "login_username_error":
            MessageLookupByLibrary.simpleMessage("只能包含字母与数字，字母开头，不少于4位"),
        "long_press_to_save_hint": MessageLookupByLibrary.simpleMessage("长按保存"),
        "lottery_cost_per_roll": MessageLookupByLibrary.simpleMessage("每抽消耗"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("福袋"),
        "main_quest": MessageLookupByLibrary.simpleMessage("主线关卡"),
        "main_record": MessageLookupByLibrary.simpleMessage("主线记录"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("章节"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Master-Detail width"),
        "master_mission": MessageLookupByLibrary.simpleMessage("御主任务"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("关联关卡"),
        "master_mission_solution": MessageLookupByLibrary.simpleMessage("方案"),
        "master_mission_tasklist": MessageLookupByLibrary.simpleMessage("任务列表"),
        "master_mission_weekly": MessageLookupByLibrary.simpleMessage("周常任务"),
        "mission": MessageLookupByLibrary.simpleMessage("任务"),
        "move_down": MessageLookupByLibrary.simpleMessage("下移"),
        "move_up": MessageLookupByLibrary.simpleMessage("上移"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("魔术礼装"),
        "new_account": MessageLookupByLibrary.simpleMessage("新建账号"),
        "next_card": MessageLookupByLibrary.simpleMessage("下一张"),
        "next_page": MessageLookupByLibrary.simpleMessage("下一页"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("无幕间或强化关卡"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("点击♡查看所有从者任务"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("宝具"),
        "noble_phantasm_level": MessageLookupByLibrary.simpleMessage("宝具等级"),
        "not_found": MessageLookupByLibrary.simpleMessage("Not Found"),
        "not_implemented": MessageLookupByLibrary.simpleMessage("尚未实现"),
        "not_outdated": MessageLookupByLibrary.simpleMessage("未过期"),
        "np_short": MessageLookupByLibrary.simpleMessage("宝具"),
        "obtain_time": MessageLookupByLibrary.simpleMessage("时间"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "open": MessageLookupByLibrary.simpleMessage("打开"),
        "open_condition": MessageLookupByLibrary.simpleMessage("开发条件"),
        "open_in_file_manager":
            MessageLookupByLibrary.simpleMessage("请用文件管理器打开"),
        "outdated": MessageLookupByLibrary.simpleMessage("已过期"),
        "overview": MessageLookupByLibrary.simpleMessage("概览"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("被动技能"),
        "plan": MessageLookupByLibrary.simpleMessage("规划"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("规划最大化(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("规划最大化(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("规划目标"),
        "plan_title": MessageLookupByLibrary.simpleMessage("规划"),
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("规划Free本"),
        "preferred_translation": MessageLookupByLibrary.simpleMessage("首选翻译"),
        "preferred_translation_footer": MessageLookupByLibrary.simpleMessage(
            "拖动以更改顺序。\n用于游戏数据的显示而非应用UI语言。部分语言存在未翻译的部分。"),
        "prev_page": MessageLookupByLibrary.simpleMessage("上一页"),
        "preview": MessageLookupByLibrary.simpleMessage("预览"),
        "previous_card": MessageLookupByLibrary.simpleMessage("上一张"),
        "priority": MessageLookupByLibrary.simpleMessage("优先级"),
        "project_homepage": MessageLookupByLibrary.simpleMessage("项目主页"),
        "quest": MessageLookupByLibrary.simpleMessage("关卡"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("开放条件"),
        "quest_fixed_drop": MessageLookupByLibrary.simpleMessage("固定掉落"),
        "quest_fixed_drop_short": MessageLookupByLibrary.simpleMessage("掉落"),
        "quest_reward": MessageLookupByLibrary.simpleMessage("通关奖励"),
        "quest_reward_short": MessageLookupByLibrary.simpleMessage("奖励"),
        "rarity": MessageLookupByLibrary.simpleMessage("稀有度"),
        "rate_app_store": MessageLookupByLibrary.simpleMessage("App Store评分"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Google Play评分"),
        "remove_duplicated_svt": MessageLookupByLibrary.simpleMessage("销毁2号机"),
        "remove_from_blacklist": MessageLookupByLibrary.simpleMessage("移出黑名单"),
        "rename": MessageLookupByLibrary.simpleMessage("重命名"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("复刻活动"),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "reset_plan_all": m13,
        "reset_plan_shown": m14,
        "restart_to_apply_changes":
            MessageLookupByLibrary.simpleMessage("重启以使配置生效"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "重启以更新应用，若更新失败，请手动复制source文件夹到destination"),
        "restore": MessageLookupByLibrary.simpleMessage("恢复"),
        "results": MessageLookupByLibrary.simpleMessage("结果"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("攒石"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("保存到相册"),
        "saved": MessageLookupByLibrary.simpleMessage("已保存"),
        "screen_size": MessageLookupByLibrary.simpleMessage("屏幕尺寸"),
        "screenshots": MessageLookupByLibrary.simpleMessage("截图"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("基础信息"),
        "search_options": MessageLookupByLibrary.simpleMessage("搜索范围"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("选择复制来源"),
        "select_lang": MessageLookupByLibrary.simpleMessage("选择语言"),
        "select_plan": MessageLookupByLibrary.simpleMessage("选择规划"),
        "send_email_to": MessageLookupByLibrary.simpleMessage("发送邮件到"),
        "sending": MessageLookupByLibrary.simpleMessage("正在发送..."),
        "sending_failed": MessageLookupByLibrary.simpleMessage("发送失败"),
        "sent": MessageLookupByLibrary.simpleMessage("已发送"),
        "servant": MessageLookupByLibrary.simpleMessage("从者"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("从者硬币"),
        "servant_coin_short": MessageLookupByLibrary.simpleMessage("硬币"),
        "servant_detail_page": MessageLookupByLibrary.simpleMessage("从者详情页"),
        "servant_list_page": MessageLookupByLibrary.simpleMessage("从者列表页"),
        "servant_title": MessageLookupByLibrary.simpleMessage("从者"),
        "set_plan_name": MessageLookupByLibrary.simpleMessage("设置规划名称"),
        "setting_always_on_top": MessageLookupByLibrary.simpleMessage("置顶显示"),
        "setting_auto_rotate": MessageLookupByLibrary.simpleMessage("自动旋转"),
        "setting_auto_turn_on_plan_not_reach":
            MessageLookupByLibrary.simpleMessage("默认显示\"规划未满\""),
        "setting_home_plan_list_page":
            MessageLookupByLibrary.simpleMessage("首页-规划列表页"),
        "setting_only_change_second_append_skill":
            MessageLookupByLibrary.simpleMessage("仅更改附加技能2"),
        "setting_priority_tagging":
            MessageLookupByLibrary.simpleMessage("优先级备注"),
        "setting_servant_class_filter_style":
            MessageLookupByLibrary.simpleMessage("从者职阶筛选样式"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage("「关注」按钮默认筛选"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage("首页显示当前账号"),
        "setting_tabs_sorting": MessageLookupByLibrary.simpleMessage("标签页排序"),
        "settings_data": MessageLookupByLibrary.simpleMessage("数据"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("使用文档"),
        "settings_general": MessageLookupByLibrary.simpleMessage("通用"),
        "settings_language": MessageLookupByLibrary.simpleMessage("语言"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("设置"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "show_frame_rate": MessageLookupByLibrary.simpleMessage("显示刷新率"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("显示已过期"),
        "silver": MessageLookupByLibrary.simpleMessage("银"),
        "simulator": MessageLookupByLibrary.simpleMessage("模拟器"),
        "skill": MessageLookupByLibrary.simpleMessage("技能"),
        "skill_up": MessageLookupByLibrary.simpleMessage("技能升级"),
        "skilled_max10": MessageLookupByLibrary.simpleMessage("练度最大化(310)"),
        "solution_battle_count": MessageLookupByLibrary.simpleMessage("次数"),
        "solution_target_count": MessageLookupByLibrary.simpleMessage("目标数"),
        "solution_total_battles_ap": m15,
        "sort_order": MessageLookupByLibrary.simpleMessage("排序"),
        "sprites": MessageLookupByLibrary.simpleMessage("模型"),
        "sq_fragment_convert":
            MessageLookupByLibrary.simpleMessage("21圣晶片=3圣晶石"),
        "sq_short": MessageLookupByLibrary.simpleMessage("石"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("统计"),
        "still_send": MessageLookupByLibrary.simpleMessage("仍然发送"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "summon": MessageLookupByLibrary.simpleMessage("卡池"),
        "summon_daily": MessageLookupByLibrary.simpleMessage("日替"),
        "summon_show_banner": MessageLookupByLibrary.simpleMessage("显示横幅"),
        "summon_ticket_short": MessageLookupByLibrary.simpleMessage("呼符"),
        "summon_title": MessageLookupByLibrary.simpleMessage("卡池一览"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("支持与捐赠"),
        "svt_ascension_icon": MessageLookupByLibrary.simpleMessage("从者头像"),
        "svt_basic_info": MessageLookupByLibrary.simpleMessage("资料"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("未关注"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("已隐藏"),
        "svt_profile": MessageLookupByLibrary.simpleMessage("羁绊故事"),
        "svt_related_ce": MessageLookupByLibrary.simpleMessage("关联礼装"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("重置规划"),
        "svt_second_archive": MessageLookupByLibrary.simpleMessage("保管室"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("切换滑动条/下拉框"),
        "test_info_pad": MessageLookupByLibrary.simpleMessage("测试信息"),
        "testing": MessageLookupByLibrary.simpleMessage("测试ing"),
        "time_close": MessageLookupByLibrary.simpleMessage("关闭"),
        "time_end": MessageLookupByLibrary.simpleMessage("结束"),
        "time_start": MessageLookupByLibrary.simpleMessage("开始"),
        "toogle_dark_mode": MessageLookupByLibrary.simpleMessage("切换深色模式"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("刷新轮播图"),
        "total_ap": MessageLookupByLibrary.simpleMessage("总AP"),
        "total_counts": MessageLookupByLibrary.simpleMessage("总数"),
        "treasure_box_draw_cost": MessageLookupByLibrary.simpleMessage("每抽消耗"),
        "treasure_box_extra_gift":
            MessageLookupByLibrary.simpleMessage("每箱额外礼物"),
        "treasure_box_max_draw_once":
            MessageLookupByLibrary.simpleMessage("单次最多抽数"),
        "update": MessageLookupByLibrary.simpleMessage("更新"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("已经是最新版本"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("更新数据包"),
        "update_msg_error": MessageLookupByLibrary.simpleMessage("更新失败"),
        "update_msg_no_update": MessageLookupByLibrary.simpleMessage("无可用更新"),
        "update_msg_succuss": MessageLookupByLibrary.simpleMessage("已更新"),
        "upload": MessageLookupByLibrary.simpleMessage("上传"),
        "usage": MessageLookupByLibrary.simpleMessage("使用方法"),
        "userdata": MessageLookupByLibrary.simpleMessage("用户数据"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("下载备份"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("选择一个备份"),
        "userdata_sync": MessageLookupByLibrary.simpleMessage("同步数据"),
        "userdata_upload_backup": MessageLookupByLibrary.simpleMessage("上传备份"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("情人节礼装"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("查看卡面"),
        "voice": MessageLookupByLibrary.simpleMessage("语音"),
        "warning": MessageLookupByLibrary.simpleMessage("警告"),
        "web_renderer": MessageLookupByLibrary.simpleMessage("Web渲染器"),
        "words_separate": m0
      };
}
