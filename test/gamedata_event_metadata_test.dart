import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';

void main() {
  test('opening movie decoding tolerates unknown display metadata', () {
    final movie = NiceOpeningMovie.fromJson({
      'id': 1,
      'movie': 'https://example.com/movie.mp4',
      'materialPosType': 'futurePlacement',
      'script': {'timing': 'futureTiming'},
    });

    expect(movie.movie, 'https://example.com/movie.mp4');
    expect(movie.materialPosType, NiceOpeningMovieMaterialPosType.none);
    expect(movie.script.timing, isNull);
  });

  test('resolved event point counts use their owning event', () {
    const ownerId = 80101;
    const otherId = 80102;
    const resolvedItemId = 94990001;
    const unresolvedItemId = 94990002;
    final original = db.gameData;
    addTearDown(() => db.gameData = original);
    db.gameData = GameData(
      events: {
        ownerId: Event(id: ownerId, name: 'Owner', startedAt: 1, endedAt: 60),
        otherId: Event(id: otherId, name: 'Other', startedAt: 2, endedAt: 61),
      },
      items: {
        resolvedItemId: Item(id: resolvedItemId, type: ItemType.eventPoint, icon: '', eventId: ownerId),
        unresolvedItemId: Item(id: unresolvedItemId, type: ItemType.eventPoint, icon: ''),
      },
    );
    final data = MasterDataManager();
    data.userEventPoint.updated([
      {'eventId': otherId, 'groupId': 0, 'value': 37},
    ]);
    expect(data.getItemOrSvtNum(resolvedItemId, eventIds: [otherId]), 0);
    expect(data.getItemOrSvtNum(unresolvedItemId, eventIds: [otherId]), 37);

    data.userEventPoint.updated([
      {'eventId': ownerId, 'groupId': 0, 'value': 12},
    ]);
    expect(data.getItemOrSvtNum(resolvedItemId, eventIds: [otherId]), 12);
  });
}
