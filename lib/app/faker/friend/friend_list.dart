import 'package:material_ui/material_ui.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/models/gamedata/mst_tables.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../runtime.dart';

class FriendListPage extends StatefulWidget {
  final FakerRuntime runtime;

  const FriendListPage({super.key, required this.runtime});

  @override
  State<FriendListPage> createState() => FriendListPageState();
}

class FriendListPageState extends State<FriendListPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  final scrollController = ScrollController();

  final friendStatusFilter = FilterGroupData<int>();
  final friendFlagFilter = FilterGroupData<TblFriendFlag>();

  @override
  Widget build(BuildContext context) {
    final allStatus = mstData.tblFriend.map((e) => e.status).toSet().toList();
    friendStatusFilter.options.retainAll(allStatus);
    final friends = mstData.tblFriend.where((tblFriend) {
      if (!friendStatusFilter.matchOne(tblFriend.status)) return false;
      if (!friendFlagFilter.matchAny(tblFriend.flags)) return false;
      return true;
    }).toList();
    friends.sort2(
      (e) => mstData.otherUserGame[e.getIdNotMe(mstData.user!.userId)]?.getUpdatedAt() ?? 0,
      reversed: true,
    );
    final int friendCount = mstData.tblFriend.where((e) => e.status == FriendStatus.friend.value).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Friends'), actions: [runtime.buildHistoryButton(context)]),
      body: Column(
        children: [
          const SizedBox(height: 8),
          FilterGroup<int>(
            values: friendStatusFilter,
            options: allStatus,
            optionBuilder: (value) => Text(FriendStatus.fromValue(value).name),
            combined: true,
            onFilterChanged: (optionData, _) {
              if (mounted) setState(() {});
            },
          ),
          FilterGroup<TblFriendFlag>(
            values: friendFlagFilter,
            options: const [.toFriendidLock, .toUseridLock],
            optionBuilder: (value) => Text(value.dispName),
            combined: true,
            onFilterChanged: (optionData, _) {
              if (mounted) setState(() {});
            },
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemBuilder: (context, index) => buildFriend(index, friends[index]),
              separatorBuilder: (context, index) => const Divider(height: 8, indent: 16, endIndent: 16),
              itemCount: friends.length,
            ),
          ),
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                runtime.buildCircularProgress(context: context),
                FilledButton(
                  onPressed: () async {
                    runtime.runTask(runtime.agent.friendTop);
                  },
                  child: Text('Refresh'),
                ),
                Text('$friendCount/${mstData.user?.friendKeep}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFriend(int index, TblFriendEntity tblFriend) {
    final me = mstData.user;
    final bool toMe = tblFriend.friendId == me?.userId;
    final friend = mstData.otherUserGame[toMe ? tblFriend.userId : tblFriend.friendId];

    return ListTile(
      dense: true,
      leading: Text('${index + 1}'),
      title: Text((friend?.userName ?? 'ID ${tblFriend.friendId}') + (toMe ? ' →ME' : '')),
      subtitle: Text(
        [
          if (friend != null) 'Lv.${friend.userLv} ${friend.friendCode}',
          if (friend != null && friend.message.isNotEmpty) friend.message,
          if (friend != null) friend.getUpdatedAt().sec2date().toStringShort(omitSec: true),
          // tblFriend.createdAt.sec2date().toStringShort(omitSec: true),
          // tblFriend.updatedAt.sec2date().toStringShort(omitSec: true),
          // '${tblFriend.userId}->${tblFriend.friendId}',
        ].join('\n'),
      ),
      trailing: Text(
        [tblFriend.status2.name, tblFriend.flags.map((e) => e.dispName).join('/')].join('\n'),
        textAlign: .end,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        //
      },
    );
  }
}
