import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class ExtraAssetsPage extends StatelessWidget {
  final ExtraAssets assets;
  final List<String> aprilFoolAssets;
  final List<String> spriteModels;

  const ExtraAssetsPage({
    Key? key,
    required this.assets,
    this.aprilFoolAssets = const [],
    this.spriteModels = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 48),
      children: <Widget?>[
        _oneGroup(S.current.illustration,
            [...assets.charaGraph.allUrls, ...aprilFoolAssets], 300),
        _oneGroup(S.current.card_asset_face, assets.faces.allUrls, 80),
        _oneGroup(S.current.card_asset_status, assets.status.allUrls, 120),
        _oneGroup(S.current.card_asset_command, assets.commands.allUrls, 120),
        _oneGroup(
            S.current.card_asset_chara_figure, assets.charaFigure.allUrls, 300),
        _oneGroup(S.current.card_asset_narrow_figure,
            assets.narrowFigure.allUrls, 300),
        _oneGroup('equipFace', assets.equipFace.allUrls, 50),
        _oneGroup(S.current.sprites, spriteModels, 300),
        // _oneGroup('Status', assets?.status),
      ].whereType<Widget>().toList(),
    );
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
}
