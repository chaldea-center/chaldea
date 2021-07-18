import 'package:chaldea/components/split_route/split_route.dart';
import 'package:flutter/material.dart';

class GalleryItem {
  static const String servant = 'servant';
  static const String craft_essence = 'craft';
  static const String cmd_code = 'cmd_code';
  static const String item = 'item';
  static const String event = 'event';
  static const String plan = 'plan';
  static const String free_calculator = 'free_calculator';
  static const String mystic_code = 'mystic_code';
  static const String costume = 'costume';
  static const String gacha = 'gacha';
  static const String ffo = 'ffo';
  static const String cv_list = 'cv_list';
  static const String illustrator_list = 'illustrator_list';

  static const String master_mission = 'master_mission';
  static const String calculator = 'calculator';
  static const String master_equip = 'master_equip';
  static const String exp_card = 'exp_card';
  static const String ap_cal = 'ap_cal';
  static const String statistics = 'statistics';

  // static const String image_analysis = 'image_analysis';
  static const String import_data = 'import_data';
  static const String backup = 'backup';
  static const String more = 'more';
  static const String issues = 'issues';

  static List<String> get persistentPages => [issues, more];

//  static Map<String, GalleryItem> allItems;

  // instant part
  final String name;
  final String title;
  final IconData? icon;
  final Widget? child;
  final SplitPageBuilder? builder;
  final bool isDetail;

  const GalleryItem({
    required this.name,
    required this.title,
    this.icon,
    this.child,
    this.builder,
    this.isDetail = false,
  }) : assert(icon != null || child != null);

  @override
  String toString() {
    return '$runtimeType($name)';
  }
}
