import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class ExtraAssetsPage extends StatelessWidget {
  final ExtraAssets assets;

  const ExtraAssetsPage({Key? key, required this.assets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 48),
      children: <Widget?>[
        _oneGroup(S.current.illustration, assets.charaGraph, 300),
        _oneGroup(S.current.card_asset_face, assets.faces, 80),
        _oneGroup(S.current.card_asset_status, assets.status, 120),
        _oneGroup(S.current.card_asset_command, assets.commands, 120),
        _oneGroup(S.current.card_asset_chara_figure, assets.charaFigure, 300),
        _oneGroup(S.current.card_asset_narrow_figure, assets.narrowFigure, 300),
        _oneGroup('equipFace', assets.equipFace, 50),
        // _oneGroup('Status', assets?.status),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? _oneGroup(String title, ExtraAssetsUrl assetsUrl, double height,
      [bool expanded = true]) {
    final urls = assetsUrl.allUrls.toList();
    if (urls.isEmpty) return null;
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
            itemCount: urls.length,
            itemBuilder: (context, index) => CachedImage(
              imageUrl: urls[index],
              onTap: () {
                FullscreenImageViewer.show(
                    context: context, urls: urls, initialPage: index);
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
