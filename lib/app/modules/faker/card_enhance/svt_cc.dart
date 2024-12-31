import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../_shared/svt_select.dart';
import '../history.dart';

const int _kQuickKey = 5000, _kArtsKey = 5001, _kBusterKey = 5002, _kBeastFoot = 2000;

class UserSvtCommandCodePage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserSvtCommandCodePage({super.key, required this.runtime});

  @override
  State<UserSvtCommandCodePage> createState() => _UserSvtCommandCodePageState();
}

class _UserSvtCommandCodePageState extends State<UserSvtCommandCodePage> {
  late final runtime = widget.runtime;
  late final agent = runtime.agent;
  late final mstData = runtime.mstData;
  late final user = agent.user;

  int curSvtId = 0;

  @override
  void initState() {
    super.initState();
    runtime.addDependency(this);
  }

  @override
  void dispose() {
    super.dispose();
    runtime.removeDependency(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('从者强化'),
        actions: [
          IconButton(
            onPressed: () {
              router.pushPage(FakerHistoryViewer(agent: agent));
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: ListTileTheme.merge(
        dense: true,
        visualDensity: VisualDensity.compact,
        child: Column(
          children: [
            headerInfo,
            Expanded(child: body),
            const Divider(height: 1),
            buttonBar,
          ],
        ),
      ),
    );
  }

  Widget get headerInfo {
    final userGame = mstData.user ?? agent.user.userGame;
    List<InlineSpan> subtitleSpans = [
      for (final itemId in [_kQuickKey, _kArtsKey, _kBusterKey, _kBeastFoot]) ...[
        CenterWidgetSpan(
          child: Item.iconBuilder(
            context: context,
            item: null,
            itemId: itemId,
            width: 20,
          ),
        ),
        TextSpan(text: '×${mstData.userItem[itemId]?.num ?? 0}  '),
      ],
      TextSpan(text: '\nQP ${userGame?.qp.format(compact: false, groupSeparator: ",")} '),
    ];
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        minTileHeight: 48,
        visualDensity: VisualDensity.compact,
        minLeadingWidth: 20,
        leading: Container(
          constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
          child: ValueListenableBuilder(
            valueListenable: runtime.runningTask,
            builder: (context, running, _) => CircularProgressIndicator(
              value: running ? null : 1.0,
              color: running ? Colors.red : Colors.green,
            ),
          ),
        ),
        title: Text('[${agent.user.serverName}] ${userGame?.name}'),
        subtitle: Text.rich(TextSpan(children: subtitleSpans)),
      ),
    );
  }

  Widget get body {
    final svt = db.gameData.servantsById[curSvtId];
    final userSvtCmdCode = mstData.userSvtCommandCode[curSvtId];
    List<Widget> children = [
      ListTile(
        leading: svt?.iconBuilder(context: context),
        title: Text('No.$curSvtId ${svt?.lName.l ?? ""}'),
        trailing: IconButton(
          onPressed: () {
            router.pushPage(SelectUserSvtCollectionPage(
              runtime: runtime,
              getStatus: (collection) {
                final svtCC = mstData.userSvtCommandCode[collection.svtId];
                return [
                  'Lv.${collection.maxLv}',
                  svtCC?.userCommandCodeIds
                          .map((e) => e == -1 ? '-' : (e == 0 ? '0' : (e > 0 ? '1' : '$e')))
                          .join('/') ??
                      '-/-/-'
                ].join('\n');
              },
              onSelected: (value) {
                curSvtId = value.svtId;
                if (mounted) setState(() {});
              },
            ));
          },
          icon: Icon(Icons.change_circle),
        ),
      ),
      if (svt != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (index) {
                final cardType = svt.cards.getOrNull(index);
                final status = userSvtCmdCode?.userCommandCodeIds.getOrNull(index) ?? -1;
                Widget child;
                if (cardType == null) {
                  child = Text('$index:UnknownCard');
                } else {
                  child = CommandCardWidget(card: cardType, width: 42);
                  if (status == -1) {
                    child = InkWell(
                      onTap: () async {
                        await runtime.runTask(() => unlockIndex(svt.id, [index]));
                      },
                      child: Opacity(opacity: 0.5, child: child),
                    );
                  }
                }
                return Flexible(child: child);
              },
            ),
            IconButton(
              onPressed: () {
                runtime.runTask(() => unlockIndex(svt.id, List.generate(5, (i) => i)));
              },
              icon: Icon(Icons.done_all),
            ),
          ],
        )
    ];

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16),
      children: children,
    );
  }

  Widget get buttonBar {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    FilledButton buildButton({
      bool enabled = true,
      required VoidCallback onPressed,
      required String text,
    }) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        child: Text(text),
      );
    }

    List<List<Widget>> btnGroups = [
      [
        buildButton(
          onPressed: () {
            agent.network.stopFlag = true;
          },
          text: 'Stop',
        ),
      ],
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final btns in btnGroups)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: btns,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> unlockIndex(int svtId, List<int> indexes) async {
    for (final index in indexes) {
      final svt = db.gameData.servantsById[svtId];
      final status = mstData.userSvtCommandCode[svtId]?.userCommandCodeIds.getOrNull(index) ?? -1;
      final cardType = svt?.cards.getOrNull(index);
      if (cardType == null) {
        throw SilentException('Unknown Svt or index');
      }
      if (status >= 0) continue;
      final itemId = switch (cardType) {
        CardType.quick => _kQuickKey,
        CardType.arts => _kArtsKey,
        CardType.buster => _kBusterKey,
        _ => throw UnimplementedError('Unknown CardType $cardType'),
      };
      final itemNum = mstData.userItem[itemId]?.num ?? 0;
      if (itemNum <= 0) continue;
      await runtime.agent.commandCodeUnlock(servantId: svtId, idx: index);
      if (mounted) setState(() {});
    }
  }
}
