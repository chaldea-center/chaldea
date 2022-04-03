// ignore_for_file: implementation_imports
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive/src/box/default_compaction_strategy.dart';
import 'package:hive/src/box/default_key_comparator.dart';

import '../packages/logger.dart';

extension HiveRetryOpen on HiveInterface {
  Future<Box<E>> openBoxRetry<E>(
    String name, {
    HiveCipher? encryptionCipher,
    KeyComparator keyComparator = defaultKeyComparator,
    CompactionStrategy compactionStrategy = defaultCompactionStrategy,
    bool crashRecovery = true,
    String? path,
    Uint8List? bytes,
  }) async {
    Box<E> box;
    try {
      box = await openBox<E>(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        bytes: bytes,
      );
    } catch (e, s) {
      logger.e('open Box<$E> "$name" failed', e, s);
      await deleteBoxFromDisk(name, path: path);
      box = await openBox<E>(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        bytes: bytes,
      );
    }
    return box;
  }

  Future<LazyBox<E>> openLazyBoxRetry<E>(
    String name, {
    HiveCipher? encryptionCipher,
    KeyComparator keyComparator = defaultKeyComparator,
    CompactionStrategy compactionStrategy = defaultCompactionStrategy,
    bool crashRecovery = true,
    String? path,
  }) async {
    LazyBox<E> box;
    try {
      box = await openLazyBox<E>(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
      );
    } catch (e, s) {
      logger.e('open Box<$E> "$name" failed', e, s);
      await deleteBoxFromDisk(name, path: path);
      box = await openLazyBox<E>(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
      );
    }
    return box;
  }
}
