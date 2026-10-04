import 'dart:math';

import 'package:flutter/services.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/accent_container.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../runtime.dart';

typedef _CoinRoomCoin = ({Servant svt, Item item, int stock});

class CoinRoomPage extends StatefulWidget {
  final FakerRuntime runtime;

  const CoinRoomPage({super.key, required this.runtime});

  @override
  State<CoinRoomPage> createState() => _CoinRoomPageState();
}

class _CoinRoomPageState extends State<CoinRoomPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  final _selected = <int, int>{};

  CoinRoomRules get _rules {
    final constants = runtime.gameData.timerData.constants;
    final room = mstData.userCoinRoom[mstData.user?.userId];
    return CoinRoomRules(
      count: room?.cnt ?? 0,
      castNum: room?.num ?? 0,
      maxPoint: constants.coinRoomMax,
      maxNum: constants.coinRoomMaxNum,
      pointPerCoin: constants.coinRoomGet,
      released: mstData.isQuestClear(constants.coinRoomReleaseQuestId),
    );
  }

  List<_CoinRoomCoin> get _coins {
    final coins = <_CoinRoomCoin>[];
    for (final coin in mstData.userSvtCoin) {
      final svt = db.gameData.servantsById[coin.svtId];
      final item = svt?.coin?.item;
      if (svt == null || item == null || item.type != ItemType.svtCoin || item.value != svt.id) continue;
      if (!CoinRoomRules.isEligible(
        rarity: svt.rarity,
        obtains: svt.obtains,
        unlockNums: mstData.userSvtAppendPassiveSkill[svt.id]?.unlockNums ?? const [],
        stock: coin.num,
      )) {
        continue;
      }
      coins.add((svt: svt, item: item, stock: coin.num));
    }
    coins.sort((a, b) {
      final rarityOrder = a.svt.rarity.compareTo(b.svt.rarity);
      return rarityOrder != 0 ? rarityOrder : a.svt.collectionNo.compareTo(b.svt.collectionNo);
    });
    return coins;
  }

  int get _total => Maths.sum(_selected.values);
  bool get _disabled => runtime.runningTask.value;

  DateTime get _now => runtime.region.getDateTimeByOffset(DateTime.now().timestamp);

  void _setQuantity(int itemId, int quantity) {
    setState(() {
      if (quantity == 0) {
        _selected.remove(itemId);
      } else {
        _selected[itemId] = quantity;
      }
    });
  }

  int _maxQuantity(int itemId, int stock) =>
      _rules.maxSelectable(stock: stock, otherSelected: _total - (_selected[itemId] ?? 0));

  Future<void> _editQuantity(_CoinRoomCoin coin) async {
    final quantity = await showDialog<int>(
      context: context,
      useRootNavigator: false,
      builder: (context) => _CoinRoomQuantityDialog(
        coin: coin,
        initialQuantity: _selected[coin.item.id] ?? 0,
        maxQuantity: _maxQuantity(coin.item.id, coin.stock),
        unlockNums: mstData.userSvtAppendPassiveSkill[coin.svt.id]?.unlockNums ?? const [],
      ),
    );
    if (quantity == null || !mounted || _disabled) return;
    // Another Faker task may have changed the stock while the dialog was open.
    final current = _coins.firstWhereOrNull((entry) => entry.item.id == coin.item.id);
    if (current == null || quantity > _maxQuantity(coin.item.id, current.stock)) return;
    _setQuantity(coin.item.id, quantity);
  }

  Future<void> _submit() async {
    final rules = _rules;
    final coins = _coins;
    final selected = Map<int, int>.of(_selected);
    final total = _total;
    final month = _now;
    if (rules.validate(selected, {for (final coin in coins) coin.item.id: coin.stock}) != null) return;
    final confirmed = await SimpleConfirmDialog(
      title: Text(S.current.confirm),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final coin in coins)
            if (selected.containsKey(coin.item.id))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Item.iconBuilder(context: context, item: coin.item, width: 32, jumpToDetail: false),
                    const SizedBox(width: 8),
                    Expanded(child: Text(coin.svt.lName.l)),
                    const SizedBox(width: 8),
                    Text('${selected[coin.item.id]}'),
                  ],
                ),
              ),
          const Divider(),
          Text('${S.current.cost}: ${S.current.servant_coin_short} $total'),
          Text(
            '${S.current.progress}: ${rules.points} → ${rules.points + total * rules.pointPerCoin}/${rules.maxPoint}',
          ),
          Text(rules.points + total * rules.pointPerCoin == rules.maxPoint ? '本次可铸造 1 个圣杯' : '本次投入后尚未满额'),
          const SizedBox(height: 8),
          const Text('投入的硬币将被消耗，无法撤回。'),
        ],
      ),
    ).showDialog(context);
    if (confirmed != true || !mounted) return;
    final response = await runtime.runTask(() async {
      // Revalidate the cached state after confirmation; the server validates the contribution.
      final now = _now;
      final current = _rules;
      if (month.year != now.year ||
          month.month != now.month ||
          current.count != rules.count ||
          current.castNum != rules.castNum ||
          current.maxPoint != rules.maxPoint ||
          current.maxNum != rules.maxNum ||
          current.pointPerCoin != rules.pointPerCoin) {
        throw SilentException('铸造进度已变化，请核对后重新提交');
      }
      final error = current.validate(selected, {for (final coin in _coins) coin.item.id: coin.stock});
      if (error != null) throw SilentException(error);
      return agent.coinRoomPut(items: selected);
    });
    if (response != null && mounted) setState(_selected.clear);
  }

  Widget _buildCoinCell(_CoinRoomCoin? coin, {bool compact = false}) {
    final quantity = _selected[coin?.item.id] ?? 0;
    final selected = quantity > 0;
    final cs = Theme.of(context).colorScheme;
    final label = (coin == null)
        ? ' '
        : (compact ? '$quantity' : (selected ? '$quantity/${coin.stock}' : '${coin.stock}'));
    final cell = Material(
      color: selected ? cs.secondaryContainer : cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _disabled || coin == null ? null : () => _editQuantity(coin),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: compact ? 48 : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                coin == null
                    ? const SizedBox(width: 32, height: 32 * 144 / 132)
                    : Item.iconBuilder(
                        context: context,
                        item: coin.item,
                        width: compact ? 32 : 48,
                        jumpToDetail: false,
                      ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? cs.onSecondaryContainer : cs.onSurface,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (coin == null) return cell;
    return Tooltip(message: coin.svt.lName.l, child: cell);
  }

  @override
  Widget build(BuildContext context) {
    final rules = _rules;
    final coins = _coins;
    final error = rules.validate(_selected, {for (final coin in coins) coin.item.id: coin.stock});
    final now = _now;
    final status = !rules.released
        ? '${S.current.holy_grail_casting}尚未解锁'
        : rules.castNum >= rules.maxNum
        ? '本月铸造次数已用完'
        : null;
    return Scaffold(
      appBar: AppBar(title: Text(S.current.holy_grail_casting), actions: [runtime.buildMenuButton(context)]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccentContainer(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                Text('${now.year}-${now.month.toString().padLeft(2, '0')}'),
                                Text('本月铸造 ${rules.castNum}/${rules.maxNum} 次'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: rules.maxPoint > 0 ? (rules.points / rules.maxPoint).clamp(0.0, 1.0) : 0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('${rules.points}/${rules.maxPoint}'),
                              ],
                            ),
                            if (status != null) ...[
                              const SizedBox(height: 4),
                              Text(status, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('已选择 · $_total', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      if (_selected.isEmpty)
                        Align(alignment: AlignmentDirectional.centerStart, child: _buildCoinCell(null, compact: true))
                      else
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final coin in coins)
                              if (_selected.containsKey(coin.item.id)) _buildCoinCell(coin, compact: true),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Text(S.current.item_own, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text('1–3 星 · 友情池 · 非限定 · 5 个追加技能已开放', style: Theme.of(context).textTheme.bodySmall),
                      if (coins.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(child: Text(S.current.empty_hint)),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 80,
                    mainAxisExtent: 68 + MediaQuery.textScalerOf(context).scale(16),
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: coins.length,
                  itemBuilder: (context, index) => _buildCoinCell(coins[index]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${S.current.cost}: ${S.current.servant_coin_short} $_total · ${S.current.progress}: ${rules.points + _total * rules.pointPerCoin}/${rules.maxPoint}',
                  ),
                  if (_selected.isNotEmpty && error != null)
                    Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton(onPressed: !_disabled && error == null ? _submit : null, child: const Text('投入硬币')),
                      TextButton(
                        onPressed: !_disabled && _selected.isNotEmpty ? () => setState(_selected.clear) : null,
                        child: Text(S.current.clear),
                      ),
                      runtime.buildCircularProgress(context: context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinRoomQuantityDialog extends StatefulWidget {
  final _CoinRoomCoin coin;
  final int initialQuantity;
  final int maxQuantity;
  final List<int> unlockNums;

  const _CoinRoomQuantityDialog({
    required this.coin,
    required this.initialQuantity,
    required this.maxQuantity,
    required this.unlockNums,
  });

  @override
  State<_CoinRoomQuantityDialog> createState() => _CoinRoomQuantityDialogState();
}

class _CoinRoomQuantityDialogState extends State<_CoinRoomQuantityDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _quantity = widget.initialQuantity.clamp(0, widget.maxQuantity);
  late final _controller = TextEditingController(text: '$_quantity');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? text) {
    final value = int.tryParse(text ?? '');
    return value == null || value < 0 || value > widget.maxQuantity
        ? '${S.current.input_invalid_hint} (0–${widget.maxQuantity})'
        : null;
  }

  void _slide(double value) {
    setState(() {
      _quantity = value.round();
      _controller.value = TextEditingValue(
        text: '$_quantity',
        selection: TextSelection.collapsed(offset: '$_quantity'.length),
      );
    });
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Item.iconBuilder(context: context, item: coin.item, width: 40, jumpToDetail: false),
          const SizedBox(width: 12),
          Expanded(child: Text(coin.svt.lName.l)),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.current.append_skill, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final skillNum in kAppendSkillNums)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.unlockNums.contains(skillNum + 99) ? Icons.check_circle_outline : Icons.lock_outline,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text('$skillNum'),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: '${S.current.cost} · ${S.current.servant_coin_short}',
                  suffixText: '${S.current.item_own} ${coin.stock}',
                ),
                validator: _validate,
                onChanged: (text) {
                  final value = int.tryParse(text);
                  if (value != null && value >= 0 && value <= widget.maxQuantity) setState(() => _quantity = value);
                },
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _quantity.toDouble(),
              min: 0,
              max: widget.maxQuantity.toDouble(),
              divisions: widget.maxQuantity > 0 ? widget.maxQuantity : null,
              label: '$_quantity',
              onChanged: widget.maxQuantity > 0 ? _slide : null,
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              children: [const Text('0'), Text('本次最多 ${widget.maxQuantity}')],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(S.current.cancel)),
        TextButton(onPressed: () => _slide(0), child: Text(S.current.clear)),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) Navigator.pop(context, int.parse(_controller.text));
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// Shared unlocks establish eligibility; per-copy skill levels are irrelevant.
class CoinRoomRules {
  static bool isEligible({
    required int rarity,
    required List<SvtObtain> obtains,
    required Iterable<int> unlockNums,
    required int stock,
  }) {
    return stock > 0 &&
        rarity >= 1 &&
        rarity <= 3 &&
        obtains.contains(SvtObtain.friendPoint) &&
        !obtains.contains(SvtObtain.limited) &&
        kAppendSkillNums.every((skillNum) => unlockNums.contains(skillNum + 99));
  }

  final int count;
  final int castNum;
  final int maxPoint;
  final int maxNum;
  final int pointPerCoin;
  final bool released;

  const CoinRoomRules({
    required this.count,
    required this.castNum,
    required this.maxPoint,
    required this.maxNum,
    required this.pointPerCoin,
    required this.released,
  });

  int get points => count * pointPerCoin;

  int get remainingCoins {
    if (!released || castNum >= maxNum || pointPerCoin <= 0 || maxPoint <= 0 || count < 0 || castNum < 0) return 0;
    // Never round up: a contribution must not overflow the current Grail.
    return max(0, (maxPoint - points) ~/ pointPerCoin);
  }

  int maxSelectable({required int stock, required int otherSelected}) =>
      max(0, min(stock, remainingCoins - otherSelected));

  String? validate(Map<int, int> selected, Map<int, int> eligibleStocks) {
    if (!released) return 'Unreleased feature';
    if (remainingCoins == 0) return '当前无法继续投入硬币';
    if (selected.isEmpty) return '请选择硬币';
    int total = 0;
    for (final entry in selected.entries) {
      final stock = eligibleStocks[entry.key];
      if (stock == null) return '硬币资格已变化，请重新选择';
      if (entry.value <= 0 || entry.value > stock) return '硬币数量无效或库存不足';
      total += entry.value;
    }
    if (total > remainingCoins) return '投入数量超过当前圣杯所需数量';
    return null;
  }
}
