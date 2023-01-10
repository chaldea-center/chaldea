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

  static String m0(curVersion, newVersion, releaseNote) =>
      "当前版本: ${curVersion}\n最新版本: ${newVersion}\n更新内容:\n${releaseNote}";

  static String m1(url) =>
      "Chaldea——一款跨平台的Fate/GO素材规划客户端，支持游戏信息浏览、从者练度/活动/素材规划、周常规划、抽卡模拟器等功能。\n\n详情请见: \n${url}\n";

  static String m2(version) => "App版本需不低于${version}";

  static String m3(n) => "最多${n}池";

  static String m4(n, total) => "圣杯替换为传承结晶 ${n}/${total} 个";

  static String m15(filename, hash, localHash) =>
      "文件${filename}未找到或错误: ${hash} - ${localHash}";

  static String m16(rarity) => "${rarity}星礼装PickUp";

  static String m17(rarity) => "${rarity}星从者PickUp";

  static String m5(error) => "导入失败:\n${error}";

  static String m6(name) => "${name}已存在";

  static String m7(site) => "跳转到${site}";

  static String m18(shown, total) => "显示${shown}/总计${total}";

  static String m19(shown, ignore, total) =>
      "显示${shown}/忽略${ignore}/总计${total}";

  static String m8(first) => "${Intl.select(first, {
            'true': '已经是第一张',
            'false': '已经是最后一张',
            'other': '已经到头了',
          })}";

  static String m9(n) => "第${n}节";

  static String m20(region) => "出现错误或${region}无此关卡数据";

  static String m21(unknown, dup, valid, total, selected) =>
      "${unknown}不明, ${dup}重复, ${valid}/${total}有效, ${selected}已选";

  static String m10(region) => "${region}公告";

  static String m11(n) => "重置规划${n}(所有)";

  static String m12(n) => "重置规划${n}(已显示)";

  static String m22(battles, ap) => "总计${battles}次战斗, ${ap} AP";

  static String m13(n) => "个人资料${n}";

  static String m23(color, trait) => "此宝具显示为${color}卡，但不持有[${trait}]特性";

  static String m24(trait) => "这是一个宝具，但不持有[${trait}]特性";

  static String m14(a, b) => "${a}${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("关于"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "　本应用所使用数据均来源于游戏及以下网站，游戏图片文本原文等版权属于TYPE MOON/FGO PROJECT。\n　程序功能与界面设计参考微信小程序\"素材规划\"以及iOS版Guda。"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("数据来源"),
        "about_data_source_footer":
            MessageLookupByLibrary.simpleMessage("若存在未标注的来源或侵权敬请告知"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("反馈"),
        "about_update_app_detail": m0,
        "account_title": MessageLookupByLibrary.simpleMessage("账户"),
        "active_skill": MessageLookupByLibrary.simpleMessage("主动技能"),
        "active_skill_short": MessageLookupByLibrary.simpleMessage("主动"),
        "add": MessageLookupByLibrary.simpleMessage("添加"),
        "add_condition": MessageLookupByLibrary.simpleMessage("添加条件"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("请填写反馈内容"),
        "add_mission": MessageLookupByLibrary.simpleMessage("添加任务"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("加入黑名单"),
        "anniversary": MessageLookupByLibrary.simpleMessage("周年"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_campaign_time_mismatch_hint":
            MessageLookupByLibrary.simpleMessage("关卡AP等相关活动显示的时间(日服除外)可能不准确"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP效率"),
        "app_data_folder": MessageLookupByLibrary.simpleMessage("数据目录"),
        "app_data_use_external_storage":
            MessageLookupByLibrary.simpleMessage("使用外部储存(SD卡)"),
        "append_skill": MessageLookupByLibrary.simpleMessage("追加技能"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("追加"),
        "april_fool": MessageLookupByLibrary.simpleMessage("愚人节"),
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
        "autoplay": MessageLookupByLibrary.simpleMessage("自动播放"),
        "background": MessageLookupByLibrary.simpleMessage("背景"),
        "backup": MessageLookupByLibrary.simpleMessage("备份"),
        "backup_failed": MessageLookupByLibrary.simpleMessage("备份失败"),
        "backup_history": MessageLookupByLibrary.simpleMessage("历史备份"),
        "bgm": MessageLookupByLibrary.simpleMessage("BGM"),
        "blacklist": MessageLookupByLibrary.simpleMessage("黑名单"),
        "bond": MessageLookupByLibrary.simpleMessage("羁绊"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("羁绊礼装"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("羁绊效率"),
        "bond_limit": MessageLookupByLibrary.simpleMessage("羁绊上限"),
        "bootstrap_page_title": MessageLookupByLibrary.simpleMessage("引导页"),
        "branch_quest": MessageLookupByLibrary.simpleMessage("分支关卡"),
        "bronze": MessageLookupByLibrary.simpleMessage("铜"),
        "buff_check_opponent": MessageLookupByLibrary.simpleMessage("对方"),
        "buff_check_self": MessageLookupByLibrary.simpleMessage("自身"),
        "cache_icons": MessageLookupByLibrary.simpleMessage("缓存图标"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("权重"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "card_asset_chara_figure": MessageLookupByLibrary.simpleMessage("立绘差分"),
        "card_asset_command": MessageLookupByLibrary.simpleMessage("指令卡"),
        "card_asset_face": MessageLookupByLibrary.simpleMessage("头像框"),
        "card_asset_narrow_figure":
            MessageLookupByLibrary.simpleMessage("编队立绘"),
        "card_asset_status": MessageLookupByLibrary.simpleMessage("再临阶段图标"),
        "card_description": MessageLookupByLibrary.simpleMessage("解说"),
        "card_info": MessageLookupByLibrary.simpleMessage("资料"),
        "card_name": MessageLookupByLibrary.simpleMessage("卡牌名称"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("轮播设置"),
        "cc_equipped_svt": MessageLookupByLibrary.simpleMessage("已装备从者"),
        "ce_max_limit_break": MessageLookupByLibrary.simpleMessage("满破"),
        "ce_status": MessageLookupByLibrary.simpleMessage("图鉴状态"),
        "ce_status_met": MessageLookupByLibrary.simpleMessage("已遭遇"),
        "ce_status_not_met": MessageLookupByLibrary.simpleMessage("未遭遇"),
        "ce_status_owned": MessageLookupByLibrary.simpleMessage("已拥有"),
        "ce_type_mix_hp_atk": MessageLookupByLibrary.simpleMessage("混合"),
        "ce_type_none_hp_atk": MessageLookupByLibrary.simpleMessage("无"),
        "ce_type_pure_atk": MessageLookupByLibrary.simpleMessage("ATK"),
        "ce_type_pure_hp": MessageLookupByLibrary.simpleMessage("HP"),
        "chaldea_account": MessageLookupByLibrary.simpleMessage("Chaldea账号"),
        "chaldea_account_system_hint": MessageLookupByLibrary.simpleMessage(
            "  与V1数据不互通。\n  一个简易的用于数据备份及多设备同步的账户系统。\n  没有安全性保障，请不要设置常用密码！\n  若不需要上述功能，则无需注册。"),
        "chaldea_backup": MessageLookupByLibrary.simpleMessage("Chaldea应用备份"),
        "chaldea_gate": MessageLookupByLibrary.simpleMessage("迦勒底之门"),
        "chaldea_server": MessageLookupByLibrary.simpleMessage("Chaldea服务器"),
        "chaldea_server_cn": MessageLookupByLibrary.simpleMessage("国内"),
        "chaldea_server_global": MessageLookupByLibrary.simpleMessage("海外"),
        "chaldea_server_hint":
            MessageLookupByLibrary.simpleMessage("用于游戏数据和截图识别"),
        "chaldea_share_msg": m1,
        "change_log": MessageLookupByLibrary.simpleMessage("更新历史"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("出场角色"),
        "check_file_hash": MessageLookupByLibrary.simpleMessage("验证文件完整性"),
        "check_update": MessageLookupByLibrary.simpleMessage("检查更新"),
        "clear": MessageLookupByLibrary.simpleMessage("清空"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("清除缓存"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage("缓存已清理"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage("包括卡面语音等"),
        "clear_data": MessageLookupByLibrary.simpleMessage("清除数据"),
        "coin_summon_num": MessageLookupByLibrary.simpleMessage("召唤所得"),
        "command_code": MessageLookupByLibrary.simpleMessage("指令纹章"),
        "common_release_group_hint": MessageLookupByLibrary.simpleMessage(
            "当存在多组(Group)时，仅需满足其中一组(Group)条件即可"),
        "confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "consumed": MessageLookupByLibrary.simpleMessage("已消耗"),
        "contact_information_not_filled":
            MessageLookupByLibrary.simpleMessage("联系方式未填写"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage("将无法无法无法无法无法回复您的问题"),
        "copied": MessageLookupByLibrary.simpleMessage("已复制"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("拷贝自其它规划"),
        "cost": MessageLookupByLibrary.simpleMessage("消耗"),
        "costume": MessageLookupByLibrary.simpleMessage("灵衣"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("灵衣开放"),
        "counts": MessageLookupByLibrary.simpleMessage("计数"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("概念礼装"),
        "create_account_textfield_helper":
            MessageLookupByLibrary.simpleMessage("稍后在设置中可以添加更多游戏账号"),
        "create_duplicated_svt": MessageLookupByLibrary.simpleMessage("生成2号机"),
        "crit_star_mod": MessageLookupByLibrary.simpleMessage("暴击星补正"),
        "cur_account": MessageLookupByLibrary.simpleMessage("当前账号"),
        "current_": MessageLookupByLibrary.simpleMessage("当前"),
        "current_version": MessageLookupByLibrary.simpleMessage("当前版本"),
        "custom_mission": MessageLookupByLibrary.simpleMessage("自定义任务"),
        "custom_mission_mixed_type_hint":
            MessageLookupByLibrary.simpleMessage("同一任务中敌人类条件与关卡类条件不可一起使用"),
        "custom_mission_nothing_hint":
            MessageLookupByLibrary.simpleMessage("无任务，点击+添加"),
        "custom_mission_source_mission":
            MessageLookupByLibrary.simpleMessage("原任务"),
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
        "def_np_gain_mod": MessageLookupByLibrary.simpleMessage("敌攻击补正"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "demands": MessageLookupByLibrary.simpleMessage("需求"),
        "desktop_only": MessageLookupByLibrary.simpleMessage("仅限桌面版"),
        "details": MessageLookupByLibrary.simpleMessage("详情"),
        "detective_mission": MessageLookupByLibrary.simpleMessage("侦探任务"),
        "detective_rank": MessageLookupByLibrary.simpleMessage("侦探等级"),
        "display_grid": MessageLookupByLibrary.simpleMessage("网格"),
        "display_list": MessageLookupByLibrary.simpleMessage("列表"),
        "display_setting": MessageLookupByLibrary.simpleMessage("显示设置"),
        "display_show_window_fab":
            MessageLookupByLibrary.simpleMessage("显示多窗口按钮"),
        "done": MessageLookupByLibrary.simpleMessage("完成"),
        "download": MessageLookupByLibrary.simpleMessage("下载"),
        "download_latest_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("为确保兼容性，更新前请升级至最新版APP"),
        "download_source": MessageLookupByLibrary.simpleMessage("下载源"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("大陆地区请选择国内节点"),
        "downloaded": MessageLookupByLibrary.simpleMessage("已下载"),
        "downloading": MessageLookupByLibrary.simpleMessage("下载中"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("点击 + 添加素材"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("最低AP"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("求解"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("掉率"),
        "duplicated_servant": MessageLookupByLibrary.simpleMessage("2号机"),
        "duplicated_servant_duplicated":
            MessageLookupByLibrary.simpleMessage("2号机"),
        "duplicated_servant_primary":
            MessageLookupByLibrary.simpleMessage("初号机"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "effect_scope": MessageLookupByLibrary.simpleMessage("效果范围"),
        "effect_search": MessageLookupByLibrary.simpleMessage("效果检索"),
        "effect_search_trait_hint": MessageLookupByLibrary.simpleMessage(
            "Func/Buff的生效条件，其中毒/诅咒/灼伤也筛选含有该特性的buff"),
        "effect_target": MessageLookupByLibrary.simpleMessage("效果对象"),
        "effect_type": MessageLookupByLibrary.simpleMessage("效果类型"),
        "effective_condition": MessageLookupByLibrary.simpleMessage("生效条件"),
        "efficiency": MessageLookupByLibrary.simpleMessage("效率"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("效率类型"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP效率"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("每场掉率"),
        "email": MessageLookupByLibrary.simpleMessage("邮箱"),
        "enemy": MessageLookupByLibrary.simpleMessage("敌人"),
        "enemy_filter_trait_hint":
            MessageLookupByLibrary.simpleMessage("特性筛选仅适用于主线Free的敌人"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("敌人一览"),
        "enemy_summary": MessageLookupByLibrary.simpleMessage("敌人汇总"),
        "enhance": MessageLookupByLibrary.simpleMessage("强化"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage("强化将扣除以下素材"),
        "error": MessageLookupByLibrary.simpleMessage("错误"),
        "error_no_data_found": MessageLookupByLibrary.simpleMessage("未找到数据文件"),
        "error_no_internet": MessageLookupByLibrary.simpleMessage("无网络连接"),
        "error_required_app_version": m2,
        "error_widget_hint": MessageLookupByLibrary.simpleMessage("错误!点击返回>_<"),
        "event_ap_cost_half": MessageLookupByLibrary.simpleMessage("AP消耗减半"),
        "event_bonus": MessageLookupByLibrary.simpleMessage("加成"),
        "event_bulletin_board": MessageLookupByLibrary.simpleMessage("咕咕报"),
        "event_collect_item_confirm":
            MessageLookupByLibrary.simpleMessage("所有素材添加到素材仓库，并将该活动移出规划"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("收取素材"),
        "event_custom_item": MessageLookupByLibrary.simpleMessage("自定义可获得素材"),
        "event_custom_item_empty_hint":
            MessageLookupByLibrary.simpleMessage("点击+按钮自定义可获得素材"),
        "event_digging": MessageLookupByLibrary.simpleMessage("发掘"),
        "event_item_extra": MessageLookupByLibrary.simpleMessage("额外素材"),
        "event_item_fixed_extra":
            MessageLookupByLibrary.simpleMessage("额外固定素材"),
        "event_lottery": MessageLookupByLibrary.simpleMessage("奖池"),
        "event_lottery_limit_hint": m3,
        "event_lottery_limited": MessageLookupByLibrary.simpleMessage("有限池"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("池"),
        "event_lottery_unlimited": MessageLookupByLibrary.simpleMessage("无限池"),
        "event_not_planned": MessageLookupByLibrary.simpleMessage("活动未列入规划"),
        "event_point": MessageLookupByLibrary.simpleMessage("活动点数"),
        "event_point_reward": MessageLookupByLibrary.simpleMessage("点数"),
        "event_progress": MessageLookupByLibrary.simpleMessage("进度"),
        "event_quest": MessageLookupByLibrary.simpleMessage("活动关卡"),
        "event_recipe": MessageLookupByLibrary.simpleMessage("配方"),
        "event_rerun_replace_grail": m4,
        "event_shop": MessageLookupByLibrary.simpleMessage("活动商店"),
        "event_title": MessageLookupByLibrary.simpleMessage("活动"),
        "event_tower": MessageLookupByLibrary.simpleMessage("塔"),
        "event_treasure_box": MessageLookupByLibrary.simpleMessage("宝箱"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("素材交换券"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("交换券"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("等级"),
        "exp_card_plan_next": MessageLookupByLibrary.simpleMessage("距离下一级"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("相同职阶"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("种火需求"),
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
            "提交反馈前，请先查阅<**FAQ**>。反馈时请详细描述:\n- 如何复现/期望表现\n- 应用/数据版本、使用设备系统及版本\n- 附加截图日志\n- 以及最好能够提供联系方式(邮箱等)\n- 不要问为什么没找到某从者"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("发送"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("主题"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("身体"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("裁剪"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("头部"),
        "ffo_missing_data_hint":
            MessageLookupByLibrary.simpleMessage("请先下载或导入FFO资源包↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("同一从者"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("效率剧场"),
        "file_not_found_or_mismatched_hash": m15,
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
        "filter_plan_not_reached": MessageLookupByLibrary.simpleMessage("规划未满"),
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
        "free_quest_calculator": MessageLookupByLibrary.simpleMessage("Free规划"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("Free规划"),
        "gacha_prob_calc": MessageLookupByLibrary.simpleMessage("卡池概率计算"),
        "gacha_prob_ce_pickup": m16,
        "gacha_prob_custom_rate": MessageLookupByLibrary.simpleMessage("自定义概率"),
        "gacha_prob_precision_hint": MessageLookupByLibrary.simpleMessage(
            "数值过大或过小时由于double精度问题造成计算结果不准确"),
        "gacha_prob_svt_pickup": m17,
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("首页"),
        "game_account": MessageLookupByLibrary.simpleMessage("游戏账号"),
        "game_data_not_found":
            MessageLookupByLibrary.simpleMessage("数据加载失败，请先前往游戏数据页面下载"),
        "game_drop": MessageLookupByLibrary.simpleMessage("掉落"),
        "game_experience": MessageLookupByLibrary.simpleMessage("经验"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("羁绊"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("奖励"),
        "game_server": MessageLookupByLibrary.simpleMessage("游戏区服"),
        "gamedata": MessageLookupByLibrary.simpleMessage("游戏数据"),
        "general_all": MessageLookupByLibrary.simpleMessage("所有"),
        "general_close": MessageLookupByLibrary.simpleMessage("关闭"),
        "general_custom": MessageLookupByLibrary.simpleMessage("自定义"),
        "general_default": MessageLookupByLibrary.simpleMessage("默认"),
        "general_others": MessageLookupByLibrary.simpleMessage("其他"),
        "general_special": MessageLookupByLibrary.simpleMessage("特殊"),
        "general_type": MessageLookupByLibrary.simpleMessage("类型"),
        "global_text_selection":
            MessageLookupByLibrary.simpleMessage("全局文本可选择"),
        "glpk_error_no_valid_target":
            MessageLookupByLibrary.simpleMessage("无效条件或无相关目标"),
        "gold": MessageLookupByLibrary.simpleMessage("金"),
        "grail": MessageLookupByLibrary.simpleMessage("圣杯"),
        "grail_up": MessageLookupByLibrary.simpleMessage("圣杯转临"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("成长曲线"),
        "guda_female": MessageLookupByLibrary.simpleMessage("咕哒子"),
        "guda_male": MessageLookupByLibrary.simpleMessage("咕哒夫"),
        "help": MessageLookupByLibrary.simpleMessage("帮助"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("隐藏已过期"),
        "hide_svt_plan_details": MessageLookupByLibrary.simpleMessage("隐藏规划项"),
        "hide_svt_plan_details_hint": MessageLookupByLibrary.simpleMessage(
            "仅仅是在从者详情规划页不显示，实际仍计入素材规划与统计。"),
        "hide_unreleased_card": MessageLookupByLibrary.simpleMessage("隐藏未实装卡牌"),
        "high_difficulty_quest": MessageLookupByLibrary.simpleMessage("高难度关卡"),
        "http_sniff_hint":
            MessageLookupByLibrary.simpleMessage("(国/台/日/美)账号登陆时的数据"),
        "https_sniff": MessageLookupByLibrary.simpleMessage("Https抓包"),
        "hunting_quest": MessageLookupByLibrary.simpleMessage("狩猎关卡"),
        "icons": MessageLookupByLibrary.simpleMessage("图标"),
        "ignore": MessageLookupByLibrary.simpleMessage("忽略"),
        "illustration": MessageLookupByLibrary.simpleMessage("卡面"),
        "illustrator": MessageLookupByLibrary.simpleMessage("画师"),
        "image": MessageLookupByLibrary.simpleMessage("图片"),
        "import_active_skill_hint":
            MessageLookupByLibrary.simpleMessage("强化 - 从者技能强化"),
        "import_active_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("主动技能截图解析"),
        "import_append_skill_hint":
            MessageLookupByLibrary.simpleMessage("强化 - 被动技能强化"),
        "import_append_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("追加技能截图解析"),
        "import_backup": MessageLookupByLibrary.simpleMessage("导入备份"),
        "import_csv_export_all": MessageLookupByLibrary.simpleMessage("所有从者"),
        "import_csv_export_empty": MessageLookupByLibrary.simpleMessage("空模板"),
        "import_csv_export_favorite":
            MessageLookupByLibrary.simpleMessage("仅关注从者"),
        "import_csv_export_template":
            MessageLookupByLibrary.simpleMessage("导出模板"),
        "import_csv_load_csv": MessageLookupByLibrary.simpleMessage("载入CSV"),
        "import_csv_title": MessageLookupByLibrary.simpleMessage("CSV模板"),
        "import_data": MessageLookupByLibrary.simpleMessage("导入"),
        "import_data_error": m5,
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
            MessageLookupByLibrary.simpleMessage("仅更新识别成功的結果"),
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
        "info_charge": MessageLookupByLibrary.simpleMessage("充能"),
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
        "item_already_exist_hint": m6,
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
        "item_edit_owned_amount": MessageLookupByLibrary.simpleMessage("修改库存"),
        "item_eff": MessageLookupByLibrary.simpleMessage("素材效率"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "计算规划前，可以设置不同材料的富余量(仅用于Free本规划)"),
        "item_grail2crystal": MessageLookupByLibrary.simpleMessage("圣杯→传承结晶"),
        "item_left": MessageLookupByLibrary.simpleMessage("剩余"),
        "item_no_free_quests": MessageLookupByLibrary.simpleMessage("无Free本"),
        "item_only_show_lack": MessageLookupByLibrary.simpleMessage("仅显示不足"),
        "item_own": MessageLookupByLibrary.simpleMessage("拥有"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("素材截图"),
        "item_stat_include_owned": MessageLookupByLibrary.simpleMessage("包含库存"),
        "item_stat_sub_event": MessageLookupByLibrary.simpleMessage("减去活动所得"),
        "item_stat_sub_owned": MessageLookupByLibrary.simpleMessage("减去库存"),
        "item_title": MessageLookupByLibrary.simpleMessage("素材"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("共需"),
        "join_beta": MessageLookupByLibrary.simpleMessage("加入Beta版"),
        "jump_to": m7,
        "language": MessageLookupByLibrary.simpleMessage("简体中文"),
        "language_en": MessageLookupByLibrary.simpleMessage("Chinese"),
        "level": MessageLookupByLibrary.simpleMessage("等级"),
        "limited_event": MessageLookupByLibrary.simpleMessage("限时活动"),
        "limited_time": MessageLookupByLibrary.simpleMessage("限时"),
        "link": MessageLookupByLibrary.simpleMessage("链接"),
        "list_count_shown_all": m18,
        "list_count_shown_hidden_all": m19,
        "list_end_hint": m8,
        "load_ffo_data": MessageLookupByLibrary.simpleMessage("加载FFO数据"),
        "logic_type": MessageLookupByLibrary.simpleMessage("逻辑关系"),
        "logic_type_and": MessageLookupByLibrary.simpleMessage("且"),
        "logic_type_or": MessageLookupByLibrary.simpleMessage("或"),
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
        "lucky_bag_best": MessageLookupByLibrary.simpleMessage("最优"),
        "lucky_bag_expectation": MessageLookupByLibrary.simpleMessage("期望值"),
        "lucky_bag_expectation_short":
            MessageLookupByLibrary.simpleMessage("期望"),
        "lucky_bag_rating": MessageLookupByLibrary.simpleMessage("打分"),
        "lucky_bag_tooltip_unwanted":
            MessageLookupByLibrary.simpleMessage("非常不想要"),
        "lucky_bag_tooltip_wanted":
            MessageLookupByLibrary.simpleMessage("非常想要！"),
        "lucky_bag_worst": MessageLookupByLibrary.simpleMessage("最差"),
        "main_interlude": MessageLookupByLibrary.simpleMessage("主线物语"),
        "main_quest": MessageLookupByLibrary.simpleMessage("主线关卡"),
        "main_story": MessageLookupByLibrary.simpleMessage("主线记录"),
        "main_story_chapter": MessageLookupByLibrary.simpleMessage("章节"),
        "map_gimmicks": MessageLookupByLibrary.simpleMessage("小部件"),
        "map_show_fq_spots_only":
            MessageLookupByLibrary.simpleMessage("仅Free关卡地点"),
        "map_show_header_image": MessageLookupByLibrary.simpleMessage("显示标题图"),
        "map_show_roads": MessageLookupByLibrary.simpleMessage("显示道路"),
        "map_show_spots": MessageLookupByLibrary.simpleMessage("显示地点"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Master-Detail width"),
        "master_mission": MessageLookupByLibrary.simpleMessage("御主任务"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("关联关卡"),
        "master_mission_solution": MessageLookupByLibrary.simpleMessage("方案"),
        "master_mission_tasklist": MessageLookupByLibrary.simpleMessage("任务列表"),
        "master_mission_weekly": MessageLookupByLibrary.simpleMessage("周常任务"),
        "media_assets": MessageLookupByLibrary.simpleMessage("资源"),
        "migrate_external_storage_btn_no":
            MessageLookupByLibrary.simpleMessage("不迁移"),
        "migrate_external_storage_btn_yes":
            MessageLookupByLibrary.simpleMessage("迁移"),
        "migrate_external_storage_manual_warning":
            MessageLookupByLibrary.simpleMessage("请手动移动数据，否则启动后为空数据。"),
        "migrate_external_storage_title":
            MessageLookupByLibrary.simpleMessage("迁移数据"),
        "mission": MessageLookupByLibrary.simpleMessage("任务"),
        "move_down": MessageLookupByLibrary.simpleMessage("下移"),
        "move_up": MessageLookupByLibrary.simpleMessage("上移"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("魔术礼装"),
        "network_cur_connection": MessageLookupByLibrary.simpleMessage("当前连接"),
        "network_force_online": MessageLookupByLibrary.simpleMessage("强制在线模式"),
        "network_force_online_hint":
            MessageLookupByLibrary.simpleMessage("当未检测到网络连接时，App将默认处于离线模式"),
        "network_settings": MessageLookupByLibrary.simpleMessage("网络设置"),
        "new_account": MessageLookupByLibrary.simpleMessage("新建账号"),
        "new_data_available": MessageLookupByLibrary.simpleMessage("可用数据更新"),
        "new_drop_data_6th": MessageLookupByLibrary.simpleMessage("新掉落数据"),
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
        "np_charge": MessageLookupByLibrary.simpleMessage("NP充能"),
        "np_charge_type_instant": MessageLookupByLibrary.simpleMessage("直冲"),
        "np_charge_type_instant_sum":
            MessageLookupByLibrary.simpleMessage("直冲总计"),
        "np_charge_type_perturn": MessageLookupByLibrary.simpleMessage("缓冲"),
        "np_gain_mod": MessageLookupByLibrary.simpleMessage("敌受击补正"),
        "np_short": MessageLookupByLibrary.simpleMessage("宝具"),
        "obtain_time": MessageLookupByLibrary.simpleMessage("时间"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "one_off_quest": MessageLookupByLibrary.simpleMessage("一次性关卡"),
        "only_show_main_story_enemy":
            MessageLookupByLibrary.simpleMessage("仅显示主线Free敌人"),
        "open": MessageLookupByLibrary.simpleMessage("打开"),
        "open_condition": MessageLookupByLibrary.simpleMessage("开放条件"),
        "open_in_file_manager":
            MessageLookupByLibrary.simpleMessage("请用文件管理器打开"),
        "opening_time": MessageLookupByLibrary.simpleMessage("开放时间"),
        "outdated": MessageLookupByLibrary.simpleMessage("已过期"),
        "overview": MessageLookupByLibrary.simpleMessage("概览"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("被动技能"),
        "passive_skill_short": MessageLookupByLibrary.simpleMessage("被动"),
        "permanent": MessageLookupByLibrary.simpleMessage("永久"),
        "plan": MessageLookupByLibrary.simpleMessage("规划"),
        "plan_list_only_unlock_append":
            MessageLookupByLibrary.simpleMessage("仅已解锁追加"),
        "plan_list_set_all": MessageLookupByLibrary.simpleMessage("批量设置"),
        "plan_list_set_all_current": MessageLookupByLibrary.simpleMessage("当前"),
        "plan_list_set_all_target": MessageLookupByLibrary.simpleMessage("目标"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("规划最大化(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("规划最大化(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("规划目标"),
        "plan_title": MessageLookupByLibrary.simpleMessage("规划"),
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("规划Free本"),
        "prefer_april_fool_icon":
            MessageLookupByLibrary.simpleMessage("优先愚人节头像"),
        "preferred_translation": MessageLookupByLibrary.simpleMessage("首选翻译"),
        "preferred_translation_footer": MessageLookupByLibrary.simpleMessage(
            "拖动以更改顺序。\n用于游戏数据的显示而非应用UI语言。部分语言存在未翻译的部分。"),
        "prev_page": MessageLookupByLibrary.simpleMessage("上一页"),
        "preview": MessageLookupByLibrary.simpleMessage("预览"),
        "previous_card": MessageLookupByLibrary.simpleMessage("上一张"),
        "priority": MessageLookupByLibrary.simpleMessage("优先级"),
        "priority_tagging_hint":
            MessageLookupByLibrary.simpleMessage("建议备注不要太长，否则可能显示不全"),
        "probability": MessageLookupByLibrary.simpleMessage("概率"),
        "probability_expectation": MessageLookupByLibrary.simpleMessage("期望"),
        "project_homepage": MessageLookupByLibrary.simpleMessage("项目主页"),
        "quest": MessageLookupByLibrary.simpleMessage("关卡"),
        "quest_chapter_n": m9,
        "quest_condition": MessageLookupByLibrary.simpleMessage("开放条件"),
        "quest_detail_btn": MessageLookupByLibrary.simpleMessage("详情"),
        "quest_enemy_summary_hint": MessageLookupByLibrary.simpleMessage(
            "主线Free本中敌人信息的汇总，任何属性均可能被服务器所覆盖，仅供参考。\n*特殊*特性指仅部分敌人拥有的特性。"),
        "quest_fields": MessageLookupByLibrary.simpleMessage("场地"),
        "quest_fixed_drop": MessageLookupByLibrary.simpleMessage("固定掉落"),
        "quest_fixed_drop_short": MessageLookupByLibrary.simpleMessage("掉落"),
        "quest_not_found_error": m20,
        "quest_prefer_region": MessageLookupByLibrary.simpleMessage("首选区服"),
        "quest_prefer_region_hint":
            MessageLookupByLibrary.simpleMessage("若该关卡所属活动在所选区服尚未开放，则默认显示日服"),
        "quest_region_has_enemy_hint": MessageLookupByLibrary.simpleMessage(
            "仅日服(2020/11之后)和美服(2020/12之后)可能含有敌方数据"),
        "quest_restriction": MessageLookupByLibrary.simpleMessage("编队限制"),
        "quest_reward": MessageLookupByLibrary.simpleMessage("通关奖励"),
        "quest_reward_short": MessageLookupByLibrary.simpleMessage("奖励"),
        "quest_timeline_sort_campaign_open":
            MessageLookupByLibrary.simpleMessage("AP消耗活动开放时间"),
        "quest_timeline_sort_quest_open":
            MessageLookupByLibrary.simpleMessage("关卡开放时间"),
        "raid_quest": MessageLookupByLibrary.simpleMessage("柱子战"),
        "random": MessageLookupByLibrary.simpleMessage("随机"),
        "random_mission": MessageLookupByLibrary.simpleMessage("随机任务"),
        "rankup_quest": MessageLookupByLibrary.simpleMessage("强化关卡"),
        "rankup_timeline_hint": MessageLookupByLibrary.simpleMessage(
            "部分关卡时间与实际开放时间不符\n若按AP消耗活动时间排序，则只使用日服时间"),
        "rarity": MessageLookupByLibrary.simpleMessage("稀有度"),
        "rate_app_store": MessageLookupByLibrary.simpleMessage("App Store评分"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Google Play评分"),
        "recognizer_result_count": m21,
        "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "refresh_data_no_update": MessageLookupByLibrary.simpleMessage("无新增卡牌"),
        "region_cn": MessageLookupByLibrary.simpleMessage("国服"),
        "region_jp": MessageLookupByLibrary.simpleMessage("日服"),
        "region_kr": MessageLookupByLibrary.simpleMessage("韩服"),
        "region_na": MessageLookupByLibrary.simpleMessage("美服"),
        "region_notice": m10,
        "region_tw": MessageLookupByLibrary.simpleMessage("台服"),
        "related_traits": MessageLookupByLibrary.simpleMessage("关联特性"),
        "remove_condition": MessageLookupByLibrary.simpleMessage("删除条件"),
        "remove_duplicated_svt": MessageLookupByLibrary.simpleMessage("销毁2号机"),
        "remove_from_blacklist": MessageLookupByLibrary.simpleMessage("移出黑名单"),
        "remove_mission": MessageLookupByLibrary.simpleMessage("删除任务"),
        "rename": MessageLookupByLibrary.simpleMessage("重命名"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("复刻活动"),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "reset_custom_ascension_icon":
            MessageLookupByLibrary.simpleMessage("重置自定义从者头像"),
        "reset_plan_all": m11,
        "reset_plan_shown": m12,
        "resettable_digged_num":
            MessageLookupByLibrary.simpleMessage("重置所需发掘数目"),
        "restart_to_apply_changes":
            MessageLookupByLibrary.simpleMessage("重启以使配置生效"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "重启以更新应用，若更新失败，请手动复制source文件夹到destination"),
        "restore": MessageLookupByLibrary.simpleMessage("恢复"),
        "results": MessageLookupByLibrary.simpleMessage("结果"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("攒石"),
        "same_event_plan": MessageLookupByLibrary.simpleMessage("保持相同活动规划"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_as": MessageLookupByLibrary.simpleMessage("另存为"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("保存到相册"),
        "saved": MessageLookupByLibrary.simpleMessage("已保存"),
        "screen_size": MessageLookupByLibrary.simpleMessage("屏幕尺寸"),
        "screenshots": MessageLookupByLibrary.simpleMessage("截图"),
        "script_choice": MessageLookupByLibrary.simpleMessage("选项"),
        "script_choice_end": MessageLookupByLibrary.simpleMessage("选项分支结束"),
        "script_player_name": MessageLookupByLibrary.simpleMessage("藤丸"),
        "script_story": MessageLookupByLibrary.simpleMessage("剧情"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("基础信息"),
        "search_options": MessageLookupByLibrary.simpleMessage("搜索范围"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("选择复制来源"),
        "select_item_title": MessageLookupByLibrary.simpleMessage("选择素材"),
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
        "setting_drag_by_mouse":
            MessageLookupByLibrary.simpleMessage("允许鼠标拖动滚动组件"),
        "setting_home_plan_list_page":
            MessageLookupByLibrary.simpleMessage("首页-规划列表页"),
        "setting_only_change_second_append_skill":
            MessageLookupByLibrary.simpleMessage("仅更改追加技能2"),
        "setting_priority_tagging":
            MessageLookupByLibrary.simpleMessage("优先级备注"),
        "setting_servant_class_filter_style":
            MessageLookupByLibrary.simpleMessage("从者职阶筛选样式"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage("「关注」按钮默认筛选"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage("首页显示当前账号"),
        "setting_split_ratio": MessageLookupByLibrary.simpleMessage("分屏模式分割比例"),
        "setting_split_ratio_hint":
            MessageLookupByLibrary.simpleMessage("仅用于宽屏模式"),
        "setting_tabs_sorting": MessageLookupByLibrary.simpleMessage("标签页排序"),
        "settings_data": MessageLookupByLibrary.simpleMessage("数据"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("使用文档"),
        "settings_general": MessageLookupByLibrary.simpleMessage("通用"),
        "settings_language": MessageLookupByLibrary.simpleMessage("语言"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("设置"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "shop": MessageLookupByLibrary.simpleMessage("商店"),
        "show_carousel": MessageLookupByLibrary.simpleMessage("显示轮播图"),
        "show_empty_event": MessageLookupByLibrary.simpleMessage("显示无内容活动"),
        "show_frame_rate": MessageLookupByLibrary.simpleMessage("显示刷新率"),
        "show_fullscreen": MessageLookupByLibrary.simpleMessage("全屏显示"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("显示已过期"),
        "silver": MessageLookupByLibrary.simpleMessage("银"),
        "simulator": MessageLookupByLibrary.simpleMessage("模拟器"),
        "skill": MessageLookupByLibrary.simpleMessage("技能"),
        "skill_rankup": MessageLookupByLibrary.simpleMessage("技能强化"),
        "skill_up": MessageLookupByLibrary.simpleMessage("技能升级"),
        "skilled_max10": MessageLookupByLibrary.simpleMessage("练度最大化(310)"),
        "solution_battle_count": MessageLookupByLibrary.simpleMessage("次数"),
        "solution_target_count": MessageLookupByLibrary.simpleMessage("目标数"),
        "solution_total_battles_ap": m22,
        "sort_order": MessageLookupByLibrary.simpleMessage("排序"),
        "sound_effect": MessageLookupByLibrary.simpleMessage("音效"),
        "special_reward_hide": MessageLookupByLibrary.simpleMessage("隐藏特殊报酬"),
        "special_reward_show": MessageLookupByLibrary.simpleMessage("显示特殊报酬"),
        "sprites": MessageLookupByLibrary.simpleMessage("模型"),
        "sq_buy_pack_unit": MessageLookupByLibrary.simpleMessage("单"),
        "sq_fragment_convert":
            MessageLookupByLibrary.simpleMessage("21圣晶片=3圣晶石"),
        "sq_short": MessageLookupByLibrary.simpleMessage("石"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("统计"),
        "still_send": MessageLookupByLibrary.simpleMessage("仍然发送"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "summon": MessageLookupByLibrary.simpleMessage("卡池"),
        "summon_daily": MessageLookupByLibrary.simpleMessage("日替"),
        "summon_expectation_btn": MessageLookupByLibrary.simpleMessage("期望计算"),
        "summon_gacha_footer":
            MessageLookupByLibrary.simpleMessage("仅供娱乐, 如有雷同, 纯属巧合"),
        "summon_gacha_result": MessageLookupByLibrary.simpleMessage("抽卡结果"),
        "summon_pull_unit": MessageLookupByLibrary.simpleMessage("抽"),
        "summon_show_banner": MessageLookupByLibrary.simpleMessage("显示横幅"),
        "summon_ticket_short": MessageLookupByLibrary.simpleMessage("呼符"),
        "summon_title": MessageLookupByLibrary.simpleMessage("卡池一览"),
        "super_effective_damage": MessageLookupByLibrary.simpleMessage("特攻"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("支持与捐赠"),
        "support_servant": MessageLookupByLibrary.simpleMessage("助战"),
        "support_servant_forced": MessageLookupByLibrary.simpleMessage("限定"),
        "support_servant_short": MessageLookupByLibrary.simpleMessage("助战"),
        "svt_ascension_icon": MessageLookupByLibrary.simpleMessage("从者头像"),
        "svt_basic_info": MessageLookupByLibrary.simpleMessage("资料"),
        "svt_card_deck_incorrect":
            MessageLookupByLibrary.simpleMessage("敌方配卡及卡色可能不准确，以Hits分布为准"),
        "svt_class_dist": MessageLookupByLibrary.simpleMessage("职阶分布"),
        "svt_class_filter_auto": MessageLookupByLibrary.simpleMessage("自动适配"),
        "svt_class_filter_hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "svt_class_filter_single_row":
            MessageLookupByLibrary.simpleMessage("单行不展开Extra职阶"),
        "svt_class_filter_single_row_expanded":
            MessageLookupByLibrary.simpleMessage("单行并展开Extra职阶"),
        "svt_class_filter_two_row":
            MessageLookupByLibrary.simpleMessage("Extra职阶显示在第二行"),
        "svt_fav_btn_remember": MessageLookupByLibrary.simpleMessage("记住选择"),
        "svt_fav_btn_show_all": MessageLookupByLibrary.simpleMessage("显示全部"),
        "svt_fav_btn_show_favorite":
            MessageLookupByLibrary.simpleMessage("显示已关注"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("未关注"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("已隐藏"),
        "svt_profile": MessageLookupByLibrary.simpleMessage("羁绊故事"),
        "svt_profile_info": MessageLookupByLibrary.simpleMessage("角色详情"),
        "svt_profile_n": m13,
        "svt_related_ce": MessageLookupByLibrary.simpleMessage("关联礼装"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("重置规划"),
        "svt_second_archive": MessageLookupByLibrary.simpleMessage("保管室"),
        "svt_stat_own_total":
            MessageLookupByLibrary.simpleMessage("(999)拥有/总计"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("切换滑动条/下拉框"),
        "switch_region": MessageLookupByLibrary.simpleMessage("切换区服"),
        "td_base_hits_hint":
            MessageLookupByLibrary.simpleMessage("同一宝具不同持有者可能拥有不同的色卡和Hit分布"),
        "td_cardcolor_hint": m23,
        "td_cardnp_hint": m24,
        "td_rankup": MessageLookupByLibrary.simpleMessage("宝具强化"),
        "test_info_pad": MessageLookupByLibrary.simpleMessage("测试信息"),
        "testing": MessageLookupByLibrary.simpleMessage("测试ing"),
        "time_close": MessageLookupByLibrary.simpleMessage("关闭"),
        "time_end": MessageLookupByLibrary.simpleMessage("结束"),
        "time_start": MessageLookupByLibrary.simpleMessage("开始"),
        "toggle_dark_mode": MessageLookupByLibrary.simpleMessage("切换深色模式"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("刷新轮播图"),
        "total_ap": MessageLookupByLibrary.simpleMessage("总AP"),
        "total_counts": MessageLookupByLibrary.simpleMessage("总数"),
        "treasure_box_draw_cost": MessageLookupByLibrary.simpleMessage("每抽消耗"),
        "treasure_box_extra_gift":
            MessageLookupByLibrary.simpleMessage("每箱额外礼物"),
        "treasure_box_max_draw_once":
            MessageLookupByLibrary.simpleMessage("单次最多抽数"),
        "trial_quest": MessageLookupByLibrary.simpleMessage("体验关卡"),
        "unlock_quest": MessageLookupByLibrary.simpleMessage("解锁关卡"),
        "update": MessageLookupByLibrary.simpleMessage("更新"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("已经是最新版本"),
        "update_data_at_start": MessageLookupByLibrary.simpleMessage("启动时更新"),
        "update_data_at_start_off_hint":
            MessageLookupByLibrary.simpleMessage("加载本地数据并后台更新,下次启动应用更新"),
        "update_data_at_start_on_hint":
            MessageLookupByLibrary.simpleMessage("启动时间可能变长"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("更新数据包"),
        "update_msg_error": MessageLookupByLibrary.simpleMessage("更新失败"),
        "update_msg_no_update": MessageLookupByLibrary.simpleMessage("无可用更新"),
        "update_msg_succuss": MessageLookupByLibrary.simpleMessage("已更新"),
        "upload": MessageLookupByLibrary.simpleMessage("上传"),
        "upload_and_close_app": MessageLookupByLibrary.simpleMessage("上传并关闭"),
        "upload_and_close_app_alert":
            MessageLookupByLibrary.simpleMessage("是否上传数据再关闭应用?"),
        "upload_before_close_app":
            MessageLookupByLibrary.simpleMessage("关闭app前上传"),
        "usage": MessageLookupByLibrary.simpleMessage("使用方法"),
        "userdata": MessageLookupByLibrary.simpleMessage("用户数据"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("下载备份"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("选择一个备份"),
        "userdata_local": MessageLookupByLibrary.simpleMessage("用户数据(本地)"),
        "userdata_sync": MessageLookupByLibrary.simpleMessage("同步数据"),
        "userdata_sync_hint":
            MessageLookupByLibrary.simpleMessage("仅更新账户数据，不包含本地设置"),
        "userdata_sync_server":
            MessageLookupByLibrary.simpleMessage("同步数据(服务器)"),
        "userdata_upload_backup": MessageLookupByLibrary.simpleMessage("上传备份"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("情人节礼装"),
        "valentine_script": MessageLookupByLibrary.simpleMessage("情人节剧情"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "video": MessageLookupByLibrary.simpleMessage("视频"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("查看卡面"),
        "voice": MessageLookupByLibrary.simpleMessage("语音"),
        "war_age": MessageLookupByLibrary.simpleMessage("年代"),
        "war_banner": MessageLookupByLibrary.simpleMessage("标题图"),
        "war_board": MessageLookupByLibrary.simpleMessage("圣杯战线"),
        "war_map": MessageLookupByLibrary.simpleMessage("地图"),
        "war_title": MessageLookupByLibrary.simpleMessage("关卡配置"),
        "warning": MessageLookupByLibrary.simpleMessage("警告"),
        "web_renderer": MessageLookupByLibrary.simpleMessage("Web渲染器"),
        "words_separate": m14
      };
}
