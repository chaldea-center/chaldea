import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report_mode.dart';
import 'package:catcher/utils/catcher_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config.dart';

class PageReportModeCross extends ReportMode {
  final bool showStackTrace;

  PageReportModeCross({
    this.showStackTrace = true,
  }) : assert(showStackTrace != null, "showStackTrace can't be null");

  @override
  Future<void> requestAction(Report report, BuildContext context) async {
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

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();

  @override
  bool isContextRequired() {
    return true;
  }
}

class _PageWidget extends StatefulWidget {
  final PageReportModeCross pageReportMode;
  final Report report;

  const _PageWidget(
    this.pageReportMode,
    this.report, {
    Key key,
  }) : super(key: key);

  @override
  _PageWidgetState createState() {
    return _PageWidgetState();
  }
}

class _PageWidgetState extends State<_PageWidget> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController =
        TextEditingController(text: db.userData.contactInfo);
    super.initState();
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
              labelText: '联系方式(可选)',
              hintText: '我们会尽快给您答复',
            ),
            onChanged: (s) {
              db.userData.contactInfo = s;
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
      final items = widget.report.stackTrace.toString().split("\n");
      if (widget.report.errorDetails?.exception != null)
        items.insert(0, widget.report.errorDetails.exceptionAsString());
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
