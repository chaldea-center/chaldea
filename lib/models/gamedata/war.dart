part of gamedata;

@JsonSerializable()
class NiceMap {
  int id;
  String? mapImage;
  int mapImageW;
  int mapImageH;
  String? headerImage;
  Bgm bgm;

  NiceMap({
    required this.id,
    this.mapImage,
    required this.mapImageW,
    required this.mapImageH,
    this.headerImage,
    required this.bgm,
  });

  factory NiceMap.fromJson(Map<String, dynamic> json) =>
      _$NiceMapFromJson(json);
}

@JsonSerializable()
class NiceSpot {
  int id;
  List<int> joinSpotIds;
  int mapId;
  String name;
  String? image;
  int x;
  int y;
  int imageOfsX;
  int imageOfsY;
  int nameOfsX;
  int nameOfsY;
  int questOfsX;
  int questOfsY;
  int nextOfsX;
  int nextOfsY;
  String closedMessage;
  List<Quest> quests;

  NiceSpot({
    required this.id,
    required this.joinSpotIds,
    required this.mapId,
    required this.name,
    this.image,
    required this.x,
    required this.y,
    required this.imageOfsX,
    required this.imageOfsY,
    required this.nameOfsX,
    required this.nameOfsY,
    required this.questOfsX,
    required this.questOfsY,
    required this.nextOfsX,
    required this.nextOfsY,
    required this.closedMessage,
    required this.quests,
  });

  factory NiceSpot.fromJson(Map<String, dynamic> json) =>
      _$NiceSpotFromJson(json);
}

@JsonSerializable()
class WarAdd {
  int warId;
  WarOverwriteType type;
  int priority;
  int overwriteId;
  String overwriteStr;
  String? overwriteBanner;
  CondType condType;
  int targetId;
  int value;
  int startedAt;
  int endedAt;

  WarAdd({
    required this.warId,
    required this.type,
    required this.priority,
    required this.overwriteId,
    required this.overwriteStr,
    this.overwriteBanner,
    required this.condType,
    required this.targetId,
    required this.value,
    required this.startedAt,
    required this.endedAt,
  });

  factory WarAdd.fromJson(Map<String, dynamic> json) => _$WarAddFromJson(json);
}

@JsonSerializable()
class NiceWar {
  int id;
  List<List<double>> coordinates;
  String age;
  String name;
  String longName;
  String? banner;
  String? headerImage;
  int priority;
  int parentWarId;
  int materialParentWarId;
  String emptyMessage;
  Bgm bgm;
  String scriptId;
  String script;
  WarStartType startType;
  int targetId;
  int eventId;
  String eventName;
  int lastQuestId;
  List<WarAdd> warAdds;
  List<NiceMap> maps;
  List<NiceSpot> spots;

  NiceWar({
    required this.id,
    required this.coordinates,
    required this.age,
    required this.name,
    required this.longName,
    this.banner,
    this.headerImage,
    required this.priority,
    required this.parentWarId,
    required this.materialParentWarId,
    required this.emptyMessage,
    required this.bgm,
    required this.scriptId,
    required this.script,
    required this.startType,
    required this.targetId,
    required this.eventId,
    required this.eventName,
    required this.lastQuestId,
    required this.warAdds,
    required this.maps,
    required this.spots,
  });

  factory NiceWar.fromJson(Map<String, dynamic> json) =>
      _$NiceWarFromJson(json);
}
