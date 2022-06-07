import 'dart:async';

abstract class BackupBackend<K, V> {
  FutureOr<K> Function() encode;
  FutureOr<V> Function(K data) decode;

  BackupBackend({required this.encode, required this.decode});

  Future<void> backup();
  Future<V?> restore();
}
