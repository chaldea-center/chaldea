import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/multi_entry.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CreatorDetail extends StatelessWidget {
  final String _name;
  final bool _isCV;

  const CreatorDetail.cv({super.key, required String name}) : _isCV = true, _name = name;
  const CreatorDetail.illust({super.key, required String name}) : _isCV = false, _name = name;

  List<String> _split(String name) {
    return name.split(RegExp(r'[&＆]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Transl<String, String> lName([String? name]) =>
      _isCV ? Transl.cvNames(name ?? _name) : Transl.illustratorNames(name ?? _name);
  bool ckSvt(Servant svt) {
    // No.83 Solomon
    // if (_name.isEmpty) return false;
    if (_isCV) {
      return svt.profile.cv == _name || _split(svt.profile.cv).contains(_name);
    } else {
      return svt.profile.illustrator == _name || _split(svt.profile.illustrator).contains(_name);
    }
  }

  bool ckCE(CraftEssence ce) {
    if (_isCV) {
      // most of CEs has no cv
      if (_name.isEmpty) return false;
      return ce.profile.cv == _name || _split(ce.profile.cv).contains(_name);
    } else {
      return ce.profile.illustrator == _name || _split(ce.profile.illustrator).contains(_name);
    }
  }

  bool ckCC(CommandCode cc) {
    if (_name.isEmpty) return false;
    if (_isCV) return false;
    return cc.illustrator == _name || _split(cc.illustrator).contains(_name);
  }

  @override
  Widget build(BuildContext context) {
    List<String> subCreators = _split(_name);
    List<Widget> children = [];
    final table = CustomTable(
      selectable: true,
      children: <Widget>[
        CustomTableRow(
          children: [
            TableCellData(
              child: Text(
                lName().l,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              isHeader: true,
            ),
          ],
        ),
        if (!Transl.isJP)
          CustomTableRow(
            children: [TableCellData(text: _name, textAlign: TextAlign.center)],
          ),
        if (!Transl.isEN)
          CustomTableRow(
            children: [TableCellData(text: lName().na, textAlign: TextAlign.center)],
          ),
        if (subCreators.length > 1) ...[
          CustomTableRow.fromTexts(texts: const ['Related'], isHeader: true),
          CustomTableRow.fromChildren(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: divideList([
                  for (final creator in subCreators)
                    Text.rich(
                      MultiDescriptor.inkWell(
                        context: context,
                        onTap: () {
                          if (_isCV) {
                            router.pushPage(CreatorDetail.cv(name: creator));
                          } else {
                            router.pushPage(CreatorDetail.illust(name: creator));
                          }
                        },
                        text: _isCV ? Transl.cvNames(creator).l : Transl.illustratorNames(creator).l,
                      ),
                    ),
                ], const Text(' / ')),
              ),
            ],
          ),
        ],
      ],
    );
    children.add(table);

    final servants = db.gameData.servantsNoDup.values.where((svt) => ckSvt(svt)).toList();
    final ces = db.gameData.allCraftEssences.where((ce) => ckCE(ce)).toList();
    final ccs = db.gameData.commandCodes.values.where((cc) => ckCC(cc)).toList();
    servants.sort2((e) => e.collectionNo);
    ces.sort2((e) => e.collectionNo);
    ccs.sort2((e) => e.collectionNo);
    if (servants.isNotEmpty) {
      children.addAll([
        ListTile(title: Text(S.current.servant)),
        SharedBuilder.grid<Servant>(
          context: context,
          items: servants,
          builder: (context, svt) => svt.iconBuilder(context: context, width: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]);
    }
    if (ces.isNotEmpty) {
      children.addAll([
        ListTile(title: Text(S.current.craft_essence)),
        SharedBuilder.grid<CraftEssence>(
          context: context,
          items: ces,
          builder: (context, ce) => ce.iconBuilder(context: context, width: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]);
    }
    if (ccs.isNotEmpty) {
      children.addAll([
        ListTile(title: Text(S.current.command_code)),
        SharedBuilder.grid<CommandCode>(
          context: context,
          items: ccs,
          builder: (context, cc) => cc.iconBuilder(context: context, width: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]);
    }
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${_isCV ? S.current.info_cv : S.current.illustrator}: ${lName().l}',
          minFontSize: 12,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(children: children),
    );
  }
}
