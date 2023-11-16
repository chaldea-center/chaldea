import 'dart:math' as math;

import 'package:flutter/services.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class GachaProbCalcPage extends StatefulWidget {
  const GachaProbCalcPage({super.key});

  @override
  State<GachaProbCalcPage> createState() => _GachaProbCalcPageState();
}

class _GachaProbCalcPageState extends State<GachaProbCalcPage> {
  final upTypes = <RateEntry>[
    // RateEntry(0, 'Custom'),
    RateEntry(0.8, S.current.gacha_prob_svt_pickup(5)),
    // 2.1x1, 1.2x2, 0.8x3
    RateEntry(2.1, S.current.gacha_prob_svt_pickup(4)),
    RateEntry(0.7, '${S.current.gacha_prob_svt_pickup(5)}(old)'),
    // 1.5x1, 1.2x2, 0.7x3, 0.7x4
    RateEntry(1.5, '${S.current.gacha_prob_svt_pickup(4)}(old)'),
    RateEntry(2.8, S.current.gacha_prob_ce_pickup(5)),
    RateEntry(4.0, S.current.gacha_prob_ce_pickup(4)),
    RateEntry(8.0, S.current.gacha_prob_ce_pickup(3)),
  ];

  late RateEntry? upType = upTypes.first;
  int _npxRange = 1;

  late final _rateController = TextEditingController(text: '0.8');
  late final _ticketController = TextEditingController(text: '168');

  @override
  void dispose() {
    super.dispose();
    _rateController.dispose();
    _ticketController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _customRate = double.tryParse(_rateController.text);
    final _rate = upType?.rate ?? _customRate;

    final _tickets = int.tryParse(_ticketController.text) ?? 0;
    final x11 = _tickets ~/ 10;
    final xleft = _tickets - x11 * 10;
    final sq = _tickets * 3;
    final pulls = x11 * 11 + xleft;
    final expect = _rate == null ? null : (pulls * _rate / 100).toStringAsPrecision(4);

    return Scaffold(
      appBar: AppBar(title: Text(S.current.gacha_prob_calc)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const SHeader('Pick Up'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<RateEntry?>(
              value: upType,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(S.current.general_custom, textScaler: const TextScaler.linear(0.9)),
                ),
                for (final rate in upTypes)
                  DropdownMenuItem(
                    value: rate,
                    child: Text('${rate.title}(${rate.rate}%)', textScaler: const TextScaler.linear(0.9)),
                  ),
              ],
              onChanged: (v) {
                upType = v;
                onChanged();
              },
            ),
          ),
          if (upType == null)
            ListTile(
              title: Text(S.current.gacha_prob_custom_rate),
              subtitle: Text(_customRate != null && _customRate > 0 && _customRate < 100 ? '$_customRate%' : 'Invalid'),
              trailing: SizedBox(
                width: 120,
                child: TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    suffixText: '%',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*'))],
                  onChanged: (s) {
                    onChanged();
                  },
                ),
              ),
            ),
          ListTile(
            leading: db.getIconImage(Items.summonTicket?.icon, width: 32),
            horizontalTitleGap: 4,
            title: Text(Item.getName(Items.summonTicketId)),
            trailing: SizedBox(
              width: 120,
              child: TextFormField(
                controller: _ticketController,
                decoration: const InputDecoration(
                  // suffixText: '%',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (s) {
                  onChanged();
                },
              ),
            ),
          ),
          const Divider(height: 16, thickness: 1),
          ListTile(
            title: Text.rich(TextSpan(children: [
              TextSpan(text: '$_tickets '),
              CenterWidgetSpan(
                child: db.getIconImage(Items.summonTicket?.icon, width: 32),
              ),
              TextSpan(text: ' = $sq '),
              CenterWidgetSpan(
                child: db.getIconImage(Items.stone?.icon, width: 32),
              ),
              TextSpan(text: '\n= $pulls ${S.current.summon_pull_unit} = $x11×11+$xleft'),
              TextSpan(text: '\n=  ${(sq / 168).toStringAsPrecision(4)} ${S.current.sq_buy_pack_unit}'),
              TextSpan(text: '\n${S.current.probability_expectation} E = ${expect ?? "?"}')
            ])),
          ),
          // ListTile(
          //   title: Text(
          //       '$_tickets Tickets = $sq SQs \n= $pulls Pulls = $x11 x 11 + $xleft \n= ${(sq / 168).toStringAsPrecision(4)} Packs'),
          // ),
          // const Divider(height: 16),
          CustomTable(
            children: [
              CustomTableRow.fromTexts(
                texts: ['${S.current.probability} (%)'],
                isHeader: true,
              ),
              CustomTableRow.fromTexts(
                texts: const [
                  'NP(x)',
                  'P(=x)',
                  'P(≥x)',
                  'P(<x)',
                  // 'Pulls',
                  // 'Quartz'
                ],
                isHeader: true,
              ),
              if (_tickets > 0 && _rate != null && _rate > 0 && _rate < 100) ...[
                ...calculate(pulls, _rate),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _npxRange += 1;
                    });
                  },
                  child: const Text('More'),
                ),
              ],
            ],
          ),
          SafeArea(child: SFooter(S.current.gacha_prob_precision_hint)),
        ],
      ),
    );
  }

  void onChanged() {
    EasyDebounce.debounce(
      'prob_calc_update',
      const Duration(milliseconds: 500),
      () {
        if (mounted) setState(() {});
      },
    );
  }

  List<Widget> calculate(int pulls, double rate) {
    // =x%, >=x%, <x%
    List<List<num>> data = [];
    for (int npx = 0; npx <= _npxRange * 10; npx++) {
      if (npx > pulls) break;

      final v = CMN(pulls, npx) * math.pow(rate / 100, npx) * math.pow(1 - rate / 100, pulls - npx) * 100.0;
      data.add([npx, v, 0.0, 0.0]);
    }
    for (int index = 0; index < data.length; index++) {
      data[index][3] = (data.getOrNull(index - 1)?[3] ?? 0) + (data.getOrNull(index - 1)?[1] ?? 0);
      data[index][2] = 100 - data[index][3];
    }
    return [
      for (final row in data)
        CustomTableRow.fromTexts(texts: [
          row[0].toString(),
          for (final v in row.skip(1)) _fmt(v),
        ])
    ];
  }

  String _fmt(num x) {
    if (x == 0.0) return 0.toString();
    if (x >= 0.01) {
      String s = x.toStringAsPrecision(4);
      if (s == '100.0' && x != 100.0) s = '~$s';
      return s;
    }
    return x.toStringAsExponential(3);
  }

  // ignore: non_constant_identifier_names, unused_element
  static int PMN(int m, int n) {
    if (n == 0) return 1;
    int v = m;
    while (n > 1) {
      m--;
      n--;
      v *= m;
    }
    return v;
  }

  // ignore: non_constant_identifier_names
  double CMN(int m, int n) {
    if (n > m / 2) n = m - n;
    if (n == 0) return 1;
    double v = m.toDouble();
    int i = 1;
    while (n > i) {
      m--;
      i++;
      v *= m;
      v /= i;
    }
    return v;
  }
}

class RateEntry {
  final double rate;
  final String title;
  const RateEntry(this.rate, this.title);
}
