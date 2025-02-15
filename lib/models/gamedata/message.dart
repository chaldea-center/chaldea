import '_helper.dart';
import 'common.dart';

part '../../generated/models/gamedata/message.g.dart';

@JsonSerializable()
class BattleMessage {
  int id;
  int idx;
  int priority;
  List<CommonRelease> releaseConditions;
  int motionId;
  String message;
  Map<String, dynamic> script;

  BattleMessage({
    required this.id,
    required this.idx,
    required this.priority,
    this.releaseConditions = const [],
    this.motionId = 0,
    this.message = '',
    this.script = const {},
  });

  factory BattleMessage.fromJson(Map<String, dynamic> json) => _$BattleMessageFromJson(json);

  Map<String, dynamic> toJson() => _$BattleMessageToJson(this);
}

@JsonSerializable()
class BattleMessageGroup {
  int groupId;
  int probability;
  List<BattleMessage> messages;

  BattleMessageGroup({required this.groupId, required this.probability, this.messages = const []});

  factory BattleMessageGroup.fromJson(Map<String, dynamic> json) => _$BattleMessageGroupFromJson(json);

  Map<String, dynamic> toJson() => _$BattleMessageGroupToJson(this);
}
