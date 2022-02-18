import 'package:flutter/foundation.dart';

bool _runChaldeaNext = false;

bool get runChaldeaNext => kIsWeb || (kDebugMode && _runChaldeaNext);

set runChaldeaNext(bool v) => _runChaldeaNext = v;
