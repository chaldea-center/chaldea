import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../packages/logger.dart';

class ValListDsc extends StatelessWidget {
  final BaseFunction func;
  final List<DataVals> mutaingVals;
  final List<DataVals> originVals;
  final int? selected; // 1-10
  const ValListDsc({
    super.key,
    required this.func,
    required this.mutaingVals,
    required this.originVals,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutTryBuilder(builder: (context, constraints) {
      int perLine = (constraints.maxWidth.isFinite && constraints.maxWidth > 600 && originVals.length > 5) ? 10 : 5;
      List<Widget> rows = [];
      int rowCount = (mutaingVals.length / perLine).ceil();
      for (int i = 0; i < rowCount; i++) {
        List<Widget> cols = [];
        for (int j = i * perLine; j < (i + 1) * perLine; j++) {
          final vals = mutaingVals.getOrNull(j);
          Widget child;
          if (vals == null) {
            child = const SizedBox();
          } else {
            child = ValDsc(
              func: func,
              vals: vals,
              originVals: originVals.getOrNull(j),
              ignoreRate: false,
              color: j == 5 || j == 9 ? Theme.of(context).colorScheme.secondary : null,
              inList: true,
            );
          }
          child = Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: child,
          );
          if (selected != null && selected! - 1 == j) {
            child = DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(180)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: child,
            );
          }
          cols.add(child);
        }
        rows.add(Row(children: cols.map((e) => Expanded(child: e)).toList()));
      }
      if (rows.isEmpty) return const SizedBox();
      if (rows.length == 1) return rows.first;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      );
    });
  }
}

class ValDsc extends StatelessWidget {
  final BaseFunction func;
  final DataVals vals;
  final DataVals? originVals;
  final bool? ignoreRate;
  final bool ignoreCount;
  final Color? color;
  final bool inList;
  final bool supportOnly;

  ValDsc({
    super.key,
    required this.func,
    required this.vals,
    this.originVals,
    this.color,
    this.ignoreRate,
    this.ignoreCount = false,
    this.inList = false,
    this.supportOnly = false,
  });

  final List<String> parts = [];

  @override
  Widget build(BuildContext context) {
    describeFunc();
    TextStyle style = TextStyle(color: color, fontSize: 13);
    if (parts.isEmpty) {
      style = style.copyWith(
        fontStyle: FontStyle.italic,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );
    }
    final text = parts.isEmpty ? vals.Value?.toString() ?? empty : parts.where((e) => e.isNotEmpty).join(', ');
    return InkWell(
      child: Text(
        supportOnly ? '${Transl.special.funcSupportOnly} $text' : text,
        textAlign: supportOnly ? TextAlign.end : TextAlign.center,
        style: style,
      ),
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: SimpleCancelOkDialog(
                title: const Text('Data Vals'),
                content: JsonViewer((originVals ?? vals).toJson(sort: false), defaultOpen: true),
                scrollable: true,
                hideCancel: true,
                contentPadding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 12.0, 24.0),
              ),
            );
          },
        );
      },
    );
  }

  static void _addInt(final List<String> parts, int? value, [String Function(String)? post]) {
    if (value == null || value == 0) return;
    if (value == 966756) {
      logger.e(value.toString());
    }
    String text = value.toString();
    if (post != null) text = post(text);
    parts.add(text);
  }

  static String? _toPercent(int? value, [int base = 1]) {
    if (value == null) return null;
    int _intValue = value ~/ base;
    double _floatValue = value / base;
    if (_intValue.toDouble() == _floatValue) {
      return '$_intValue';
    } else {
      return _floatValue.toString().trimCharRight('0');
    }
  }

  static void _addPercent(final List<String> parts, int? value, int base, [String Function(String)? post]) {
    if (value == null || value == 0) return;
    String text = '${_toPercent(value, base)!}%';
    if (post != null) {
      text = post(text);
    }
    parts.add(text);
  }

  // return null if not processed
  void describeFunc() {
    parts.clear();

    // conditions
    if (vals.StarHigher != null) {
      parts.add("($kStarChar≥${vals.StarHigher})");
    }
    // end conditions

    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort ||
        func.funcType == FuncType.addFieldChangeToField) {
      describeBuff(parts, func.buffs.first, vals, inList: inList, ignoreCount: ignoreCount);
      if (vals.UseRate != null) {
        _addPercent(parts, vals.UseRate, 10, (v) => Transl.special.funcValActChance(v));
      }
    } else if (func.funcType == FuncType.gainHpFromTargets) {
      _addInt(parts, vals.DependFuncVals?.Value);
    } else if (func.funcType == FuncType.gainNpFromTargets) {
      // Absorb Value, charge Value2
      _addPercent(parts, vals.DependFuncVals?.Value2 ?? vals.DependFuncVals?.Value, 100);
    } else if (func.funcType == FuncType.absorbNpturn) {
      final v2 = vals.DependFuncVals?.Value2 ?? vals.DependFuncVals?.Value;
      if (v2 != null) {
        _addInt(parts, v2 ~/ 100);
      }
    } else if (func.funcType == FuncType.subState) {
      if (vals.Value != null && vals.Value! > 0) {
        _addInt(parts, vals.Value);
      } else if (vals.Value2 != null && vals.Value2! > 0) {
        _addInt(parts, vals.Value2);
      } else {
        // parts.add('All');
      }
    } else {
      if (vals.Value != null) {
        switch (func.funcType) {
          case FuncType.lossHp:
          case FuncType.lossHpSafe:
          case FuncType.lossHpPer:
          case FuncType.lossHpPerSafe:
            if (vals.Value2 != null) {
              parts.add('${vals.Value}~${vals.Value2}');
            } else {
              parts.add(vals.Value.toString());
            }
            break;
          case FuncType.transformServant:
            // already added in func text
            break;
          default:
            final base = kFuncValPercentType[func.funcType];
            if (base != null) {
              _addPercent(parts, vals.Value, base);
            } else {
              parts.add(vals.Value.toString());
            }
            break;
        }
      }
      if (vals.Value2 != null) {
        // if (func.funcType == FuncType.damageNpIndividualSum) {
        //   _addPercent(vals.Value2, 10);
        // }
      }
      if (vals.Correction != null) {
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpRare:
          case FuncType.damageNpStateIndividualFix:
            _addPercent(parts, vals.Correction, 10, (s) => '×$s');
            break;
          case FuncType.damageNpIndividualSum:
            if (vals.Value2 != null) {
              parts.add('${_toPercent(vals.Value2, 10)}%+N×${_toPercent(vals.Correction, 10)}%');
            } else {
              _addPercent(parts, vals.Correction, 10, (s) => '×$s');
            }
            break;
          default:
            parts.add(vals.Correction.toString());
            break;
        }
      }
      if (vals.Target != null) {
        switch (func.funcType) {
          case FuncType.damageNpHpratioLow:
            _addPercent(parts, vals.Target, 10);
            break;
          case FuncType.damageNpIndividual:
          case FuncType.damageNpRare:
          case FuncType.damageNpStateIndividualFix:
          case FuncType.damageNpIndividualSum:
          case FuncType.servantFriendshipUp:
            break;
          default:
            parts.join(vals.Target.toString());
            break;
        }
      }
      if (!ignoreCount && vals.Count != null && vals.Count! > 0) {
        _addInt(parts, vals.Count, (v) => Transl.special.funcValCountTimes(vals.Count!));
      }
      if (vals.AddCount != null) {
        if (func.funcType == FuncType.eventDropRateUp) {
          _addPercent(parts, vals.AddCount, 10);
        } else {
          _addInt(parts, vals.AddCount);
        }
      }
      if (vals.UseRate != null) {
        _addPercent(parts, vals.UseRate, 10, (v) => Transl.special.funcValActChance(v));
      }
      if (vals.RateCount != null) {
        switch (func.funcType) {
          case FuncType.qpDropUp:
          case FuncType.servantFriendshipUp:
          case FuncType.userEquipExpUp:
          case FuncType.eventPointUp:
          case FuncType.eventFortificationPointUp:
          case FuncType.expUp:
            _addPercent(parts, vals.RateCount, 10);
            break;
          case FuncType.enemyEncountRateUp:
          case FuncType.enemyEncountCopyRateUp:
            _addPercent(parts, vals.RateCount, 10);
            break;
          default:
            _addInt(parts, vals.RateCount);
        }
      }
      if (vals.DropRateCount != null) {
        _addPercent(parts, vals.DropRateCount, 10);
      }
      if (vals.Individuality != null) {
        // if ([].contains(func.funcType)) {
        //   parts.add(Transl.trait(vals.Individuality!).l);
        // }
      }
    }
    _maybeAddRate();
  }

  final empty = '';

  static void describeBuff(
    final List<String> parts,
    final Buff buff,
    final DataVals vals, {
    final bool inList = false,
    final bool ignoreCount = false,
  }) {
    final base = buff.percentBase;
    final trigger = kBuffValueTriggerTypes[buff.type];
    String _val(int? v) {
      if (v == null) return '';
      if (base == null) return '$v';
      return '${_toPercent(v, base)!}%';
    }

    bool _valueUsed = false;

    if (vals.ParamAddValue != null) {
      parts.add('${_val(vals.Value)}+${_val(vals.ParamAddValue)}×N');
      _valueUsed = true;
    }
    if (vals.ParamAdd != null) {
      parts.add('${_val(vals.Value)}+${_val(vals.ParamAdd)}×N');
      _valueUsed = true;
    }
    if (base != null) {
      if (!_valueUsed) _addPercent(parts, vals.Value, base);
      // return;
    } else if (trigger != null) {
      final triggerVal = trigger(vals);
      if (triggerVal.level != null) {
        parts.add('Lv.${triggerVal.level}');
      } else if (triggerVal.skill != null) {
        parts.add('${triggerVal.skill}');
      }
      if (buff.type == BuffType.counterFunction && vals.CounterOc != null) {
        parts.add('OC${vals.CounterOc}');
      }
      return;
    } else if (buff.type == BuffType.changeCommandCardType && vals.Value != null) {
      final cardName = kCardTypeMapping[vals.Value]?.name.toTitle() ?? vals.Value.toString();
      parts.add(cardName);
      return;
    } else if ([
          BuffType.addIndividuality,
          BuffType.subIndividuality,
          BuffType.fieldIndividuality,
          // BuffType.subFieldIndividuality, // in TargetList
        ].contains(buff.type) &&
        vals.Value != null) {
      // parts.add(Transl.trait(vals.Value!).l);
      parts.add('');
      return;
    } else if ([
          BuffType.toFieldChangeField,
          // BuffType.toFieldSubIndividualityField,  // may be in TargetList
        ].contains(buff.type) &&
        vals.FieldIndividuality != null) {
      // parts.add(Transl.trait(vals.FieldIndividuality!).l);
      parts.add('');
      return;
    } else {
      if (!_valueUsed) _addInt(parts, vals.Value);
    }
    if (vals.RatioHPHigh != null || vals.RatioHPLow != null) {
      final ratios = [vals.RatioHPHigh ?? 0, vals.RatioHPLow ?? 0].toList();
      final ratioStrings = ratios.map((e) => _toPercent(e, base ?? 1)).toList();
      parts.add('${ratioStrings.join('-')}%');
    }
    if (!inList &&
        (vals.RatioHPRangeHigh != null ||
            vals.RatioHPRangeLow != null ||
            vals.RatioHPHigh != null ||
            vals.RatioHPLow != null)) {
      final hpRatios = [vals.RatioHPRangeHigh ?? 1000, vals.RatioHPRangeLow ?? 0].toList();
      final hpRatiosStrings = hpRatios.map((e) => _toPercent(e, 10)).toList();
      parts.add('[HP ${hpRatiosStrings.join('-')}%]');
    }

    if (!ignoreCount && vals.Count != null && vals.Count! > 0) {
      _addInt(parts, vals.Count, (v) => Transl.special.funcValCountTimes(vals.Count!));
    }
  }

  void _maybeAddRate() {
    if (vals.Rate != null) {
      final _jsonVals = vals.toJson().keys.toSet();
      // _jsonVals.removeAll(['Turn', 'Count']);
      if (ignoreRate == false ||
          (_jsonVals.length == 1 && _jsonVals.first == 'Rate' && ignoreRate != true) ||
          vals.Rate != 1000 ||
          [FuncType.instantDeath, FuncType.forceInstantDeath].contains(func.funcType)) {
        parts.add(Transl.special.funcValChance('${_toPercent(vals.Rate, 10)}%'));
      }
    }

    if (vals.ActSetWeight != null) {
      _addPercent(parts, vals.ActSetWeight, 1, (v) {
        String s = Transl.special.funcValWeight(v);
        if (vals.ActSet != null) {
          s = '[${vals.ActSet}]$s';
        }
        return s;
      });
    }
  }
}
