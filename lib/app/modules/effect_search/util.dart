import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../common/filter_group.dart';

class EffectFilterUtil {
  static bool checkFuncTraits(BaseFunction func, FilterGroupData<int> data, {bool checkReduceHpVals = true}) {
    final traits = data.options;
    if (traits.isEmpty) return true;
    if (func.functvals.any((e) => traits.contains(e.id)) || func.traitVals.any((e) => traits.contains(e.id))) {
      return true;
    }
    for (final buff in func.buffs) {
      if (buff.ckSelfIndv.any((e) => traits.contains(e.id)) || buff.ckOpIndv.any((e) => traits.contains(e.id))) {
        return true;
      }
      if (checkReduceHpVals && buff.vals.any((e) => reduceHpTraits.contains(e.name) && traits.contains(e.id))) {
        return true;
      }
    }
    return false;
  }

  static const reduceHpTraits = [
    Trait.buffPoison,
    Trait.buffCurse,
    Trait.buffBurn,
  ];
  static FilterGroup buildTraitFilter(
    BuildContext context,
    FilterGroupData<int> data,
    VoidCallback onChanged, {
    List<Trait>? addTraits,
  }) {
    List<Trait> options = [
      Trait.cardQuick,
      Trait.cardArts,
      Trait.cardBuster,
      // Trait.cardExtra,
      // Trait.faceCard,
      // Trait.cardNP,
      // Trait.criticalHit,
      Trait.buffPositiveEffect,
      Trait.buffNegativeEffect,
      Trait.buffPoison,
      Trait.buffCurse,
      Trait.buffBurn,
      ...?addTraits,
    ];
    options.sort2((e) => e.id ~/ 1000 == 4 ? e.id - 5000 : e.id);
    return FilterGroup<int>(
      title: Text.rich(
        TextSpan(text: S.current.related_traits, children: const [
          TextSpan(
            text: '1*',
            style: TextStyle(fontFeatures: [FontFeature.enable('sups')]),
          )
        ]),
      ),
      options: options.map((e) => e.id).toList(),
      values: data,
      showMatchAll: false,
      showInvert: false,
      optionBuilder: (v) {
        String text = {
              Trait.cardQuick.id: 'Quick',
              Trait.cardArts.id: 'Arts',
              Trait.cardBuster.id: 'Buster',
              Trait.cardExtra.id: 'Extra',
            }[v] ??
            Transl.trait(v).l;
        if (text.startsWith('buff') && text.length > 4) {
          text = text.substring(4).trim();
        }
        return Text(text);
      },
      onFilterChanged: (value, _) {
        onChanged();
      },
    );
  }
}
