import 'dart:convert';
import 'dart:math';

import 'package:dart_des/dart_des.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/builders.dart';

class ReadAuthPage extends StatefulWidget {
  final UserAuth? auth;
  final ValueChanged<UserAuth?> onChanged;
  const ReadAuthPage({super.key, required this.auth, required this.onChanged});

  @override
  State<ReadAuthPage> createState() => _ReadAuthPageState();
}

class _ReadAuthPageState extends State<ReadAuthPage> {
  late UserAuth? auth = widget.auth;

  late final _codeCtrl = TextEditingController(text: widget.auth?.code);
  late final _userIdCtrl = TextEditingController(text: widget.auth?.userId);
  late final _authKeyCtrl = TextEditingController(text: widget.auth?.authKey);
  late final _secretKeyCtrl =
      TextEditingController(text: widget.auth?.secretKey);

  @override
  Widget build(BuildContext context) {
    final auth = this.auth;
    List<Widget> cardChildren = [];
    if (auth == null) {
      cardChildren.add(const Text('No Auth Found'));
    } else {
      final code = auth.code;
      final buffer = StringBuffer('Code: ');
      if (code == null) {
        buffer.write('null');
      } else {
        buffer.writeAll([
          code.substring(0, min(8, code.length)),
          '****',
          code.substring(max(0, code.length - 8), code.length)
        ]);
        if (!code.startsWith('ZSv/')) {
          buffer.write('\n> Warning: should start with ZSv/');
        }
      }
      cardChildren.add(Text(
        buffer.toString(),
        style: Theme.of(context).textTheme.bodySmall,
      ));
      cardChildren.add(const Divider());
      cardChildren.addAll([
        'gameServer: ${auth.userCreateServer}',
        'userId: ${auth.userId}',
        'authKey: ${auth.authKey}',
        'secretKey: ${auth.secretKey}',
        if (auth.saveDataVer != null) 'SaveDataVer: ${auth.saveDataVer}',
      ].map((e) => Text(
            e,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )));
    }
    List<Widget> children = [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cardChildren,
          ),
        ),
      ),
      SFooter(S.current.auth_data_hints),
    ];
    Widget _divider(String text) =>
        DividerWithTitle(title: text, endIndent: 8, height: 16);

    children.add(_divider('1'));
    final _docLink = HttpUrlHelper.projectDocUrl('import_https/auto_login');
    children.add(TileGroup(
      header: 'Method 1',
      footerWidget: SFooter.rich(TextSpan(text: 'more: ', children: [
        SharedBuilder.textButtonSpan(
            context: context, text: _docLink, onTap: () => launch(_docLink))
      ])),
      children: [
        ListTile(
          title: Text(S.current.import_from_file),
          subtitle: const Text('Android: 54cc, iOS: authsave(2).dat'),
          trailing: const Icon(Icons.file_open),
          onTap: readAuthFile,
        )
      ],
    ));

    children.add(_divider('2'));
    children.add(TileGroup(
      header: 'Method 2 - text of 54cc auth file',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextFormField(
            controller: _codeCtrl,
            decoration: InputDecoration(
              label: const Text('Auth File Code'),
              border: const OutlineInputBorder(),
              hintText: 'start from ZSv/ (include ZSv/)',
              errorText:
                  _codeCtrl.text.isEmpty || UserAuth.isValidCode(_codeCtrl.text)
                      ? null
                      : "Invalid",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            contextMenuBuilder: (context, editableTextState) =>
                AdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState),
            maxLines: 4,
            onChanged: (v) {
              EasyDebounce.debounce(
                  '_auth_code_', const Duration(milliseconds: 300), () {
                if (mounted) setState(() {});
              });
            },
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (_codeCtrl.text.trim().isEmpty) {
                EasyLoading.showError('Empty');
                return;
              }
              try {
                EasyLoading.show(status: 'Decoding...');
                await decodeAuth(_codeCtrl.text.trim());
                widget.onChanged(this.auth);
                EasyLoading.showSuccess(S.current.success);
              } catch (e, s) {
                EasyLoading.showError(escapeDioError(e));
                logger.e('decode auth failed', e, s);
              } finally {
                if (mounted) setState(() {});
              }
            },
            child: Text(S.current.update),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ));

    children.add(_divider('3'));
    const _link2 = 'https://github.com/hexstr/FGODailyBonus';
    children.add(TileGroup(
      header: 'Method 3 - manual input',
      footer: 'Warning: no extra verification',
      footerWidget: SFooter.rich(TextSpan(
          text: 'Warning: no extra verification!'
              ' About how to get above values, check <step 0> from:\n',
          children: [
            SharedBuilder.textButtonSpan(
                context: context, text: _link2, onTap: () => launch(_link2))
          ])),
      children: [
        _buildTextField(_userIdCtrl, 'userId'),
        _buildTextField(_authKeyCtrl, 'authKey'),
        _buildTextField(_secretKeyCtrl, 'secretKey'),
        Center(
          child: ElevatedButton(
            onPressed: () {
              final _auth = UserAuth(
                userId: _userIdCtrl.text.trim(),
                authKey: _authKeyCtrl.text.trim(),
                secretKey: _secretKeyCtrl.text.trim(),
              );
              if (int.tryParse(_auth.userId) == null) {
                EasyLoading.showError('userId must be number');
                return;
              }
              List<String> hints = [];
              if (_auth.userId.isEmpty ||
                  _auth.authKey.isEmpty ||
                  _auth.secretKey.isEmpty) {
                EasyLoading.showError('Empty');
                return;
              }
              if (_auth.userId.length < 9) {
                hints.add('<userId> is too short');
              }
              if (_auth.authKey.length != 29) {
                hints.add('<authKey> should be 29 length');
              }
              if (_auth.secretKey.length != 29) {
                hints.add('<secretKey> should be 29 length');
              }
              if (hints.isEmpty) {
                this.auth = _auth;
                widget.onChanged(this.auth);
                EasyLoading.showSuccess('Updated');
              } else {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    return SimpleCancelOkDialog(
                      title: Text(S.current.warning),
                      content: Text([...hints, '\nStill continue?'].join('\n')),
                      onTapOk: () {
                        this.auth = _auth;
                        widget.onChanged(this.auth);
                        EasyLoading.showSuccess('Updated');
                        if (mounted) setState(() {});
                      },
                    );
                  },
                );
              }
            },
            child: Text(S.current.update),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ));

    children.add(const SafeArea(child: SizedBox()));

    return Scaffold(
      appBar: AppBar(title: Text(S.current.login_auth)),
      body: ListView(
        children: children,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          label: Text(label),
          border: const OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        contextMenuBuilder: (context, editableTextState) =>
            AdaptiveTextSelectionToolbar.editableText(
                editableTextState: editableTextState),
      ),
    );
  }

  Future<UserAuth?> readAuthFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) return null;
      final bytes = result.files.first.bytes?.toList();
      if (bytes == null) {
        EasyLoading.showError(S.current.failed);
        return null;
      }
      // xx 01 5A 53 76 2F
      // ?  ?  Z  S  v  /
      print(bytes.length);
      // print(bytes);
      if (!(bytes[2] == 0x5A && bytes[3] == 0x53 && bytes[4] == 0x76)) {
        EasyLoading.showError('Not a transfer code file');
        return null;
      }
      EasyLoading.show(status: 'Decoding...');
      String encrypted = utf8.decode(bytes.skip(2).toList());
      print(encrypted);
      final res = await decodeAuth(encrypted);
      widget.onChanged(res);
      EasyLoading.showSuccess(S.current.success);
      return res;
    } catch (e, s) {
      logger.e('decode auth failed', e, s);
      EasyLoading.showError(escapeDioError(e));
    } finally {
      if (mounted) setState(() {});
    }
    return null;
  }

  Future<UserAuth> decodeAuth(String code) async {
    // check base64 and length
    code = UserAuth.normTransferCode(code);
    if (code.isEmpty) {
      throw ArgumentError('Input string is empty');
    }
    try {
      print(base64.decode(code).length);
    } catch (e, s) {
      logger.e('invalid base64 string', e, s);
      throw ArgumentError('Invalid base64 string');
    }
    const key = 'b5nHjsMrqaeNliSs3jyOzgpD'; // 24-byte
    const iv = 'wuD6keVr';
    DES3 des3CBC = DES3(
      key: utf8.encode(key),
      mode: DESMode.CBC,
      iv: utf8.encode(iv),
    );
    final decrypted =
        utf8.decode(des3CBC.decrypt(base64.decode(code))).trimChar('\b');
    final data = jsonDecode(decrypted);
    return auth = UserAuth(
      code: code,
      authKey: data['authKey'] as String,
      secretKey: data['secretKey'] as String,
      userId: data['userId'] as String,
      saveDataVer: data['SaveDataVer'] as String,
      userCreateServer: data['userCreateServer'] as String,
    );
  }
}
