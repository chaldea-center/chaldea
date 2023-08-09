// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:hive/hive.dart';
import 'package:hive/src/box/default_compaction_strategy.dart';
import 'package:hive/src/box/default_key_comparator.dart';

import 'package:chaldea/utils/basic.dart';
import '../models/db.dart';
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
    int retry = 3,
  }) async {
    Box<E>? box;
    int n = 0;
    while (n < retry) {
      n += 1;
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
        return box;
      } catch (e, s) {
        logger.e('open Box<$E> "$name" failed', e, s);
        await Future.delayed(const Duration(seconds: 1));
        try {
          if (!kIsWeb && n == 1) {
            final lockFile = File('${joinPaths(path ?? db.paths.hiveDir, name.toLowerCase())}.lock');
            if (lockFile.existsSync()) {
              logger.d('deleting lock file: ${lockFile.path}');
              lockFile.deleteSync();
            } else {
              logger.d('deleting box $name');
              await deleteBoxFromDisk(name, path: path);
            }
          } else {
            logger.d('deleting box $name');
            await deleteBoxFromDisk(name, path: path);
          }
        } catch (e, s) {
          logger.e('deleting box failed: $name', e, s);
        }
        await Future.delayed(const Duration(seconds: 1));
        if (n >= retry) rethrow;
      }
    }
    throw HiveError('Failed to open hive box: $name');
  }

  Future<LazyBox<E>> openLazyBoxRetry<E>(
    String name, {
    HiveCipher? encryptionCipher,
    KeyComparator keyComparator = defaultKeyComparator,
    CompactionStrategy compactionStrategy = defaultCompactionStrategy,
    bool crashRecovery = true,
    String? path,
    int retry = 3,
  }) async {
    LazyBox<E>? box;
    int n = 0;
    while (n < retry) {
      n += 1;
      try {
        box = await openLazyBox<E>(
          name,
          encryptionCipher: encryptionCipher,
          keyComparator: keyComparator,
          compactionStrategy: compactionStrategy,
          crashRecovery: crashRecovery,
          path: path,
        );
        return box;
      } catch (e, s) {
        logger.e('open Box<$E> "$name" failed', e, s);
        await Future.delayed(const Duration(seconds: 1));
        logger.d('deleting box $name');
        try {
          await deleteBoxFromDisk(name, path: path);
        } catch (e, s) {
          logger.e('deleting box failed: $name', e, s);
        }
        await Future.delayed(const Duration(seconds: 1));
        if (n >= retry) rethrow;
      }
    }
    throw HiveError('Failed to open hive box: $name');
  }
}
