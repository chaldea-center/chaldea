import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';

class GachaBanner extends StatelessWidget {
  final Region? region;
  final int? imageId;
  final String? url;

  const GachaBanner({super.key, required Region this.region, required int this.imageId}) : url = null;
  const GachaBanner.url({super.key, required String this.url})
      : region = null,
        imageId = null;

  @override
  Widget build(BuildContext context) {
    final url = this.url ?? AssetURL(region ?? Region.jp).summonBanner(imageId ?? 0);
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider("https://assets.chaldea.center/images/summon_bg.jpg"),
          fit: BoxFit.cover,
          alignment: Alignment(0.0, -0.6),
        ),
      ),
      child: CachedImage(
        imageUrl: url,
        showSaveOnLongPress: true,
        placeholder: (context, url) => const AspectRatio(aspectRatio: 1344 / 576),
        cachedOption: CachedImageOption(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorWidget: (context, url, error) => const AspectRatio(aspectRatio: 1344 / 576),
        ),
      ),
    );
  }
}
