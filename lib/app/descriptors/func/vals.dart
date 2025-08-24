import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ValListDsc extends StatelessWidget {
  final BaseFunction func;
  final List<DataVals> mutaingVals;
  final List<DataVals> originVals;
  final int? selected; // 1-10
  const ValListDsc({super.key, required this.func, required this.mutaingVals, required this.originVals, this.selected});

  @override
  Widget build(BuildContext context) {
    return LayoutTryBuilder(
      builder: (context, constraints) {
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
                color: j == 5 || j == 9 ? AppTheme(context).tertiary : null,
                inList: true,
              );
            }
            child = Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: child);
            if (selected != null && selected! - 1 == j) {
              child = DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme(context).tertiaryContainer.withAlpha(180)),
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
        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      },
    );
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
      style = style.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodySmall?.color);
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
              data: ThemeData.light(useMaterial3: Theme.of(context).useMaterial3),
              child: SimpleConfirmDialog(
                title: const Text('Data Vals'),
                content: JsonViewer((originVals ?? vals).toJson(sort: false), defaultOpen: true),
                scrollable: true,
                showCancel: false,
                contentPadding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 12.0, 24.0),
              ),
            );
          },
        );
      },
    );
  }

  static void _addInt(final List<String> parts, int? value, {String Function(String)? post}) {
    if (value == null) return;
    String text = value.toString();
    // if (maxValue != null) text = '$text~$maxValue';
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

  static void _addPercent(final List<String> parts, int? value, int base, {String Function(String)? post}) {
    if (value == null) return;
    String text = '${_toPercent(value, base)}';
      // if (maxValue != null) text = '$text~${_toPercent(maxValue, base)}';
      text += '%';
    if (post != null) {
      text = post(text);
    }
    parts.add(text);
  }

  // return null if not processed
  void describeFunc() {
    parts.clear();

    int? k = vals.CondParamAddValue ?? vals.CondParamRangeMaxValue;
    bool isPercentK = (vals.CondParamRangeMaxValue ?? 0) != 0;
    int? valueMaxValue = vals.CondParamRangeMaxValue ?? vals.CondParamAddMaxValue;
    if (valueMaxValue != null) valueMaxValue = (vals.Value ?? 0) + valueMaxValue;

    // conditions
    if (vals.StarHigher != null) {
      parts.add("($kStarChar≥${vals.StarHigher})");
    }
    if (vals.TriggeredTargetHpRange != null) {
      parts.add('HP ${DataVals.beautifyRangeTexts(vals.TriggeredTargetHpRange!).join(" & ")}');
    }
    if (vals.TriggeredTargetHpRateRange != null) {
      List<String> ranges = DataVals.beautifyRangeTexts(vals.TriggeredTargetHpRateRange!);
      ranges = ranges
          .map((e) => e.replaceAllMapped(RegExp(r'\d+'), (m) => int.parse(m.group(0)!).format(percent: true, base: 10)))
          .toList();
      parts.add('HP ${ranges.join(" & ")}');
    }
    // end conditions

    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort ||
        func.funcType == FuncType.addFieldChangeToField) {
      final buff = func.buff;
      if (buff != null) {
        describeBuff(parts, func.buffs.first, vals, inList: inList, ignoreCount: ignoreCount);
      }
      if (vals.UseRate != null) {
        _addPercent(parts, vals.UseRate, 10, post: (v) => Transl.special.funcValActChance(v));
      }
    } else if (func.funcType == FuncType.gainHpFromTargets) {
      _addInt(parts, vals.DependFuncVals?.Value, post: (s) => '$s×N');
    } else if (func.funcType == FuncType.gainNpTargetSum) {
      _addPercent(parts, vals.Value, 100, post: (s) => '$s×N');
    } else if (func.funcType == FuncType.gainNpCriticalstarSum) {
      _addPercent(parts, vals.Value, 100, post: (s) => '$s×N');
    } else if (func.funcType == FuncType.gainNpFromTargets) {
      // Absorb Value, charge Value2
      _addPercent(parts, vals.DependFuncVals?.Value2 ?? vals.DependFuncVals?.Value, 100, post: (s) => '$s×N');
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
        String? _fmtValue(int? v) {
          if (v == null) return null;
          final base = kFuncValPercentType[func.funcType];
          if (base != null) {
            return '${_toPercent(v, base)}%';
          } else {
            return v.toString();
          }
        }

        switch (func.funcType) {
          case FuncType.lossHp:
          case FuncType.lossHpSafe:
          case FuncType.lossHpPer:
          case FuncType.lossHpPerSafe:
          case FuncType.damageValue:
          case FuncType.damageValueSafe:
          case FuncType.damageValueSafeOnce:
            if (vals.Value2 != null) {
              parts.add('${_fmtValue(vals.Value)}~${_fmtValue(vals.Value2)}');
            } else {
              parts.add(_fmtValue(vals.Value)!);
            }
            break;
          case FuncType.gainNpIndividualSum:
          case FuncType.gainNpBuffIndividualSum:
          case FuncType.gainNpTargetSum:
            _addPercent(parts, vals.Value, 100, post: (s) => '$s×N');
            break;
          case FuncType.transformServant:
            // already added in func text
            break;
          default:
            final base = kFuncValPercentType[func.funcType];
            if (base != null) {
              if (k != null) {
                parts.add("${_toPercent(vals.Value, base)}%+${_toPercent(k, base)}%×${isPercentK ? 'p' : 'N'}");
              } else {
                _addPercent(parts, vals.Value, base);
              }
            } else {
              if (k != null) {
                parts.add("${vals.Value}+$k×${isPercentK ? 'p' : 'N'}");
              } else {
                parts.add(vals.Value.toString());
              }
            }

            break;
        }
      }
      if (vals.Value2 != null) {
        // if (func.funcType == FuncType.damageNpIndividualSum) {
        //   _addPercent(vals.Value2, 10);
        // }
      }
      if ((originVals ?? vals).Correction != null) {
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpAndOrCheckIndividuality:
          case FuncType.damageNpRare:
          case FuncType.damageNpStateIndividualFix:
            _addPercent(parts, vals.Correction, 10, post: (s) => '×$s');
            break;
          case FuncType.damageNpIndividualSum:
            if (vals.Value2 != null) {
              if (vals.Correction != null && vals.Correction != 0) {
                parts.add('${_toPercent(vals.Value2, 10)}%+N×${_toPercent(vals.Correction, 10)}%');
              } else {
                parts.add('${_toPercent(vals.Value2, 10)}%');
              }
            } else {
              _addPercent(parts, vals.Correction, 10, post: (s) => '×$s');
            }
            break;
          case FuncType.damageNpBattlePointPhase:
            int value2 = vals.Value2 ?? 0, correction = vals.Correction ?? 0;
            parts.add('${_toPercent(value2, 10)}%+N×${_toPercent(correction, 10)}%');
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
          case FuncType.damageNpAndOrCheckIndividuality:
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
      if (vals.BattlePointValue != null) {
        _addInt(parts, vals.BattlePointValue, post: (v) => '+$v');
      }
      if (!ignoreCount && vals.Count != null && vals.Count! > 0) {
        _addInt(parts, vals.Count, post: (v) => Transl.special.funcValCountTimes(vals.Count!));
      }
      if (vals.AddCount != null) {
        if (func.funcType == FuncType.eventDropRateUp) {
          _addPercent(parts, vals.AddCount, 10);
        } else {
          _addInt(parts, vals.AddCount);
        }
      }
      if (vals.UseRate != null) {
        _addPercent(parts, vals.UseRate, 10, post: (v) => Transl.special.funcValActChance(v));
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

    // b+kx
    int? k = vals.ParamAdd ?? vals.ParamAddValue ?? vals.CondParamAddValue ?? vals.CondParamRangeMaxValue;
    bool isPercentK = (vals.CondParamRangeMaxValue ?? 0) != 0;

    if (base != null) {
      if (k != null) {
        parts.add("${_toPercent(vals.Value, base)}%+${_toPercent(k, base)}%×${isPercentK ? 'p' : 'N'}");
      } else {
        _addPercent(parts, vals.Value, base);
      }
      // return;
    } else if (trigger != null) {
      final triggerVal = trigger(vals);
      if (triggerVal.level != null) {
        parts.add('Lv.${triggerVal.level}');
      } else if (triggerVal.skill != null) {
        if (buff.type == BuffType.counterFunction && vals.UseAttack == 1) {
          final cardType = CardType.fromId(vals.CounterId);
          parts.add('${cardType?.name.toTitle() ?? triggerVal.skill}');
        } else {
          parts.add('${triggerVal.skill}');
        }
      }
      if (buff.type == BuffType.counterFunction && vals.CounterOc != null) {
        parts.add('OC${vals.CounterOc}');
      }
      return;
    } else if ((buff.type == BuffType.changeCommandCardType || buff.type == BuffType.overwriteSvtCardType) &&
        vals.Value != null) {
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
          BuffType.overwriteBattleclass,
          BuffType.overwriteSubattribute,
          BuffType.donotSkillSelect,
        ].contains(buff.type) &&
        vals.Value != null) {
      parts.add('');
      return;
    } else if ([
          BuffType.toFieldChangeField,
          // BuffType.toFieldSubIndividualityField,  // may be in TargetList
        ].contains(buff.type) &&
        vals.FieldIndividuality != null) {
      // parts.add(vals.FieldIndividuality!.map((e) => Transl.trait(e).l).join('/'));
      parts.add('');
      return;
    } else {
      if (k != null) {
        parts.add("${vals.Value}+$k×${isPercentK ? 'p' : 'N'}");
      } else {
        _addInt(parts, vals.Value);
      }
    }
    if (vals.RatioHPHigh != null || vals.RatioHPLow != null) {
      final ratios = [vals.RatioHPHigh ?? 0, vals.RatioHPLow ?? 0].toList();
      final ratioStrings = ratios.map((e) => _toPercent((vals.Value ?? 0) + e, base ?? 1)).toList();
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
      _addInt(parts, vals.Count, post: (v) => Transl.special.funcValCountTimes(vals.Count!));
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
      _addPercent(
        parts,
        vals.ActSetWeight,
        1,
        post: (v) {
          String s = Transl.special.funcValWeight(v);
          if (vals.ActSet != null) {
            s = '[${vals.ActSet}]$s';
          }
          return s;
        },
      );
    }
  }
}
