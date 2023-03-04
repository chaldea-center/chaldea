import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/craft_essence/craft.dart';
import 'package:chaldea/app/modules/servant/servant.dart';
import 'package:chaldea/models/models.dart';

class EnemyDetailPage extends StatefulWidget {
  final int id;
  const EnemyDetailPage({super.key, required this.id});

  @override
  State<EnemyDetailPage> createState() => _EnemyDetailPageState();
}

class _EnemyDetailPageState extends State<EnemyDetailPage> {
  Servant? svt;
  CraftEssence? ce;
  @override
  void initState() {
    super.initState();
    final entity = db.gameData.entities[widget.id];
    if (entity?.type == SvtType.servantEquip) {
      AtlasApi.ce(widget.id).then((value) {
        ce = value;
        if (mounted) setState(() {});
      });
    } else {
      AtlasApi.svt(widget.id).then((value) {
        svt = value;
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (svt != null) {
      return ServantDetailPage(svt: svt);
    }
    if (ce != null) {
      return CraftDetailPage(ce: ce!);
    }
    final _svt = db.gameData.servantsById[widget.id] ?? db.gameData.entities[widget.id];
    if (_svt == null) return ServantDetailPage(id: widget.id); // NotFound
    return Scaffold(
      appBar: AppBar(title: Text(_svt.lName.l)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
