import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../common/filter_group.dart';

class EffectFilterUtil {
  static bool checkFuncTraits(BaseFunction func, FilterGroupData<int> data, {bool checkReduceHpVals = true}) {
    final traits = data.options;
    if (traits.isEmpty) return true;
    if (func.functvals.any((e) => traits.contains(e.abs())) || func.traitVals.any((e) => traits.contains(e.abs()))) {
      return true;
    }
    for (final buff in func.buffs) {
      if (buff.ckSelfIndv.any((e) => traits.contains(e.abs())) || buff.ckOpIndv.any((e) => traits.contains(e.abs()))) {
        return true;
      }
      if (checkReduceHpVals && buff.vals.any((e) => reduceHpTraits.contains(e.abs()) && traits.contains(e.abs()))) {
        return true;
      }
    }
    return false;
  }

  static final reduceHpTraits = [Trait.buffPoison.value, Trait.buffCurse.value, Trait.buffBurn.value];
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
      Trait.cardExtra,
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
    options.sort2((e) => e.value ~/ 1000 == 4 ? e.value - 5000 : e.value);
    return FilterGroup<int>(
      title: Text.rich(
        TextSpan(
          text: S.current.related_traits,
          children: const [
            TextSpan(
              text: '1*',
              style: TextStyle(fontFeatures: [FontFeature.enable('sups')]),
            ),
          ],
        ),
      ),
      options: options.map((e) => e.value).toList(),
      values: data,
      showMatchAll: false,
      showInvert: false,
      optionBuilder: (v) {
        String text =
            {
              Trait.cardQuick.value: 'Quick',
              Trait.cardArts.value: 'Arts',
              Trait.cardBuster.value: 'Buster',
              Trait.cardExtra.value: 'Extra',
            }[v] ??
            Transl.traitName(v);
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
