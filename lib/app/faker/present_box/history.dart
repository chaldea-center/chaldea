import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mappings.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/gamedata/quest.dart';
import 'package:chaldea/utils/extension.dart';
import '../runtime.dart';

class UserPresentHistoryPage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserPresentHistoryPage({super.key, required this.runtime});

  @override
  State<UserPresentHistoryPage> createState() => UserPresentHistoryPageState();
}

class UserPresentHistoryPageState extends State<UserPresentHistoryPage> with FakerRuntimeStateMixin {
  @override
  late final FakerRuntime runtime = widget.runtime;

  @override
  void initState() {
    super.initState();
    if (mstData.userPresentHistory.isEmpty) refreshHistory();
  }

  Future<void> refreshHistory() async {
    return runtime.runTask(runtime.agent.userPresentHistory);
  }

  @override
  Widget build(BuildContext context) {
    final presents = mstData.userPresentHistory.toList();
    presents.sortByList((e) => <int>[-e.createdAt, e.giftType, e.objectId, -e.num]);
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.history} - ${S.current.present_box}'),
        actions: [
          IconButton(onPressed: null, icon: runtime.buildCircularProgress(context: context)),
          IconButton(onPressed: refreshHistory, icon: Icon(Icons.refresh)),
          runtime.buildMenuButton(context),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => buildPresentHistory(presents[index]),
        separatorBuilder: (_, _) => const Divider(),
        itemCount: presents.length,
      ),
    );
  }

  Widget buildPresentHistory(UserPresentHistoryEntity present) {
    final gift = Gift(id: 0, type: GiftType.fromId(present.giftType), objectId: present.objectId, num: present.num);
    List<dynamic> messages = [present.message ?? ""];
    if (present.fromType != null) {
      messages.add(Transl.enumsInt(present.fromType!, (e) => e.presentFromType).l);
    }
    String? args = present.args;
    if (args != null && args.isNotEmpty) {
      try {
        final argsList = jsonDecode(args);
        if (argsList is List) {
          messages.addAll(argsList);
        } else {
          messages.add(jsonEncode(argsList));
        }
      } catch (e) {
        messages.add(args);
      }
    }
    messages.removeWhere((e) => e.toString().isEmpty);
    return ListTile(
      dense: true,
      leading: gift.iconBuilder(context: context, width: 36),
      title: Text(gift.shownName),
      subtitle: messages.isEmpty ? null : Text(messages.join(', ')),
      trailing: Text(
        present.createdAt.sec2date().toStringShort().replaceFirst(' ', '\n'),
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
