import 'dart:io';

import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

import '../test_init.dart';

void main() async {
  await initiateForTest();

  // test without ui, [silent] must set to silent
  final data = await GameDataLoader.instance.reload(offline: true, silent: true);
  print('Data version: ${data?.version.dateTime.toString()}');

  db.gameData = data!;
  // const path = '<Path to a folder>';
  // for (final Servant svt in db.gameData.servantsById.values) {
  //   checkSvtData(path, svt);
  // }
}

/// helper method to list important bit of a servant, so scripts not yet implemented can be easily spotted.
void checkSvtData(final String path, final Servant svtData) async {
  final file = File('$path/${svtData.collectionNo}.txt');
  final List<String> checkStrings = [];
  checkStrings.add('Checking data for servant [${svtData.id}] - [${svtData.collectionNo}]: ${svtData.lName.cn}');
  if (svtData.script != null && svtData.script!.source.isNotEmpty) {
    checkStrings.add('Servant scripts: [${svtData.script!.source}]');
  }
  checkStrings.add('');

  for (int i = 1; i <= svtData.groupedActiveSkills.length; i += 1) {
    checkStrings.add('===============================================================');
    checkStrings.add('Checking skill group [$i]');
    final groupedSkills = svtData.groupedActiveSkills[i - 1];
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
