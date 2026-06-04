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

@JsonSerializable()
class BattleScript {
  int id;
  int playOrder;
  int idx;
  BattleScriptActionType battleScriptAction;
  BattleScriptDetail? script;

  BattleScript({required this.id, this.playOrder = 0, this.idx = 0, this.battleScriptAction = .unknown, this.script});

  factory BattleScript.fromJson(Map<String, dynamic> json) => _$BattleScriptFromJson(json);

  Map<String, dynamic> toJson() => _$BattleScriptToJson(this);
}

@JsonSerializable()
class BattleScriptDetail with DataScriptBase {
  BattleScriptDetail();

  factory BattleScriptDetail.fromJson(Map<String, dynamic> json) => _$BattleScriptDetailFromJson(json)..setSource(json);

  Map<String, dynamic> toJson() => Map.from(source)..addAll(_$BattleScriptDetailToJson(this));

  // message
  int? get battleMessageGroupId => getScript('battleMessageGroupId');
  int? get battleMessageId => getScript('battleMessageId');
  String? get messageText => getScript('messageText');

  // Ai Act
  int? get aiActId => getScript('aiActId');
  BattleScriptActionActorType? get aiActActorType {
    final int? type = getScript('type');
    if (type == null) return null;
    return BattleScriptActionActorType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => BattleScriptActionActorType.none,
    );
  } // BattleScriptActionActorType

  int? get aiActIndividuality => getScript('individuality'); // AiActIndividuality
  // Map? get aiScript => getScript('aiScript'); // AiBaseEntityScript

  // cutin
  int? get cutinId => getScript('cutinId');
  int? get cutInCamPlayerAll => getScript('cutInCamPlayerAll'); // default -1
  int? get cutInMessageMode => getScript('cutInMessageMode'); // default -1
  String? get cutInMessageText => getScript('cutInMessageText');
  String? get cutInPrefabInfo => getScript('cutInPrefabInfo'); // separator ","
  String? get cutInVoices => getScript('cutInVoices'); // separator "/"

  // camera
  // List<Map>? get cameraTargetData => getScript("cameraTargetData");
  // String? get cameraMotionEventName => getScript('eventName');
  // int? get waitTime => getScript('waitTime');
  // int? get fov => getScript('fov');
  // int? get dispTime => getScript('dispTime');

  // others
  // int? get isOnlyFirst => getScript('isOnlyFirst');
  String? get charaVoice => getScript('charaVoice');
}

enum BattleScriptActionType {
  unknown(0),
  aiAct(1),
  wait(2),
  cutIn(3),
  moveCamera(4),
  message(5),
  playVoice(6),
  normalSpeed(7),
  resumeSpeed(8);

  const BattleScriptActionType(this.value);
  final int value;
}

enum BattleScriptActionActorType {
  none(0),
  field(1),
  enemy(2),
  player(3),
  npc(4);

  const BattleScriptActionActorType(this.value);
  final int value;
}
