import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/quiz/cipher.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../faker/history.dart';

class CipherTestPage extends StatefulWidget {
  const CipherTestPage({super.key});

  @override
  State<CipherTestPage> createState() => _CipherTestPageState();
}

const String _kDES3Key = 'des3_key';
const String _kDES3IV = 'des3_iv';
const String _kRijndaelCbcKey = 'rijndael_key';
const String _kRijndaelCbcIV = 'rijndael_iv';

List<int> _tryB64Decode(String s) {
  try {
    return base64Decode(base64.normalize(Uri.decodeComponent(s.trim())));
  } catch (e) {
    return utf8.encode(s);
  }
}

String _tryUtf8OrB64(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } catch (e) {
    return base64Encode(bytes);
  }
}

class _CipherTestPageState extends State<CipherTestPage> {
  late final inputController = TextEditingController();
  String output = "";
  String? error;

  static final Map<String, String> savedData = {};
  List<int> getSecretBytes(String key) {
    return utf8.encode(savedData[key] ?? '');
  }

  void testCipher(String Function(String) cb) {
    error = null;
    output = '';
    try {
      output = cb(inputController.text);
    } catch (e, s) {
      error = e.toString();
      logger.e('cipher test failed', e, s);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ciphers')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          TextField(
            controller: inputController,
            decoration: const InputDecoration(
              labelText: 'Input Data',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(),
              hintText: 'base64 text for decryption',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          Card(
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minHeight: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: divideList([
                  Text(output.length > 1000 ? output.substring(0, 1000) : output),
                  if (error != null)
                    Text(error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ], const SizedBox(height: 8)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const DividerWithTitle(title: 'View'),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  viewData(inputController.text);
                },
                child: const Text('Input'),
              ),
              FilledButton(
                onPressed: () {
                  viewData(output);
                },
                child: const Text('Output'),
              ),
              FilledButton(
                onPressed: () async {
                  String? text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
                  viewData(text);
                },
                child: const Text('Clipboard'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const DividerWithTitle(title: 'Common'),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  testCipher((input) {
                    return utf8.decode(_tryB64Decode(input));
                  });
                },
                child: const Text('Base64'),
              ),
              FilledButton(
                onPressed: () {
                  testCipher((input) {
                    dynamic data = msgpack.deserialize(Uint8List.fromList(_tryB64Decode(input)));
                    if (data is List || data is Map) {
                      try {
                        data = jsonEncode(data);
                      } catch (e) {} // ignore: empty_catches
                    }
                    return data.toString();
                  });
                },
                child: const Text('msgpack'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const DividerWithTitle(title: 'DES3'),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  testCipher((input) {
                    return _tryUtf8OrB64(
                      encryptDES3(_tryB64Decode(input), getSecretBytes(_kDES3Key), getSecretBytes(_kDES3IV)),
                    );
                  });
                },
                child: const Text('Encrypt'),
              ),
              FilledButton(
                onPressed: () {
                  testCipher((input) {
                    return _tryUtf8OrB64(
                      decryptDES3(_tryB64Decode(input), getSecretBytes(_kDES3Key), getSecretBytes(_kDES3IV)),
                    );
                  });
                },
                child: const Text('Decrypt'),
              ),
            ],
          ),
          buildKeyRow(_kDES3Key, 'DES3 Key'),
          buildKeyRow(_kDES3IV, 'DES3 IV'),
          const DividerWithTitle(title: 'Rijndael CBC'),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  testCipher((input) {
                    return _tryUtf8OrB64(
                      encryptRijndael(_tryB64Decode(input), getSecretBytes(_kDES3Key), getSecretBytes(_kDES3IV)),
                    );
                  });
                },
                child: const Text('Encrypt'),
              ),
              FilledButton(
                onPressed: () {
                  testCipher((input) {
                    return _tryUtf8OrB64(
                      decryptRijndael(_tryB64Decode(input), getSecretBytes(_kDES3Key), getSecretBytes(_kDES3IV)),
                    );
                  });
                },
                child: const Text('Decrypt'),
              ),
            ],
          ),
          buildKeyRow(_kRijndaelCbcKey, 'Rijndael CBC IV'),
          buildKeyRow(_kRijndaelCbcIV, 'Rijndael CBC IV'),
        ],
      ),
    );
  }

  Widget buildKeyRow(String key, String title) {
    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: Text(savedData[key] ?? 'not set'),
      trailing: const Icon(Icons.edit),
      onTap: () {
        InputCancelOkDialog(
          title: title,
          onSubmit: (s) {
            savedData[key] = s;
            if (mounted) setState(() {});
          },
        ).showDialog(context);
      },
    );
  }

  void viewData(dynamic data) {
    if (data == null || (data is String && data.isEmpty)) {
      EasyLoading.showError(S.current.empty_hint);
      return;
    }

    SimpleDialog(
      title: Text('Data Format'),
      children: [
        SimpleDialogOption(
          child: Text('Json'),
          onPressed: () {
            dynamic jsonData = data;
            try {
              jsonData = jsonDecode(jsonData);
            } catch (e) {
              //
            }
            router.pushPage(JsonViewerPage(jsonData));
          },
        ),
        SimpleDialogOption(
          child: Text('Form'),
          onPressed: () {
            List<MapEntry<String, String>> formData;
            if (data is Map) {
              formData = data.entries.map((e) => MapEntry(e.key.toString(), e.value.toString())).toList();
            } else if (data is String) {
              formData = Uri.splitQueryString(data).entries.toList();
            } else {
              formData = [MapEntry('unknown', data.toString())];
            }
            router.pushPage(FormDataViewer(data: formData));
          },
        ),
      ],
    ).showDialog(context);
  }
}
