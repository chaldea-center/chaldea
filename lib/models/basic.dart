import 'package:flutter/foundation.dart';

const _envChaldeaNext = bool.fromEnvironment('CHALDEA_NEXT');

bool _runChaldeaNext = false;

bool get runChaldeaNext =>
    _envChaldeaNext || kIsWeb || (kDebugMode && _runChaldeaNext);

set runChaldeaNext(bool v) => _runChaldeaNext = v;
