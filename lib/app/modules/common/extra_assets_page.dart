import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ExtraAssetsPage extends StatelessWidget {
  final ExtraAssets assets;
  final List<String> aprilFoolAssets;
  final List<String> spriteModels;
  final bool scrollable;
  final Iterable<String> Function(ExtraAssetsUrl urls)? getUrls;

  const ExtraAssetsPage({
    Key? key,
    required this.assets,
    this.aprilFoolAssets = const [],
    this.spriteModels = const [],
    this.scrollable = true,
    this.getUrls,
  }) : super(key: key);

  Iterable<String> _getUrls(ExtraAssetsUrl urls) {
    if (getUrls != null) return getUrls!(urls);
    return urls.allUrls;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget?>[
      _oneGroup(
          S.current.illustration,
          [
            ..._getUrls(assets.charaGraph),
            ..._getUrls(assets.charaGraphEx),
            ..._getUrls(assets.charaGraphChange),
            ...aprilFoolAssets
          ],
          300),
      _oneGroup(
          S.current.card_asset_face,
          [
            ..._getUrls(assets.faces),
            ..._getUrls(assets.facesChange),
          ],
          80),
      _oneGroup(S.current.card_asset_status, _getUrls(assets.status), 120),
      _oneGroup(S.current.card_asset_command, _getUrls(assets.commands), 120),
      _oneGroup(
          S.current.card_asset_chara_figure, _getUrls(assets.charaFigure), 300),
      _oneGroup(
        'Forms',
        [
          for (final form in assets.charaFigureForm.values) ..._getUrls(form),
        ],
        300,
      ),
      _oneGroup(
        'Characters',
        [
          for (final form in assets.charaFigureMulti.values) ..._getUrls(form),
        ],
        300,
      ),
      _oneGroup(
        S.current.card_asset_narrow_figure,
        [
          ..._getUrls(assets.narrowFigure),
          ..._getUrls(assets.narrowFigureChange),
        ],
        300,
      ),
      _oneGroup('equipFace', _getUrls(assets.equipFace), 50),
      _oneGroup('${S.current.sprites} (Mooncell)', spriteModels, 300),
      spriteViewer(),
    ].whereType<Widget>().toList();
    if (scrollable) {
      return ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 48),
        children: children,
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }
  }

  Widget? _oneGroup(String title, Iterable<String> urls, double height,
      [bool expanded = true]) {
    // final urls = assetsUrl.allUrls.toList();
    final _urls = urls.toList();
    if (_urls.isEmpty) return null;
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) => Text(title),
      expandElevation: 0,
      contentBuilder: (context) => SizedBox(
        height: height,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _urls.length,
            itemBuilder: (context, index) => CachedImage(
              imageUrl: _urls[index],
              onTap: () {
                FullscreenImageViewer.show(
                    context: context, urls: _urls, initialPage: index);
              },
              showSaveOnLongPress: true,
            ),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
          ),
        ),
      ),
    );
  }

  Widget? spriteViewer() {
    if (assets.spriteModel.allUrls.isEmpty) return null;
    Map<String, List<int>> ascensionModels = {};
    Map<String, List<int>> costumeModels = {};
    final reg = RegExp(r'(?:/Servants/)(\d+)(?:/)');
    assets.spriteModel.ascension?.forEach((key, value) {
      final id = reg.firstMatch(value)?.group(1);
      if (id == null) return;
      ascensionModels.putIfAbsent(id, () => []).add(key);
    });
    assets.spriteModel.costume?.forEach((key, value) {
      final id = reg.firstMatch(value)?.group(1);
      if (id == null) return;
      costumeModels.putIfAbsent(id, () => []).add(key);
    });

    Widget _tile(String title, String key) {
      return ListTile(
        dense: true,
        title: Text('ꔷ $title'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => launch('https://katboi01.github.io/FateViewer/?id=$key',
            external: true),
      );
    }

    List<Widget> children = [];
    ascensionModels.forEach((key, ascensions) {
      children.add(
          _tile('${S.current.ascension_short} ${ascensions.join("&")}', key));
    });
    costumeModels.forEach((key, costumeIds) {
      children.add(_tile(
          costumeIds
              .map((e) => db.gameData.costumesById[e]?.lName.l ?? 'Costume $e')
              .join('& '),
          key));
    });

    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) =>
          Text('${S.current.sprites} (katboi01\'s Fate Viewer)'),
      expandElevation: 0,
      contentBuilder: (context) =>
          Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
