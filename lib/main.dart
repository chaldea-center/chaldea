import 'package:catcher/catcher_plugin.dart';
import 'package:chaldea/modules/chaldea.dart';

void main() {
  // show launcher screen forever if return before runApp.
  // launcher screen is programmed in platform folder(android/ or ios/)
  // runApp(Chaldea());
  EmailManualHandler emailHandler = EmailManualHandler(["support@narumi.cc"],
      enableDeviceParameters: true,
      enableStackTrace: true,
      enableCustomParameters: true,
      enableApplicationParameters: true,
      sendHtml: true,
      emailTitle: "Sample Title",
      emailHeader: "Sample Header",
      printLogs: true);
  CatcherOptions debugOptions =
      CatcherOptions(SilentReportMode(), [ConsoleHandler()]);
  CatcherOptions releaseOptions =
      CatcherOptions(DialogReportMode(), [emailHandler]);

  Catcher(Chaldea(), debugConfig: debugOptions, releaseConfig: releaseOptions);
}
