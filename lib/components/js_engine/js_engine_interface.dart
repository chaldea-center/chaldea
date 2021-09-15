abstract class JsEngineMixin {
  /// init if needed
  Future<void> init([Function? callback]);

  Future<void> ensureInitiated();

  /// JSON.stringify returned object
  Future<String?> eval(String command, {String name});

  void dispose();
}
