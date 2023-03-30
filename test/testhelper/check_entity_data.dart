import 'dart:io';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../test_init.dart';

void main() async {
  await initiateForTest();

  // const path = '<Path to a folder>';
  // for (final Servant svt in db.gameData.servantsById.values) {
  //   checkSvtData(path, svt);
  // }
  // checkByType(path);
}

/// helper method to list important bit of a servant, so scripts not yet implemented can be easily spotted.
void checkSvtData(final String path, final Servant svtData) {
  final file = File('$path/${svtData.collectionNo}.txt');
  final List<String> checkStrings = [];
  checkStrings.add('Checking data for servant [${svtData.id}] - [${svtData.collectionNo}]: ${svtData.lName.cn}');
  if (svtData.script != null && svtData.script!.source.isNotEmpty) {
    checkStrings.add('Servant scripts: [${svtData.script!.source}]');
  }
  checkStrings.add('');

  for (final i in svtData.groupedActiveSkills.keys) {
    checkStrings.add('===============================================================');
    checkStrings.add('Checking skill group [$i]');
    final groupedSkills = svtData.groupedActiveSkills[i]!;
    for (int j = 1; j <= groupedSkills.length; j += 1) {
      checkStrings.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
      checkStrings.add('Checking skill [$j] in group [$i]');
      final skill = groupedSkills[j - 1];
      if (skill.script != null && skill.script!.source.isNotEmpty) {
        checkStrings.add('Checking scripts for skill [$j] in group [$i]: ${skill.script!.source}');
      }

      for (int k = 1; k <= skill.functions.length; k += 1) {
        final function = skill.functions[k - 1];
        checkStrings.add('Function type for function [$k] in skill [$j] in group [$i]: ${function.funcType}, '
            'DataVal sample: ${function.svals.last.toJson()}');

        if (function.buff != null) {
          final buff = function.buff!;
          final scriptCheck = buff.script != null && buff.script!.source.isNotEmpty;
          checkStrings.add('Buff in function has type [${buff.type}]'
              '${scriptCheck ? ' and script [${buff.script!.source}]' : ''}');
        }
      }
      checkStrings.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
      if (j != groupedSkills.length) checkStrings.add('');
    }
    checkStrings.add('===============================================================');
    checkStrings.add('');
  }

  checkStrings.add('');
  for (int i = 1; i <= svtData.noblePhantasms.length; i += 1) {
    checkStrings.add('===============================================================');
    checkStrings.add('Checking noblePhantasms [$i]');
    final niceTd = svtData.noblePhantasms[i - 1];
    if (niceTd.script != null && niceTd.script!.source.isNotEmpty) {
      checkStrings.add('Checking scripts for noblePhantasms [$i]: ${niceTd.script!.source}');
    }

    for (int j = 1; j <= niceTd.functions.length; j += 1) {
      checkStrings.add('Checking function [$j] in noblePhantasm [$i]');
      final function = niceTd.functions[j - 1];
      checkStrings.add('Function type for function [$j] in noblePhantasms [$i]: ${function.funcType} '
          'DataVal sample: ${function.svals.last.toJson()}');
      if (function.buff != null) {
        final buff = function.buff!;
        final scriptCheck = buff.script != null && buff.script!.source.isNotEmpty;
        checkStrings.add('Buff in function has type [${buff.type}]'
            '${scriptCheck ? ' and script [${buff.script!.source}]' : ''}');
      }
    }
    checkStrings.add('===============================================================');
    checkStrings.add('');
  }
  file.writeAsString(checkStrings.join('\n'));
}

void checkByType(final String path) {
  final Map<String, List<String>> servantScripts = {};
  final Map<String, List<String>> skillScripts = {};
  final Map<String, List<String>> funcTargets = {};
  final Map<String, Map<String, List<String>>> funcTypeToDataVals = {};
  final Map<String, Map<String, List<String>>> buffTypeToScripts = {};

  void logSkills(
      final Map<String, dynamic>? skillScriptMap, final List<NiceFunction> skillFunctions, final String identifier) {
    if (skillScriptMap != null && skillScriptMap.isNotEmpty) {
      for (final entry in skillScriptMap.entries) {
        if (!skillScripts.containsKey(entry.key)) {
          skillScripts[entry.key] = [];
        }
        skillScripts[entry.key]!.add('${entry.value} - $identifier');
      }
    }

    for (int k = 1; k <= skillFunctions.length; k += 1) {
      final function = skillFunctions[k - 1];
      if (!funcTargets.containsKey(function.funcTargetType.name)) {
        funcTargets[function.funcTargetType.name] = [];
      }
      funcTargets[function.funcTargetType.name]!.add('$identifier function [$k]');

      if (!funcTypeToDataVals.containsKey(function.funcType.name)) {
        funcTypeToDataVals[function.funcType.name] = {};
      }
      final dataVal = function.svals.last;
      final dataValMap = funcTypeToDataVals[function.funcType.name]!;
      for (final entry in dataVal.toJson().entries) {
        if (!dataValMap.containsKey(entry.key)) {
          dataValMap[entry.key] = [];
        }
        dataValMap[entry.key]!.add('${entry.value} - $identifier function [$k]');
      }

      if (function.buff != null) {
        final buff = function.buff!;
        final scriptCheck = buff.script != null && buff.script!.source.isNotEmpty;

        if (!buffTypeToScripts.containsKey(buff.type.name)) {
          buffTypeToScripts[buff.type.name] = {};
        }
        final scriptKeys = buffTypeToScripts[buff.type.name]!;
        if (scriptCheck) {
          for (final entry in buff.script!.source.entries) {
            if (!scriptKeys.containsKey(entry.key)) {
              scriptKeys[entry.key] = [];
            }
            scriptKeys[entry.key]!.add('${entry.value} - $identifier function [$k]');
          }
        } else {
          if (!scriptKeys.containsKey('NO SCRIPT')) {
            scriptKeys['NO SCRIPT'] = [];
          }
          scriptKeys['NO SCRIPT']!.add('$identifier function [$k]');
        }

        if (buff.type.name.endsWith('Function')) {
          final activatedSkill = db.gameData.baseSkills[dataVal.Value];
          if (activatedSkill != null) {
            logSkills(activatedSkill.script?.source, activatedSkill.functions,
                '$identifier - skill ${dataVal.Value} activated by buff ${buff.type.name}');
          }
        }
      }
    }
  }

  for (final Servant svtData in db.gameData.servantsById.values) {
    if (svtData.script != null && svtData.script!.source.isNotEmpty) {
      for (final entry in svtData.script!.source.entries) {
        if (!servantScripts.containsKey(entry.key)) {
          servantScripts[entry.key] = [];
        }
        servantScripts[entry.key]!.add('${entry.value} - ${svtData.collectionNo} ${svtData.lName.cn}');
      }
    }

    for (final i in svtData.groupedActiveSkills.keys) {
      final groupedSkills = svtData.groupedActiveSkills[i]!;
      for (int j = 1; j <= groupedSkills.length; j += 1) {
        final skill = groupedSkills[j - 1];
        logSkills(
            skill.script?.source, skill.functions, '${svtData.collectionNo} ${svtData.lName.cn} skill [$i] - [$j]');
      }
    }

    for (int j = 1; j <= svtData.classPassive.length; j += 1) {
      final skill = svtData.classPassive[j - 1];
      logSkills(
          skill.script?.source, skill.functions, '${svtData.collectionNo} ${svtData.lName.cn} passive skill [$j]');
    }

    for (int j = 1; j <= svtData.extraPassive.length; j += 1) {
      final skill = svtData.extraPassive[j - 1];
      logSkills(skill.script?.source, skill.functions,
          '${svtData.collectionNo} ${svtData.lName.cn} extra passive skill [$j]');
    }

    for (int j = 1; j <= svtData.appendPassive.length; j += 1) {
      final skill = svtData.appendPassive[j - 1].skill;
      logSkills(skill.script?.source, skill.functions, '${svtData.collectionNo} ${svtData.lName.cn} append skill [$j]');
    }

    for (int i = 1; i <= svtData.noblePhantasms.length; i += 1) {
      final niceTd = svtData.noblePhantasms[i - 1];
      logSkills(
          niceTd.script?.source, niceTd.functions, '${svtData.collectionNo} ${svtData.lName.cn} noblePhantasms [$i]');
    }
  }

  // final file = File('$path/${svtData.collectionNo}.txt');
  // file.writeAsString(checkStrings.join('\n'));
  // final Map<String, List<String>> servantScripts = {};
  // final Map<String, List<String>> skillScripts = {};
  // final Map<String, List<String>> funcTargets = {};
  // final Map<String, Map<String, List<String>>> funcTypeToDataVals = {};
  // final Map<String, Map<String, List<String>>> buffTypeToScripts = {};
  for (final entry in servantScripts.entries) {
    final file = File('$path/Servant Scripts/${entry.key}.txt')..createSync(recursive: true);
    file.writeAsString(entry.value.join('\n'));
  }
  for (final entry in skillScripts.entries) {
    final file = File('$path/Skill Scripts/${entry.key}.txt')..createSync(recursive: true);
    file.writeAsString(entry.value.join('\n'));
  }
  for (final entry in funcTargets.entries) {
    final file = File('$path/Function Targets/${entry.key}.txt')..createSync(recursive: true);
    file.writeAsString(entry.value.join('\n'));
  }
  for (final dataValEntry in funcTypeToDataVals.entries) {
    for (final entry in dataValEntry.value.entries) {
      final file = File('$path/Function Types/${dataValEntry.key}/${entry.key}.txt')..createSync(recursive: true);
      file.writeAsString(entry.value.join('\n'));
    }
  }
  for (final buffScriptEntry in buffTypeToScripts.entries) {
    for (final entry in buffScriptEntry.value.entries) {
      final file = File('$path/Buff Types/${buffScriptEntry.key}/${entry.key}.txt')..createSync(recursive: true);
      file.writeAsString(entry.value.join('\n'));
    }
  }
}
