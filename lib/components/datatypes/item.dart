part of datatypes;

@JsonSerializable(checked: true)
class Item {
  /// id: 4-digit number, X-Y-ZZ = X category & Y rarity & ZZ order number
  int id;
  int itemId;
  String name;

  /// may be null
  String? nameJp;
  String? nameEn;

  /// see [ItemCategory]
  /// category: 1-skill gem, 2-usual item(include crystal/grail), 3-ascension piece/monument,
  /// 4-event servants' ascension item, 5-special, now only QP
  int category;

  /// rarity: 1-cropper, 2-silver, 3-gold, 4-special(crystal/grail)
  @JsonKey(defaultValue: 0)
  int rarity;

  String? description;
  String? descriptionJp;

  Item({
    required this.id,
    required this.itemId,
    required this.name,
    this.nameJp,
    this.nameEn,
    required this.category,
    required this.rarity,
    this.description,
    this.descriptionJp,
  });

  Item copyWith({
    int? id,
    int? itemId,
    String? name,
    String? nameJp,
    String? nameEn,
    String? description,
    String? descriptionJp,
    int? rarity,
    int? category,
    int? num,
  }) {
    return Item(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      nameJp: nameJp ?? this.nameJp,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      descriptionJp: descriptionJp ?? this.descriptionJp,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
    );
  }

  factory Item.fromJson(Map<String, dynamic> data) => _$ItemFromJson(data);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  String toString() {
    return '$runtimeType($name)';
  }

  static int? getId(String key) {
    return db.gameData.items[key]?.id;
  }

  static String lNameOf(String name) {
    // name could be jp/en?
    return db.gameData.items[name]?.localizedName ?? name;
  }

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  static List<String> sortListById(List<String> data, [bool inPlace = false]) {
    return (inPlace ? data : List.from(data))
      ..sort((a, b) => (getId(a) ?? 9999) - (getId(b) ?? 9999));
  }

  static Map<String, T> sortMapById<T>(Map<String, T> data) {
    data.forEach((key, value) {
      getId(key);
    });
    return Map.fromEntries(data.entries.toList()
      ..sort((a, b) => (getId(a.key) ?? 9999) - (getId(b.key) ?? 9999)));
  }

  static String getNameOfCategory(int category, int rarity) {
    switch (category) {
      case 0:
      // not specific
      case ItemCategory.item:
        // usual items
        return [
          S.current.item_category_usual,
          S.current.item_category_bronze,
          S.current.item_category_silver,
          S.current.item_category_gold,
          S.current.item_category_special,
        ][rarity];
      case ItemCategory.gem:
        // gems
        return [
          S.current.item_category_gems,
          S.current.item_category_gem,
          S.current.item_category_magic_gem,
          S.current.item_category_secret_gem
        ][rarity];
      case ItemCategory.ascension:
        // pieces & monuments
        return [
          S.current.item_category_ascension,
          'Unknown',
          S.current.item_category_piece,
          S.current.item_category_monument,
        ][rarity];
      case ItemCategory.event:
        // event
        return S.current.item_category_event_svt_ascension;
      default:
        return S.current.item_category_others;
    }
  }

  static Widget iconBuilder({
    required BuildContext context,
    required String itemKey,
    double? width,
    double? height,
    String? text,
    bool jumpToDetail = true,
  }) {
    final size = MathUtils.fitSize(width, height, 132 / 144);
    width = size?.key;
    height = size?.value;
    Widget child = ImageWithText(
      image: db.getIconImage(itemKey,
          aspectRatio: 132 / 144, width: width, height: height),
      text: text,
      width: width,
      padding: size == null
          ? EdgeInsets.zero
          : EdgeInsets.fromLTRB(
              size.value / 22, 0, size.value / 22, size.value / 12),
    );
    if (jumpToDetail) {
      child = InkWell(
        child: child,
        onTap: () {
          SplitRoute.push(context, ItemDetailPage(itemKey: itemKey));
        },
      );
    }
    return child;
  }

  static int fouValToShown(int fou) {
    return fou >= 0 ? (1000 + 20 * fou) : (1000 + 50 * fou);
  }

  static int fouShownToVal(int shown) {
    return shown >= 1000 ? (shown - 1000) ~/ 20 : ((shown - 1000) / 50).floor();
  }
}

class Items {
  const Items._();

  static const String grail = '圣杯';
  static const String crystal = '传承结晶';
  static const String grail2crystal = '圣杯传承结晶';
  static const String qp = 'QP';
  static const String manaPri = '魔力棱镜';
  static const String rarePri = '稀有魔力棱镜';
  static const String summonTicket = '呼符';
  static const String quartz = '圣晶石';
  static const String quartzFragment = '圣晶片';
  static const String chaldeaLantern = '迦勒底梦火';
  static const String goldApple = '黄金果实';
  static const String silverApple = '白银果实';
  static const String bronzeApple = '赤铜果实';

  // static const String fouHp = 'HP芙芙';
  // static const String fouAtk = 'ATK芙芙';
  static const String fou3Hp = '明星之芙芙';
  static const String fou3Atk = '太阳之芙芙';
  static const String fou4Hp = '流星之芙芙';
  static const String fou4Atk = '日轮之芙芙';
  static const String servantCoin = '从者硬币';

  /// items for servant planning but not for ascension and skill
  static const List<String> extraPlanningItems = [
    qp,
    grail,
    chaldeaLantern,
    fou3Hp,
    fou3Atk,
    fou4Hp,
    fou4Atk,
    servantCoin,
  ];
}

class ItemCategory {
  const ItemCategory._();

  static const gem = 1;
  static const item = 2;
  static const ascension = 3;
  static const event = 4;
  static const special = 5;
}

class Grail {
  Grail._();

  static const maxLv = 120;

  static int maxGrailCount(int rarity) {
    if (rarity < 0 || rarity > 5) return 15;
    return [5, 5, 5, 4, 2, 0][rarity] + 15;
  }

  static int grailToLvMax(int rarity, int grail) {
    final grailLvs = maxGrailLvs(rarity);
    return grailLvs.getOrNull(grail) ?? grailLvs[0];
  }

  static List<int> maxGrailLvs(int rarity) {
    if (rarity < 0 || rarity > 5) return [];
    List<int> lvs = [
      [65, 70, 75, 80, 85, 90],
      [60, 70, 75, 80, 85, 90],
      [65, 70, 75, 80, 85, 90],
      [70, 75, 80, 85, 90],
      [80, 85, 90],
      [90]
    ][rarity];
    lvs.addAll(List.generate(15, (index) => 92 + index * 2));
    return lvs;
  }

  static List<int> maxAscensionGrailLvs({required int rarity}) {
    if (rarity < 0 || rarity > 5) return [];
    // why add 0?
    List<int> lvs = [
      [0, 25, 35, 45, 55, 65, 70, 75, 80, 85, 90],
      [0, 20, 30, 40, 50, 60, 70, 75, 80, 85, 90],
      [0, 25, 35, 45, 55, 65, 70, 75, 80, 85, 90],
      [0, 30, 40, 50, 60, 70, 75, 80, 85, 90],
      [0, 40, 50, 60, 70, 80, 85, 90],
      [0, 50, 60, 70, 80, 90]
    ][rarity];
    lvs.addAll(List.generate(15, (index) => 92 + index * 2));
    return lvs;
  }

  static List<Map<String, int>> itemCost(int rarity) {
    return [
      for (int index = 0; index < maxGrailCount(rarity); index++)
        {
          Items.grail: 1,
          if (grailToLvMax(rarity, index + 1) > 100) Items.servantCoin: 30,
          Items.qp: QPCost.grailQp(rarity, index, index + 1),
        }
    ];
  }
}

class QPCost {
  QPCost._();

  static List<int> bondLimitAll(int rarity) {
    if (rarity < 0 || rarity > 5) return [];
    return [];
  }

  static int bondLimitQP(int start, int end) {
    List<int> costs = [10, 12, 14, 16, 18]; //*1000,000
    int result = 0;
    for (int i = start; i < end; i++) {
      //start 10->0,14->4
      result += costs.getOrNull(i - 10) ?? 0;
    }
    return result * 1000000;
  }

  static List<int> grailQpAll(int rarity) {
    if (rarity < 0 || rarity > 5) return [];
    List<int> qps = [
      [60, 80, 100, 200, 300, 400, 500, 600, 700, 800],
      [40, 60, 80, 100, 200, 300, 400, 500, 600, 700],
      [60, 80, 100, 200, 300, 400, 500, 600, 700, 800],
      [100, 200, 300, 400, 500, 600, 700, 800, 900],
      [400, 500, 600, 700, 800, 900, 1000],
      [900, 1000, 1100, 1200, 1300]
    ][rarity];
    qps.addAll(List.generate(
        10, (index) => [900, 800, 900, 1000, 1200, 1500][rarity]));
    return qps.map((e) => e * 10000).toList();
  }

  static int grailQp(int rarity, int start, int end) {
    final qps = grailQpAll(rarity);
    int result = 0;
    for (int i = start; i < end; i++) {
      //start 1->0
      result += qps.getOrNull(i) ?? 0;
    }
    return result;
  }
}
