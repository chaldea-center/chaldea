import 'package:catcher/catcher_plugin.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:package_info/package_info.dart';

void main() async {
  // show launcher screen forever if return before runApp.
  // launcher screen is programmed in platform folder(android/ or ios/)

  WidgetsFlutterBinding.ensureInitialized();
  final info = await PackageInfo.fromPlatform();
  final emailHandler = EmailManualHandler(
      [supportTeamEmailAddress],
      enableDeviceParameters: true,
      enableStackTrace: true,
      enableCustomParameters: true,
      enableApplicationParameters: true,
      sendHtml: true,
      emailTitle: '${info.appName} v${info.version} Freedback',
      emailHeader: "Please attatch screenshot.",
      printLogs: true);
  final debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler(), ToastHandler()]);
  final releaseOptions =
      CatcherOptions(DialogReportMode(), [emailHandler, ToastHandler()]);

  Catcher(
    Chaldea(),
    debugConfig: debugOptions,
    profileConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}
