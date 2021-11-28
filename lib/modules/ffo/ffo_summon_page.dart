part of ffo;

class FFOSummonPage extends StatefulWidget {
  final Map<int, FFOPart> partsDta;

  const FFOSummonPage({Key? key, required this.partsDta}) : super(key: key);

  @override
  _FFOSummonPageState createState() => _FFOSummonPageState();
}

class _FFOSummonPageState extends State<FFOSummonPage> {
  int _curHistory = -1;
  List<List<FFOParams>> history = [];

  @override
  void dispose() {
    super.dispose();
    _disposeHistory();
  }

  void _disposeHistory() {
    history.forEach((group) {
      group.forEach((element) {
        element.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _curHistory = fixValidRange(_curHistory, 0, history.length - 1);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freedom Order Summon'),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              history.clear();
              _curHistory = -1;
              setState(() {});
              _disposeHistory();
            },
            icon: const Icon(Icons.replay),
            tooltip: S.current.reset,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 6),
        children: [
          banner,
          summonBtn,
          if (widget.partsDta.isEmpty)
            Center(child: Text(S.current.ffo_missing_data_hint)),
          results,
          if (history.isNotEmpty)
            Center(
              child: Text(
                S.current.long_press_to_save_hint,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget get banner {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: Image.file(
        File(join(_baseDir, 'UI', 'bg_summon_banner.png')),
        errorBuilder: (context, e, s) => Container(),
      ),
    );
  }

  Widget get summonBtn {
    double ratio = 0.56;
    Widget _buildBtn(bool ten) {
      return SizedBox(
        width: 214 * ratio,
        height: 88 * ratio,
        child: InkWell(
          onTap: () {
            drawSummon(ten ? 10 : 1);
          },
          child: Image.file(
            File(join(_baseDir, 'UI',
                ten ? 'btn_summon_10.png' : 'btn_summon_01.png')),
            errorBuilder: (context, _, __) {
              return db.getIconImage(ten ? '召唤10次按钮.png' : '召唤1次按钮.png');
            },
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBtn(false),
          const SizedBox(width: 10),
          _buildBtn(true),
        ],
      ),
    );
  }

  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  void drawSummon(int counts) async {
    final svts = widget.partsDta.values.toList();
    if (svts.isEmpty) return;
    history.add(List.generate(
      counts,
      (index) => FFOParams(
        headPart: svts[_random.nextInt(svts.length)],
        bodyPart: svts[_random.nextInt(svts.length)],
        landPart: svts[_random.nextInt(svts.length)],
        clipOverflow: true,
        cropNormalizedSize: true,
      ),
    ));
    _curHistory = history.length - 1;
    setState(() {});
  }

  Widget get results {
    if (history.isEmpty) return Container();

    Widget _buildRow(List<FFOParams> rowItems) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: rowItems
            .map((e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: e.buildCard(context, true),
                ))
            .toList(),
      );
    }

    Widget _buildOneHistory(List<FFOParams> data) {
      List<Widget> rows = [];
      rows.add(_buildRow(data.sublist(0, min(5, data.length))));
      if (data.length > 5) rows.add(_buildRow(data.sublist(5, data.length)));
      Widget child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        ),
      );
      if (data.isNotEmpty) {
        child = FittedBox(
          child: child,
          fit: BoxFit.scaleDown,
        );
      }
      return child;
    }

    if (_curHistory < 0 || _curHistory >= history.length) {
      _curHistory = history.length - 1;
    }
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _curHistory == 0
                  ? null
                  : () {
                      setState(() {
                        _curHistory -= 1;
                      });
                    },
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: (512 * 5) / (720 * 2),
                child: _buildOneHistory(history[_curHistory]),
              ),
            ),
            IconButton(
              onPressed: _curHistory == history.length - 1
                  ? null
                  : () {
                      setState(() {
                        _curHistory += 1;
                      });
                    },
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        Text(
          '${_curHistory + 1}/${history.length}',
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
