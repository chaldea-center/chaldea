// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static m0(email, logPath) =>
      "请将出错页面的截图以及日志文件发送到以下邮箱:\n ${email}\n日志文件路径: ${logPath}";

  static m1(curVersion, newVersion) =>
      "当前版本: ${curVersion}\n最新版本: ${newVersion}\n跳转到浏览器下载";

  static m2(name) => "源${name}";

  static m3(n) => "最多${n}池";

  static m4(n) => "圣杯替换为传承结晶 ${n} 个";

  static m5(error) => "导入失败，Error:\n${error}";

  static m6(name) => "${name}已存在";

  static m7(site) => "跳转到${site}";

  static m8(first) => "${Intl.select(first, {
        'true': '已经是第一张',
        'false': '已经是最后一张',
        'other': '已经到头了',
      })}";

  static m9(index) => "规划${index}";

  static m10(total) => "总计: ${total}";

  static m11(total, hidden) => "总计: ${total} (隐藏: ${hidden})";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static _notInlinedMessages(_) => <String, Function>{
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "　本应用所使用数据均来源于游戏及以下网站，游戏图片文本原文等版权属于TYPE MOON/FGO PROJECT。\n　程序功能与界面设计参考微信小程序\"素材规划\"以及iOS版Guda。"),
        "about_appstore_rating":
            MessageLookupByLibrary.simpleMessage("App Store评分"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("数据来源"),
        "about_data_source_footer":
            MessageLookupByLibrary.simpleMessage("若存在未标注的来源或侵权敬请告知"),
        "about_email_dialog": m0,
        "about_email_subtitle":
            MessageLookupByLibrary.simpleMessage("请附上出错页面截图和日志"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("反馈"),
        "about_update_app": MessageLookupByLibrary.simpleMessage("应用更新"),
        "about_update_app_alert_ios_mac":
            MessageLookupByLibrary.simpleMessage("请在App Store中检查更新"),
        "about_update_app_detail": m1,
        "active_skill": MessageLookupByLibrary.simpleMessage("持有技能"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("口算不及格的咕朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("AP计算"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP效率"),
        "ap_overflow_time": MessageLookupByLibrary.simpleMessage("AP溢出时间"),
        "ascension": MessageLookupByLibrary.simpleMessage("灵基"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("灵基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("灵基再临"),
        "backup": MessageLookupByLibrary.simpleMessage("备份"),
        "backup_success": MessageLookupByLibrary.simpleMessage("备份成功"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("羁绊礼装"),
        "calculate": MessageLookupByLibrary.simpleMessage("计算"),
        "calculator": MessageLookupByLibrary.simpleMessage("计算器"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "card_description": MessageLookupByLibrary.simpleMessage("解说"),
        "card_info": MessageLookupByLibrary.simpleMessage("资料"),
        "check_update": MessageLookupByLibrary.simpleMessage("检查更新"),
        "clear": MessageLookupByLibrary.simpleMessage("清除"),
        "clear_userdata": MessageLookupByLibrary.simpleMessage("清除用户数据"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("纹章"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令纹章"),
        "confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "copper": MessageLookupByLibrary.simpleMessage("铜"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("拷贝自其它规划"),
        "counts": MessageLookupByLibrary.simpleMessage("次数"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "cur_account": MessageLookupByLibrary.simpleMessage("当前账号"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("现有AP"),
        "current_": MessageLookupByLibrary.simpleMessage("当前"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("前往下载页"),
        "dataset_goto_download_page_hint":
            MessageLookupByLibrary.simpleMessage("下载后手动导入"),
        "dataset_management": MessageLookupByLibrary.simpleMessage("数据管理"),
        "dataset_type_entire": MessageLookupByLibrary.simpleMessage("完整数据包"),
        "dataset_type_entire_hint":
            MessageLookupByLibrary.simpleMessage("包含文本和图片，~25M"),
        "dataset_type_text": MessageLookupByLibrary.simpleMessage("文本数据包"),
        "dataset_type_text_hint":
            MessageLookupByLibrary.simpleMessage("不包含图片，~5M"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "delete_all_data": MessageLookupByLibrary.simpleMessage("删除所有数据"),
        "delete_all_data_hint":
            MessageLookupByLibrary.simpleMessage("包含用户数据、游戏数据、图片资源, 并加载默认资源"),
        "download": MessageLookupByLibrary.simpleMessage("下载"),
        "download_complete": MessageLookupByLibrary.simpleMessage("下载完成"),
        "download_latest_gamedata":
            MessageLookupByLibrary.simpleMessage("下载最新数据"),
        "download_source": MessageLookupByLibrary.simpleMessage("下载源"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("游戏数据和应用更新"),
        "download_source_of": m2,
        "downloaded": MessageLookupByLibrary.simpleMessage("已下载"),
        "downloading": MessageLookupByLibrary.simpleMessage("下载中"),
        "dress": MessageLookupByLibrary.simpleMessage("灵衣"),
        "dress_up": MessageLookupByLibrary.simpleMessage("灵衣开放"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("点击 + 添加素材"),
        "drop_calc_help_text": MessageLookupByLibrary.simpleMessage(
            "计算结果仅供参考\n>>>最低AP：\n过滤AP较低的free, 但保证每个素材至少有一个关卡\n>>>选择国服则未实装的素材将被移除\n>>>优化：最低总次数或最低总AP\n"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("最低AP"),
        "drop_calc_optimize": MessageLookupByLibrary.simpleMessage("优化"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("求解"),
        "drop_calculator": MessageLookupByLibrary.simpleMessage("掉落速查"),
        "drop_calculator_short": MessageLookupByLibrary.simpleMessage("掉落速查"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("掉率"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "enhance": MessageLookupByLibrary.simpleMessage("强化"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage("强化将扣除以下素材"),
        "event_collect_item_confirm":
            MessageLookupByLibrary.simpleMessage("所有素材添加到素材仓库，并将该活动移出规划"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("收取素材"),
        "event_item_default":
            MessageLookupByLibrary.simpleMessage("商店/任务/点数/关卡掉落奖励"),
        "event_item_extra": MessageLookupByLibrary.simpleMessage("其他"),
        "event_lottery_limit_hint": m3,
        "event_lottery_limited": MessageLookupByLibrary.simpleMessage("有限池"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("池"),
        "event_lottery_unlimited": MessageLookupByLibrary.simpleMessage("无限池"),
        "event_not_planned": MessageLookupByLibrary.simpleMessage("活动未列入规划"),
        "event_rerun_replace_grail": m4,
        "event_title": MessageLookupByLibrary.simpleMessage("活动"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交换券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交换券"),
        "favorite": MessageLookupByLibrary.simpleMessage("关注"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("效率剧场"),
        "filename": MessageLookupByLibrary.simpleMessage("文件名"),
        "filter": MessageLookupByLibrary.simpleMessage("筛选"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("属性"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("阵营"),
        "filter_category": MessageLookupByLibrary.simpleMessage("分类"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("获取方式"),
        "filter_plan_not_reached": MessageLookupByLibrary.simpleMessage("未满"),
        "filter_plan_reached": MessageLookupByLibrary.simpleMessage("已满"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("显示"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("技能练度"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("排序"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("职阶"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("序号"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("星级"),
        "filter_special_trait": MessageLookupByLibrary.simpleMessage("特殊特性"),
        "free_quest": MessageLookupByLibrary.simpleMessage("Free本"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("首页"),
        "game_drop": MessageLookupByLibrary.simpleMessage("掉落"),
        "game_experience": MessageLookupByLibrary.simpleMessage("经验"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("羁绊"),
        "gamedata": MessageLookupByLibrary.simpleMessage("游戏数据"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("圣杯"),
        "grail_level": MessageLookupByLibrary.simpleMessage("圣杯等级"),
        "grail_up": MessageLookupByLibrary.simpleMessage("圣杯转临"),
        "guda_item_data": MessageLookupByLibrary.simpleMessage("素材数据"),
        "guda_servant_data": MessageLookupByLibrary.simpleMessage("从者数据"),
        "hello": MessageLookupByLibrary.simpleMessage("你好！御主!"),
        "help": MessageLookupByLibrary.simpleMessage("帮助"),
        "hint_no_bond_craft": MessageLookupByLibrary.simpleMessage("无羁绊礼装"),
        "hint_no_valentine_craft":
            MessageLookupByLibrary.simpleMessage("无情人节礼装"),
        "illustration": MessageLookupByLibrary.simpleMessage("卡面"),
        "illustrator": MessageLookupByLibrary.simpleMessage("画师"),
        "import_data": MessageLookupByLibrary.simpleMessage("导入"),
        "import_data_error": m5,
        "import_data_success": MessageLookupByLibrary.simpleMessage("成功导入数据"),
        "import_guda_data": MessageLookupByLibrary.simpleMessage("导入Guda数据"),
        "import_guda_hint": MessageLookupByLibrary.simpleMessage(
            "更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据"),
        "import_guda_items": MessageLookupByLibrary.simpleMessage("导入素材数据"),
        "import_guda_servants": MessageLookupByLibrary.simpleMessage("导入从者数据"),
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
        "info_height": MessageLookupByLibrary.simpleMessage("身高"),
        "info_human": MessageLookupByLibrary.simpleMessage("人形"),
        "info_luck": MessageLookupByLibrary.simpleMessage("幸运"),
        "info_mana": MessageLookupByLibrary.simpleMessage("魔力"),
        "info_np": MessageLookupByLibrary.simpleMessage("宝具"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP获得率"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("出星率"),
        "info_strength": MessageLookupByLibrary.simpleMessage("筋力"),
        "info_trait": MessageLookupByLibrary.simpleMessage("特性"),
        "info_value": MessageLookupByLibrary.simpleMessage("数值"),
        "info_weak_to_ea": MessageLookupByLibrary.simpleMessage("被EA特攻"),
        "info_weight": MessageLookupByLibrary.simpleMessage("体重"),
        "input_invalid_hint": MessageLookupByLibrary.simpleMessage("输入无效"),
        "ios_app_path":
            MessageLookupByLibrary.simpleMessage("\"文件\"应用/我的iPhone/Chaldea"),
        "item": MessageLookupByLibrary.simpleMessage("素材"),
        "item_already_exist_hint": m6,
        "item_category_ascension": MessageLookupByLibrary.simpleMessage("职阶棋子"),
        "item_category_copper": MessageLookupByLibrary.simpleMessage("铜素材"),
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
        "item_exceed": MessageLookupByLibrary.simpleMessage("材料富余量"),
        "item_left": MessageLookupByLibrary.simpleMessage("剩余"),
        "item_no_free_quests": MessageLookupByLibrary.simpleMessage("无Free本"),
        "item_own": MessageLookupByLibrary.simpleMessage("拥有"),
        "item_title": MessageLookupByLibrary.simpleMessage("素材"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("共需"),
        "jump_to": m7,
        "language": MessageLookupByLibrary.simpleMessage("简体中文"),
        "limited_event": MessageLookupByLibrary.simpleMessage("限时活动"),
        "list_end_hint": m8,
        "main_record": MessageLookupByLibrary.simpleMessage("主线记录"),
        "main_record_bonus": MessageLookupByLibrary.simpleMessage("通关奖励"),
        "main_record_bonus_short": MessageLookupByLibrary.simpleMessage("奖励"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("章节"),
        "main_record_fixed_drop": MessageLookupByLibrary.simpleMessage("固定掉落"),
        "main_record_fixed_drop_short":
            MessageLookupByLibrary.simpleMessage("掉落"),
        "max_ap": MessageLookupByLibrary.simpleMessage("最大AP"),
        "more": MessageLookupByLibrary.simpleMessage("更多"),
        "new_account": MessageLookupByLibrary.simpleMessage("新建账号"),
        "next_card": MessageLookupByLibrary.simpleMessage("下一张"),
        "nga": MessageLookupByLibrary.simpleMessage("NGA"),
        "nga_fgo": MessageLookupByLibrary.simpleMessage("NGA-FGO"),
        "no": MessageLookupByLibrary.simpleMessage("否"),
        "nobel_phantasm": MessageLookupByLibrary.simpleMessage("宝具"),
        "nobel_phantasm_level": MessageLookupByLibrary.simpleMessage("宝具等级"),
        "obtain_methods": MessageLookupByLibrary.simpleMessage("获取方式"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "open": MessageLookupByLibrary.simpleMessage("打开"),
        "overwrite": MessageLookupByLibrary.simpleMessage("覆盖"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("职阶技能"),
        "plan": MessageLookupByLibrary.simpleMessage("规划"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("规划最大化(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("规划最大化(999)"),
        "plan_title": MessageLookupByLibrary.simpleMessage("规划"),
        "plan_x": m9,
        "previous_card": MessageLookupByLibrary.simpleMessage("上一张"),
        "query_failed": MessageLookupByLibrary.simpleMessage("查询失败"),
        "rarity": MessageLookupByLibrary.simpleMessage("稀有度"),
        "reload_data_success": MessageLookupByLibrary.simpleMessage("导入成功"),
        "reload_default_gamedata":
            MessageLookupByLibrary.simpleMessage("重新载入预装版本"),
        "reloading_data": MessageLookupByLibrary.simpleMessage("导入中"),
        "rename": MessageLookupByLibrary.simpleMessage("重命名"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("复刻活动"),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "reset_success": MessageLookupByLibrary.simpleMessage("已重置"),
        "reset_svt_enhance_state":
            MessageLookupByLibrary.simpleMessage("重置从者强化本状态"),
        "reset_svt_enhance_state_hint":
            MessageLookupByLibrary.simpleMessage("宝具本/技能本恢复成国服状态"),
        "restore": MessageLookupByLibrary.simpleMessage("恢复"),
        "search_result_count": m10,
        "search_result_count_hide": m11,
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("选择复制来源"),
        "select_plan": MessageLookupByLibrary.simpleMessage("选择规划"),
        "servant": MessageLookupByLibrary.simpleMessage("从者"),
        "servant_title": MessageLookupByLibrary.simpleMessage("从者"),
        "server": MessageLookupByLibrary.simpleMessage("服务器"),
        "server_cn": MessageLookupByLibrary.simpleMessage("国服"),
        "server_jp": MessageLookupByLibrary.simpleMessage("日服"),
        "settings_about": MessageLookupByLibrary.simpleMessage("关于"),
        "settings_data": MessageLookupByLibrary.simpleMessage("数据"),
        "settings_data_management":
            MessageLookupByLibrary.simpleMessage("数据管理"),
        "settings_general": MessageLookupByLibrary.simpleMessage("通用"),
        "settings_language": MessageLookupByLibrary.simpleMessage("语言"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("设置"),
        "settings_tutorial": MessageLookupByLibrary.simpleMessage("使用帮助"),
        "settings_use_mobile_network":
            MessageLookupByLibrary.simpleMessage("使用移动数据下载"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "silver": MessageLookupByLibrary.simpleMessage("银"),
        "skill": MessageLookupByLibrary.simpleMessage("技能"),
        "skill_up": MessageLookupByLibrary.simpleMessage("技能升级"),
        "skilled_max10": MessageLookupByLibrary.simpleMessage("练度最大化(310)"),
        "statistics_include_checkbox":
            MessageLookupByLibrary.simpleMessage("包含现有素材"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("统计"),
        "svt_info_tab_base": MessageLookupByLibrary.simpleMessage("基础资料"),
        "svt_info_tab_bond_story": MessageLookupByLibrary.simpleMessage("羁绊故事"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("未关注"),
        "svt_obtain_event": MessageLookupByLibrary.simpleMessage("活动赠送"),
        "svt_obtain_friend_point":
            MessageLookupByLibrary.simpleMessage("友情点召唤"),
        "svt_obtain_initial": MessageLookupByLibrary.simpleMessage("初始获得"),
        "svt_obtain_limited": MessageLookupByLibrary.simpleMessage("期间限定"),
        "svt_obtain_permanent": MessageLookupByLibrary.simpleMessage("圣晶石常驻"),
        "svt_obtain_story": MessageLookupByLibrary.simpleMessage("剧情限定"),
        "svt_obtain_unavailable": MessageLookupByLibrary.simpleMessage("无法召唤"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("已隐藏"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("刷新首页图"),
        "total_ap": MessageLookupByLibrary.simpleMessage("总AP"),
        "total_counts": MessageLookupByLibrary.simpleMessage("总次数"),
        "update": MessageLookupByLibrary.simpleMessage("更新"),
        "userdata": MessageLookupByLibrary.simpleMessage("用户数据"),
        "userdata_cleared": MessageLookupByLibrary.simpleMessage("用户数据已清除"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("情人节礼装"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("查看卡面"),
        "voice": MessageLookupByLibrary.simpleMessage("语音"),
        "yes": MessageLookupByLibrary.simpleMessage("是")
      };
}
