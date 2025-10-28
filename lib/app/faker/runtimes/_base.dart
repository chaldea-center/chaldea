import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import '../runtime.dart';

abstract class FakerRuntimeBase {
  final FakerRuntime runtime;
  final MasterDataManager mstData;
  final FakerAgent agent;

  FakerRuntimeBase(this.runtime) : mstData = runtime.mstData, agent = runtime.agent;
}
