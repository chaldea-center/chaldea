import '../db.dart';
import 'item.dart';

class RecoverEntity {
  final int id;
  final RecoverTarget target;
  final int priority;
  final RecoverType recoverType;
  final int targetId; // stone-stoneShop.id, item-itemId
  final int num;

  const RecoverEntity({
    required this.id,
    required this.target,
    required this.priority,
    required this.recoverType,
    required this.targetId,
    required this.num,
  });

  String? get icon {
    switch (recoverType) {
      case RecoverType.commandSpell:
        return null;
      case RecoverType.stone:
        return Items.stone?.borderedIcon;
      case RecoverType.item:
        return db.gameData.items[targetId]?.borderedIcon;
    }
  }
}

enum RecoverType {
  commandSpell(1),
  stone(2),
  item(3);

  const RecoverType(this.value);
  final int value;
}

enum RecoverTarget {
  ap(1),
  rp(2);

  const RecoverTarget(this.value);
  final int value;
}

const apRecovers = [
  RecoverEntity(id: 1, target: RecoverTarget.ap, priority: 60, recoverType: RecoverType.stone, targetId: 2, num: 1),
  RecoverEntity(id: 2, target: RecoverTarget.ap, priority: 50, recoverType: RecoverType.item, targetId: 100, num: 1),
  RecoverEntity(id: 3, target: RecoverTarget.ap, priority: 40, recoverType: RecoverType.item, targetId: 101, num: 1),
  RecoverEntity(id: 4, target: RecoverTarget.ap, priority: 20, recoverType: RecoverType.item, targetId: 102, num: 1),
  RecoverEntity(id: 5, target: RecoverTarget.ap, priority: 30, recoverType: RecoverType.item, targetId: 104, num: 1),
  // RecoverEntity(id: 101, target: RecoverTarget.rp, priority: 50, recoverType: RecoverType.stone, targetId: 6, num: 1),
  // RecoverEntity(
  //     id: 102, target: RecoverTarget.rp, priority: 30, recoverType: RecoverType.item, targetId: 94013001, num: 1),
  // RecoverEntity(
  //     id: 103, target: RecoverTarget.rp, priority: 40, recoverType: RecoverType.item, targetId: 94013002, num: 1),
];

final mstRecovers = {for (final recover in apRecovers) recover.id: recover};
