import '_helper.dart';

part '../../generated/models/gamedata/raw.g.dart';

@JsonSerializable(createToJson: false)
class MstEvent {
  int id;
  int type;
  String name;
  String shortName;
  // int noticeAt;
  int startedAt;
  int endedAt;
  int finishedAt;

  MstEvent({
    required this.id,
    required this.type,
    this.name = "",
    this.shortName = "",
    required this.startedAt,
    required this.endedAt,
    required this.finishedAt,
  });
  factory MstEvent.fromJson(Map<String, dynamic> json) => _$MstEventFromJson(json);
}

@JsonSerializable()
class ExtraCharaFigure {
  int svtId;
  List<int> charaFigureIds;
  ExtraCharaFigure({
    required this.svtId,
    List<int>? charaFigureIds,
  }) : charaFigureIds = charaFigureIds ?? [];

  factory ExtraCharaFigure.fromJson(Map<dynamic, dynamic> json) => _$ExtraCharaFigureFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraCharaFigureToJson(this);
}

@JsonSerializable()
class ExtraCharaImage {
  int svtId;
  // int or string
  List<dynamic> imageIds;

  ExtraCharaImage({
    required this.svtId,
    List<dynamic>? imageIds,
  }) : imageIds = imageIds ?? [];

  factory ExtraCharaImage.fromJson(Map<dynamic, dynamic> json) => _$ExtraCharaImageFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraCharaImageToJson(this);
}
