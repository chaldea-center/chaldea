import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';

void main() {
  test('spoiler filtering keeps dedicated NP materials available for owned cards', () {
    const baseId = 304300;
    const materialId = 304301;
    const hiddenServantId = 304400;
    final original = db.gameData;
    addTearDown(() => db.gameData = original);
    db.gameData = GameData(
      version: DataVersion(timestamp: 1),
      spoilerRegion: Region.na,
      mappingData: MappingData(entityRelease: MappingList(na: [baseId])),
      servants: [Servant(id: baseId, appendPassive: [])],
      entities: {
        baseId: BasicServant(id: baseId, face: ''),
        materialId: BasicServant(id: materialId, face: '', type: SvtType.svtMaterialTd),
        hiddenServantId: BasicServant(id: hiddenServantId, face: ''),
      },
    );
    expect(db.gameData.entities, isNot(contains(hiddenServantId)));
    expect(db.gameData.servantsById, isNot(contains(materialId)));
    expect(Servant.getMaterialTdSvtId(baseId), materialId);
    expect(Servant.getBaseSvtId(materialId), baseId);

    final data = MasterDataManager();
    data.userSvt.updated([
      {'id': 1, 'svtId': baseId, 'treasureDeviceLv1': 1},
      {'id': 2, 'svtId': materialId, 'treasureDeviceLv1': 1},
    ]);
    expect(data.userSvt[2]?.dbEntity?.type, SvtType.svtMaterialTd);
    expect(data.hasTdUpgradeCopy(baseId), isTrue);
    expect(data.hasTdUpgradeCopy(materialId), isTrue);
  });
}
