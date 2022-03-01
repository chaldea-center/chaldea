import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ExtraAssetsPage extends StatelessWidget {
  final ExtraAssets assets;

  const ExtraAssetsPage({Key? key, required this.assets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 48),
      children: <Widget?>[
        _oneGroup(S.current.illustration, assets.charaGraph, 300),
        _oneGroup('faces', assets.faces, 80),
        _oneGroup('Status', assets.status, 120),
        _oneGroup('Commands', assets.commands, 120),
        _oneGroup('charaFigure', assets.charaFigure, 300),
        _oneGroup('narrowFigure', assets.narrowFigure, 300),
        _oneGroup('equipFace', assets.equipFace, 50),
        // _oneGroup('Status', assets.status),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? _oneGroup(String title, ExtraAssetsUrl assetsUrl, double height,
      [bool expanded = true]) {
    final urls = assetsUrl.allUrls.toList();
    if (urls.isNotEmpty) {
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
    return null;
  }
}
