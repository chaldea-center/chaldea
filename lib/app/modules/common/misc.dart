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
                child: Image.asset(
                  'res/assets/card_bg_$cardName.png',
                  // width: 100,
                  // height: 100,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned.fill(
                child: Image.asset(
                  'res/assets/card_icon_$cardName.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Positioned.fill(
                left: dx,
                right: dx,
                bottom: 0,
                child: Image.asset(
                  'res/assets/card_txt_$cardName.png',
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
