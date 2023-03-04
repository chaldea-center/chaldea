// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_ar.dart' as messages_ar;
import 'messages_en.dart' as messages_en;
import 'messages_es.dart' as messages_es;
import 'messages_ja.dart' as messages_ja;
import 'messages_ko.dart' as messages_ko;
import 'messages_zh.dart' as messages_zh;
import 'messages_zh_Hant.dart' as messages_zh_hant;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> get _deferredLibraries => {
      'ar': () => new SynchronousFuture(null),
      'en': () => new SynchronousFuture(null),
      'es': () => new SynchronousFuture(null),
      'ja': () => new SynchronousFuture(null),
      'ko': () => new SynchronousFuture(null),
      'zh': () => new SynchronousFuture(null),
      'zh_Hant': () => new SynchronousFuture(null),
    };

Future<void> reloadMessages() async {
  for (final lib in _deferredLibraries.values) {
    await lib();
  }
  messages_ar.messages.messages.clear();
  messages_ar.messages.messages.addAll(messages_ar.MessageLookup().messages);
  messages_en.messages.messages.clear();
  messages_en.messages.messages.addAll(messages_en.MessageLookup().messages);
  messages_es.messages.messages.clear();
  messages_es.messages.messages.addAll(messages_es.MessageLookup().messages);
  messages_ja.messages.messages.clear();
  messages_ja.messages.messages.addAll(messages_ja.MessageLookup().messages);
  messages_ko.messages.messages.clear();
  messages_ko.messages.messages.addAll(messages_ko.MessageLookup().messages);
  messages_zh.messages.messages.clear();
  messages_zh.messages.messages.addAll(messages_zh.MessageLookup().messages);
  messages_zh_hant.messages.messages.clear();
  messages_zh_hant.messages.messages.addAll(messages_zh_hant.MessageLookup().messages);
}

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'ar':
      return messages_ar.messages;
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'ja':
      return messages_ja.messages;
    case 'ko':
      return messages_ko.messages;
    case 'zh':
      return messages_zh.messages;
    case 'zh_Hant':
      return messages_zh_hant.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) {
  var availableLocale =
      Intl.verifiedLocale(localeName, (locale) => _deferredLibraries[locale] != null, onFailure: (_) => null);
  if (availableLocale == null) {
    return new SynchronousFuture(false);
  }
  var lib = _deferredLibraries[availableLocale];
  lib == null ? new SynchronousFuture(false) : lib();
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new SynchronousFuture(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
