import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report_mode.dart';
import 'package:catcher/utils/catcher_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'shared_prefs.dart';

class PageReportModeCross extends ReportMode {
  final bool showStackTrace;

  PageReportModeCross({
    this.showStackTrace = true,
  });

  @override
  Future<void> requestAction(Report report, BuildContext? context) async {
    if (context != null) {
      await Future<void>.delayed(Duration.zero);
      String predict = report.error?.toString() ?? '';
      predict += report.stackTrace?.toString() ?? '';
      if (predict.trim().isNotEmpty) {
        Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => _PageWidget(this, report)),
        );
      } else {
        print('Empty report caught, skip request action and handling');
      }
    }
  }

  @override
  bool isContextRequired() {
    return true;
  }

  @override
  List<PlatformType> getSupportedPlatforms() => [
        PlatformType.android,
        PlatformType.iOS,
        PlatformType.web,
        PlatformType.linux,
        PlatformType.macOS,
        PlatformType.windows,
      ];
}

class _PageWidget extends StatefulWidget {
  final PageReportModeCross pageReportMode;
  final Report report;

  const _PageWidget(
    this.pageReportMode,
    this.report, {
    Key? key,
  }) : super(key: key);

  @override
  _PageWidgetState createState() {
    return _PageWidgetState();
  }
}

class _PageWidgetState extends State<_PageWidget> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
        text: db.prefs.instance.getString(SharedPrefs.contactInfo));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => CatcherUtils.isCupertinoAppAncestor(context)
          ? _buildCupertinoPage()
          : _buildMaterialPage(),
    );
  }

  Widget _buildMaterialPage() {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            widget.pageReportMode.onActionRejected(widget.report);
            _closePage();
          },
        ),
        title:
            Text(widget.pageReportMode.localizationOptions.pageReportModeTitle),
      ),
      body: _buildInnerWidget(),
    );
  }

  Widget _buildCupertinoPage() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:
            Text(widget.pageReportMode.localizationOptions.pageReportModeTitle),
      ),
      child: SafeArea(
        child: _buildInnerWidget(),
      ),
    );
  }

  Widget _buildInnerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget
                  .pageReportMode.localizationOptions.pageReportModeDescription,
              style: _getTextStyle(15),
              textAlign: TextAlign.center,
            ),
          ),
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              labelText: 'Contact information (Optional)',
            ),
            onChanged: (s) {
              db.prefs.instance.setString(SharedPrefs.contactInfo, s);
            },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _getStackTraceWidget(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () => _onAcceptClicked(),
                child: Text(widget
                    .pageReportMode.localizationOptions.pageReportModeAccept),
              ),
              TextButton(
                onPressed: () => _onCancelClicked(),
                child: Text(widget
                    .pageReportMode.localizationOptions.pageReportModeCancel),
              ),
            ],
          )
        ],
      ),
    );
  }

  TextStyle _getTextStyle(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      decoration: TextDecoration.none,
    );
  }

  Widget _getStackTraceWidget() {
    if (widget.pageReportMode.showStackTrace) {
      final List<String> items = [
        if (widget.report.error != null) widget.report.error.toString(),
        if (widget.report.error == null && widget.report.errorDetails != null)
          widget.report.errorDetails.toString(),
        ...widget.report.stackTrace.toString().split("\n"),
      ];
      return SizedBox(
        height: 300.0,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(
              // ignore: unnecessary_string_interpolations
              '${items[index]}',
              style: _getTextStyle(10),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  void _onAcceptClicked() {
    widget.pageReportMode.onActionConfirmed(widget.report);
    _closePage();
  }

  void _onCancelClicked() {
    widget.pageReportMode.onActionRejected(widget.report);
    _closePage();
  }

  void _closePage() {
    Navigator.of(context).pop();
  }
}
