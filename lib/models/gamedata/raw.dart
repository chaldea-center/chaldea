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

abstract class ExtraCharaImageBase<T> {
  int get svtId;
  List<T> get imageIds;
}

@JsonSerializable()
class ExtraCharaFigure implements ExtraCharaImageBase<int> {
  @override
  int svtId;
  List<int> charaFigureIds;

  @override
  List<int> get imageIds => charaFigureIds;

  ExtraCharaFigure({
    required this.svtId,
    List<int>? charaFigureIds,
  }) : charaFigureIds = charaFigureIds ?? [];

  factory ExtraCharaFigure.fromJson(Map<dynamic, dynamic> json) => _$ExtraCharaFigureFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraCharaFigureToJson(this);
}

@JsonSerializable()
class ExtraCharaImage implements ExtraCharaImageBase<String> {
  @override
  int svtId;
  @override
  List<String> imageIds;

  ExtraCharaImage({
    required this.svtId,
    List<dynamic>? imageIds,
  }) : imageIds = imageIds?.map((e) => e.toString()).toList() ?? [];

  factory ExtraCharaImage.fromJson(Map<dynamic, dynamic> json) => _$ExtraCharaImageFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraCharaImageToJson(this);
}
