import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import '../runtime.dart';

class FakerRuntimeBase {
  final FakerRuntime runtime;
  final MasterDataManager mstData;
  final FakerAgent agent;

  FakerRuntimeBase(this.runtime) : mstData = runtime.mstData, agent = runtime.agent;
}
