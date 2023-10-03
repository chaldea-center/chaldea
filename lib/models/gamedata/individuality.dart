import 'package:chaldea/utils/extension.dart';
import 'common.dart';

class Individuality {
  const Individuality._();

  static bool containsAllAB(List<NiceTrait> selfs, List<int> targets, {bool signed = true}) {
    return selfs.map((e) => signed ? e.signedId : e.id).toSet().containSubset(targets.toSet());
  }
}
