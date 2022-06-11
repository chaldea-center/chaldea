import 'dart:async';

abstract class BackupBackend<V> {
  Future<bool> backup();
  Future<V?> restore();
}
