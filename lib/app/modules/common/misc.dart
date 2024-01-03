import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class CommandCardWidget extends StatelessWidget {
  final CardType card;
  final double width;

  const CommandCardWidget({super.key, required this.card, required this.width});

  @override
  Widget build(BuildContext context) {
    if (![CardType.arts, CardType.buster, CardType.quick].contains(card)) {
      return Text(
        card.name.toTitle().breakWord,
        maxLines: 2,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      );
    }
    final cardName = card.name;
    final width2 = width * 0.8;
    final dx = (width - width2) / 2;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: width),
      child: SizedBox(
        width: width,
        height: width,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                left: dx,
                right: dx,
                top: dx,
                bottom: dx,
                child: db.getIconImage(
                  AssetURL.i.commandAtlas('card_bg_$cardName'),
                  fit: BoxFit.fill,
                  // width: 100,
                  // height: 100,
                ),
              ),
              Positioned.fill(
                child: db.getIconImage(
                  AssetURL.i.commandAtlas('card_icon_$cardName'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              Positioned.fill(
                left: dx,
                right: dx,
                bottom: 0,
                child: db.getIconImage(
                  AssetURL.i.commandAtlas('card_txt_$cardName'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
