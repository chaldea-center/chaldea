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

  static m0(email, logPath) => "请将出错页面的截图以及日志文件发送到以下邮箱:\n ${email}\n日志文件路径: ${logPath}";

  static m1(curVersion, newVersion, releaseNote) =>
      "当前版本: ${curVersion}\n最新版本: ${newVersion}\n更新内容:\n${releaseNote}";

  static m2(name) => "源${name}";

  static m3(n) => "最多${n}池";

  static m4(n) => "圣杯替换为传承结晶 ${n} 个";

  static m5(error) => "导入失败，Error:\n${error}";

  static m6(account) => "已切换到账号${account}";

  static m7(itemNum, svtNum) => "导入${itemNum}个素材,${svtNum}从者到";

  static m8(name) => "${name}已存在";

  static m9(site) => "跳转到${site}";

  static m10(first) => "${Intl.select(first, {
            'true': '已经是第一张',
            'false': '已经是最后一张',
            'other': '已经到头了',
          })}";

  static m11(version) => "已更新数据版本至${version}";

  static m12(index) => "规划${index}";

  static m13(total) => "总计: ${total}";

  static m14(total, hidden) => "总计: ${total} (隐藏: ${hidden})";

  static m15(tempDir, externalBackupDir) =>
      "用户数据备份储存于临时目录(${tempDir})\n删除应用/安装其他架构安装包(如已装arm64-v8a再装armeabi-v7a)/后续可能构建号变更，将导致用户数据和临时备份删除，建议开启储存访问权限以备份至(${externalBackupDir}})";

  static m16(a, b) => "${a}${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("关于"),
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
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("加入黑名单"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("口算不及格的咕朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("AP计算"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP效率"),
        "ap_overflow_time": MessageLookupByLibrary.simpleMessage("AP溢出时间"),
        "ascension": MessageLookupByLibrary.simpleMessage("灵基"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("灵基"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("灵基再临"),
        "auto_update": MessageLookupByLibrary.simpleMessage("自动更新"),
        "backup": MessageLookupByLibrary.simpleMessage("备份"),
        "backup_data_alert": MessageLookupByLibrary.simpleMessage("及！时！备！份！"),
        "backup_success": MessageLookupByLibrary.simpleMessage("备份成功"),
        "blacklist": MessageLookupByLibrary.simpleMessage("黑名单"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("羁绊礼装"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("权重"),
        "calculate": MessageLookupByLibrary.simpleMessage("计算"),
        "calculator": MessageLookupByLibrary.simpleMessage("计算器"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "card_description": MessageLookupByLibrary.simpleMessage("解说"),
        "card_info": MessageLookupByLibrary.simpleMessage("资料"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("出场角色"),
        "check_update": MessageLookupByLibrary.simpleMessage("检查更新"),
        "choose_quest_hint": MessageLookupByLibrary.simpleMessage("选择Free本"),
        "clear": MessageLookupByLibrary.simpleMessage("清空"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("清除缓存"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage("缓存已清理"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("包括卡面语音等"),
        "clear_userdata": MessageLookupByLibrary.simpleMessage("清空用户数据"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("纹章"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令纹章"),
        "confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "copper": MessageLookupByLibrary.simpleMessage("铜"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("拷贝自其它规划"),
        "counts": MessageLookupByLibrary.simpleMessage("计数"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("生成2号机"),
        "cur_account": MessageLookupByLibrary.simpleMessage("当前账号"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("现有AP"),
        "current_": MessageLookupByLibrary.simpleMessage("当前"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("前往下载页"),
        "dataset_goto_download_page_hint":
            MessageLookupByLibrary.simpleMessage("下载后手动导入"),
        "dataset_management": MessageLookupByLibrary.simpleMessage("数据管理"),
        "dataset_type_image": MessageLookupByLibrary.simpleMessage("图片数据包"),
        "dataset_type_image_hint":
            MessageLookupByLibrary.simpleMessage("仅包含图片，~25M"),
        "dataset_type_text": MessageLookupByLibrary.simpleMessage("文本数据包"),
        "dataset_type_text_hint":
            MessageLookupByLibrary.simpleMessage("不包含图片，~5M"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "download": MessageLookupByLibrary.simpleMessage("下载"),
        "download_complete": MessageLookupByLibrary.simpleMessage("下载完成"),
        "download_full_gamedata":
            MessageLookupByLibrary.simpleMessage("下载最新数据"),
        "download_full_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("完整zip数据包"),
        "download_latest_gamedata":
            MessageLookupByLibrary.simpleMessage("下载最新数据"),
        "download_latest_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("为确保兼容性，更新前请升级至最新版APP"),
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
        "drop_rate": MessageLookupByLibrary.simpleMessage("掉率"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "efficiency": MessageLookupByLibrary.simpleMessage("效率"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("效率类型"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP效率"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("每场掉率"),
        "enhance": MessageLookupByLibrary.simpleMessage("强化"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage("强化将扣除以下素材"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("无网络连接"),
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
        "event_progress": MessageLookupByLibrary.simpleMessage("进度"),
        "event_rerun_replace_grail": m4,
        "event_title": MessageLookupByLibrary.simpleMessage("活动"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交换券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交换券"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("等级规划"),
        "exp_card_rarity5": MessageLookupByLibrary.simpleMessage("五星狗粮"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("相同职阶"),
        "exp_card_select_lvs":
            MessageLookupByLibrary.simpleMessage("选择起始和目标等级"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("狗粮需求"),
        "failed": MessageLookupByLibrary.simpleMessage("失败"),
        "favorite": MessageLookupByLibrary.simpleMessage("关注"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("添加图像或文件附件"),
        "feedback_add_crash_log":
            MessageLookupByLibrary.simpleMessage("添加崩溃日志"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("联系方式(可选)"),
        "feedback_content_hint": MessageLookupByLibrary.simpleMessage("反馈与建议"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("发送"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("背景"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("身体"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("裁剪"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("头部"),
        "ffo_missing_data_hint":
            MessageLookupByLibrary.simpleMessage("请先下载或导入FFO资源包↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("同一从者"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("效率剧场"),
        "filename": MessageLookupByLibrary.simpleMessage("文件名"),
        "filter": MessageLookupByLibrary.simpleMessage("筛选"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("属性"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("阵营"),
        "filter_category": MessageLookupByLibrary.simpleMessage("分类"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("性别"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("全选"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("获取方式"),
        "filter_plan_not_reached": MessageLookupByLibrary.simpleMessage("未满"),
        "filter_plan_reached": MessageLookupByLibrary.simpleMessage("已满"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("反选"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("显示"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("技能练度"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("排序"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("职阶"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("序号"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("星级"),
        "filter_special_trait": MessageLookupByLibrary.simpleMessage("特殊特性"),
        "free_efficiency": MessageLookupByLibrary.simpleMessage("Free效率"),
        "free_progress": MessageLookupByLibrary.simpleMessage("Free进度"),
        "free_progress_newest": MessageLookupByLibrary.simpleMessage("日服最新"),
        "free_quest": MessageLookupByLibrary.simpleMessage("Free本"),
        "free_quest_calculator": MessageLookupByLibrary.simpleMessage("Free速查"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("Free速查"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("首页"),
        "game_drop": MessageLookupByLibrary.simpleMessage("掉落"),
        "game_experience": MessageLookupByLibrary.simpleMessage("经验"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("羁绊"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("通关奖励"),
        "gamedata": MessageLookupByLibrary.simpleMessage("游戏数据"),
        "gitee_source_hint": MessageLookupByLibrary.simpleMessage("更新可能不及时"),
        "github_source_hint": MessageLookupByLibrary.simpleMessage("连接可能受阻"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("圣杯"),
        "grail_level": MessageLookupByLibrary.simpleMessage("圣杯等级"),
        "grail_up": MessageLookupByLibrary.simpleMessage("圣杯转临"),
        "guda_item_data": MessageLookupByLibrary.simpleMessage("Guda素材数据"),
        "guda_servant_data": MessageLookupByLibrary.simpleMessage("Guda从者数据"),
        "hello": MessageLookupByLibrary.simpleMessage("你好！御主!"),
        "help": MessageLookupByLibrary.simpleMessage("帮助"),
        "hint_no_bond_craft": MessageLookupByLibrary.simpleMessage("无羁绊礼装"),
        "hint_no_valentine_craft":
            MessageLookupByLibrary.simpleMessage("无情人节礼装"),
        "ignore": MessageLookupByLibrary.simpleMessage("忽略"),
        "illustration": MessageLookupByLibrary.simpleMessage("卡面"),
        "illustrator": MessageLookupByLibrary.simpleMessage("画师"),
        "image_analysis": MessageLookupByLibrary.simpleMessage("图像解析"),
        "import_data": MessageLookupByLibrary.simpleMessage("导入"),
        "import_data_error": m5,
        "import_data_success": MessageLookupByLibrary.simpleMessage("成功导入数据"),
        "import_guda_data": MessageLookupByLibrary.simpleMessage("导入Guda"),
        "import_guda_hint": MessageLookupByLibrary.simpleMessage(
            "更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据"),
        "import_guda_items": MessageLookupByLibrary.simpleMessage("导入素材"),
        "import_guda_servants": MessageLookupByLibrary.simpleMessage("导入从者"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("允许2号机"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "点击右上角导入解密的HTTPS响应包以导入账户数据\n点击帮助以查看如何捕获并解密HTTPS响应内容"),
        "import_http_body_hint_hide":
            MessageLookupByLibrary.simpleMessage("点击从者可隐藏/取消隐藏该从者"),
        "import_http_body_locked": MessageLookupByLibrary.simpleMessage("仅锁定"),
        "import_http_body_success_switch": m6,
        "import_http_body_target_account_header": m7,
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
        "install": MessageLookupByLibrary.simpleMessage("安装"),
        "interlude_and_rankup": MessageLookupByLibrary.simpleMessage("幕间&强化"),
        "ios_app_path":
            MessageLookupByLibrary.simpleMessage("\"文件\"应用/我的iPhone/Chaldea"),
        "item": MessageLookupByLibrary.simpleMessage("素材"),
        "item_already_exist_hint": m8,
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
        "level": MessageLookupByLibrary.simpleMessage("等级"),
        "limited_event": MessageLookupByLibrary.simpleMessage("限时活动"),
        "link": MessageLookupByLibrary.simpleMessage("链接"),
        "list_end_hint": m10,
        "load_dataset_error": MessageLookupByLibrary.simpleMessage("加载数据出错"),
        "load_dataset_error_hint":
            MessageLookupByLibrary.simpleMessage("请在设置-游戏数据中重新加载默认资源"),
        "login_change_password": MessageLookupByLibrary.simpleMessage("修改密码"),
        "login_first_hint": MessageLookupByLibrary.simpleMessage("请先登陆"),
        "login_hint_text": MessageLookupByLibrary.simpleMessage(
            "十分简易的系统，仅用于备份数据到服务器并实现多设备同步\n极mei低you安全性保证，请务必不要使用常用密码！！！"),
        "login_login": MessageLookupByLibrary.simpleMessage("登陆"),
        "login_logout": MessageLookupByLibrary.simpleMessage("登出"),
        "login_new_password": MessageLookupByLibrary.simpleMessage("新密码"),
        "login_password": MessageLookupByLibrary.simpleMessage("密码"),
        "login_password_error":
            MessageLookupByLibrary.simpleMessage("只能包含字母与数字，不少于4位"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage("不能与旧密码相同"),
        "login_signup": MessageLookupByLibrary.simpleMessage("注册"),
        "login_state_not_login": MessageLookupByLibrary.simpleMessage("未登录"),
        "login_username": MessageLookupByLibrary.simpleMessage("用户名"),
        "login_username_error":
            MessageLookupByLibrary.simpleMessage("只能包含字母与数字，字母开头，不少于4位"),
        "long_press_to_save_hint": MessageLookupByLibrary.simpleMessage("长按保存"),
        "main_record": MessageLookupByLibrary.simpleMessage("主线记录"),
        "main_record_bonus": MessageLookupByLibrary.simpleMessage("通关奖励"),
        "main_record_bonus_short": MessageLookupByLibrary.simpleMessage("奖励"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("章节"),
        "main_record_fixed_drop": MessageLookupByLibrary.simpleMessage("固定掉落"),
        "main_record_fixed_drop_short":
            MessageLookupByLibrary.simpleMessage("掉落"),
        "master_mission": MessageLookupByLibrary.simpleMessage("御主任务"),
        "max_ap": MessageLookupByLibrary.simpleMessage("最大AP"),
        "more": MessageLookupByLibrary.simpleMessage("更多"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("魔术礼装"),
        "new_account": MessageLookupByLibrary.simpleMessage("新建账号"),
        "next_card": MessageLookupByLibrary.simpleMessage("下一张"),
        "nga": MessageLookupByLibrary.simpleMessage("NGA"),
        "nga_fgo": MessageLookupByLibrary.simpleMessage("NGA-FGO"),
        "no": MessageLookupByLibrary.simpleMessage("否"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("无幕间或强化关卡"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("点击♡查看所有从者任务"),
        "nobel_phantasm": MessageLookupByLibrary.simpleMessage("宝具"),
        "nobel_phantasm_level": MessageLookupByLibrary.simpleMessage("宝具等级"),
        "obtain_methods": MessageLookupByLibrary.simpleMessage("获取方式"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "open": MessageLookupByLibrary.simpleMessage("打开"),
        "overwrite": MessageLookupByLibrary.simpleMessage("覆盖"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("职阶技能"),
        "patch_gamedata": MessageLookupByLibrary.simpleMessage("更新游戏数据"),
        "patch_gamedata_error_already_latest":
            MessageLookupByLibrary.simpleMessage("已经是最新数据"),
        "patch_gamedata_error_no_compatible":
            MessageLookupByLibrary.simpleMessage("找不到兼容此APP版本的数据版本"),
        "patch_gamedata_error_unknown_version":
            MessageLookupByLibrary.simpleMessage(
                "服务器不存在当前版本，无法使用补丁方式更新，请下载完整数据包"),
        "patch_gamedata_hint": MessageLookupByLibrary.simpleMessage("打补丁"),
        "patch_gamedata_success_to": m11,
        "plan": MessageLookupByLibrary.simpleMessage("规划"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("规划最大化(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("规划最大化(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("规划目标"),
        "plan_title": MessageLookupByLibrary.simpleMessage("规划"),
        "plan_x": m12,
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("规划Free本"),
        "previous_card": MessageLookupByLibrary.simpleMessage("上一张"),
        "priority": MessageLookupByLibrary.simpleMessage("优先级"),
        "progress_cn": MessageLookupByLibrary.simpleMessage("简中服"),
        "progress_jp": MessageLookupByLibrary.simpleMessage("日服"),
        "project_homepage": MessageLookupByLibrary.simpleMessage("项目主页"),
        "query_failed": MessageLookupByLibrary.simpleMessage("查询失败"),
        "quest": MessageLookupByLibrary.simpleMessage("关卡"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("开放条件"),
        "rarity": MessageLookupByLibrary.simpleMessage("稀有度"),
        "release_page": MessageLookupByLibrary.simpleMessage("下载页"),
        "reload_data_success": MessageLookupByLibrary.simpleMessage("导入成功"),
        "reload_default_gamedata":
            MessageLookupByLibrary.simpleMessage("重新载入预装版本"),
        "reloading_data": MessageLookupByLibrary.simpleMessage("导入中"),
        "remove_duplicated_svt": MessageLookupByLibrary.simpleMessage("销毁2号机"),
        "remove_from_blacklist": MessageLookupByLibrary.simpleMessage("移出黑名单"),
        "rename": MessageLookupByLibrary.simpleMessage("重命名"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("复刻活动"),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "reset_success": MessageLookupByLibrary.simpleMessage("已重置"),
        "reset_svt_enhance_state":
            MessageLookupByLibrary.simpleMessage("重置强化本状态"),
        "reset_svt_enhance_state_hint":
            MessageLookupByLibrary.simpleMessage("宝具本/技能本恢复成国服状态"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "重启以更新应用，若更新失败，请手动复制source文件夹到destination"),
        "restore": MessageLookupByLibrary.simpleMessage("恢复"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("保存到相册"),
        "saved": MessageLookupByLibrary.simpleMessage("已保存"),
        "search_result_count": m13,
        "search_result_count_hide": m14,
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("选择复制来源"),
        "select_plan": MessageLookupByLibrary.simpleMessage("选择规划"),
        "servant": MessageLookupByLibrary.simpleMessage("从者"),
        "servant_title": MessageLookupByLibrary.simpleMessage("从者"),
        "server": MessageLookupByLibrary.simpleMessage("服务器"),
        "server_cn": MessageLookupByLibrary.simpleMessage("国服"),
        "server_jp": MessageLookupByLibrary.simpleMessage("日服"),
        "setting_auto_rotate": MessageLookupByLibrary.simpleMessage("自动旋转"),
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
        "storage_permission_content": m15,
        "storage_permission_title":
            MessageLookupByLibrary.simpleMessage("储存权限"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "summon": MessageLookupByLibrary.simpleMessage("卡池"),
        "summon_title": MessageLookupByLibrary.simpleMessage("卡池一览"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("支持与捐赠"),
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
        "svt_related_cards": MessageLookupByLibrary.simpleMessage("出场礼装/纹章"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("重置规划"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("切换滑动条/下拉框"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("刷新首页图"),
        "total_ap": MessageLookupByLibrary.simpleMessage("总AP"),
        "total_counts": MessageLookupByLibrary.simpleMessage("总数"),
        "update": MessageLookupByLibrary.simpleMessage("更新"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("更新资源包"),
        "upload": MessageLookupByLibrary.simpleMessage("上传"),
        "userdata": MessageLookupByLibrary.simpleMessage("用户数据"),
        "userdata_cleared": MessageLookupByLibrary.simpleMessage("用户数据已清空"),
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
        "words_separate": m16,
        "yes": MessageLookupByLibrary.simpleMessage("是")
      };
}
