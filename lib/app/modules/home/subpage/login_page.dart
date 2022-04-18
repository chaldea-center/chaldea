import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/home/subpage/feedback_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';

enum _PageMode { login, signup, changePwd, changeName }

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _PageMode mode = _PageMode.login;
  late TextEditingController _nameController;
  late TextEditingController _pwdController;
  late TextEditingController _newPwdController;
  late TextEditingController _confirmPwdController;
  late TextEditingController _newNameController;
  bool obscurePwd = true;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: db.security.get('chaldea_user')?.toString())
          ..addListener(() {
            setState(() {});
          });
    _pwdController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _newPwdController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _confirmPwdController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _newNameController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _pwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    _newNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == _PageMode.login
            ? S.current.login_login
            : mode == _PageMode.signup
                ? S.current.login_signup
                : S.current.login_change_password),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          nameInput,
          const SizedBox(height: 12),
          pwdInput,
          const SizedBox(height: 12),
          if (mode == _PageMode.changePwd) ...[
            changePwdInput,
            const SizedBox(height: 12),
          ],
          if (mode == _PageMode.changePwd || mode == _PageMode.signup) ...[
            confirmPwdInput,
            const SizedBox(height: 12),
          ],
          if (mode == _PageMode.changeName) ...[
            changeNameInput,
            const SizedBox(height: 12),
          ],
          Text(
            S.current.chaldea_account_system_hint,
            style: Theme.of(context).textTheme.caption,
          ),
          const SizedBox(height: 8),
          mainAction(),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: otherActions(),
          ),
          if (mode == _PageMode.login)
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                forgotPwdBtn,
                logoutBtn,
                deleteAccountBtn,
              ],
            ),
          if (kDebugMode)
            ListTile(
              title: Center(
                child: Text('Server: ${db.apiWorkerDio.options.baseUrl}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget mainAction() {
    switch (mode) {
      case _PageMode.login:
        return loginBtn;
      case _PageMode.signup:
        return signupBtn;
      case _PageMode.changePwd:
        return changePwdBtn;
      case _PageMode.changeName:
        return changeNameBtn;
    }
  }

  List<Widget> otherActions() {
    switch (mode) {
      case _PageMode.login:
        return [_toChangePwdBtn, _toChangeNameBtn, _toSignupBtn];
      case _PageMode.signup:
      case _PageMode.changePwd:
      case _PageMode.changeName:
        return [_toLoginBtn];
    }
  }

  Widget get loginBtn => ElevatedButton(
        onPressed: isLoginAvailable() ? doLogin : null,
        child: Text(S.current.login_login),
      );

  Widget get logoutBtn => TextButton(
        onPressed: doLogout,
        child: Text(
          S.current.login_logout,
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
      );

  Widget get deleteAccountBtn => TextButton(
        onPressed: doDelete,
        child: Text(
          S.current.delete,
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
      );

  Widget get signupBtn => ElevatedButton(
        onPressed: isLoginAvailable() ? doSignUp : null,
        child: Text(S.current.login_signup),
      );

  Widget get changePwdBtn => ElevatedButton(
        onPressed: isChangePasswordAvailable() ? doChangePwd : null,
        child: Text(S.current.login_change_password),
      );

  Widget get changeNameBtn => ElevatedButton(
        onPressed: isChangeNameAvailable() ? doChangeName : null,
        child: Text(S.current.login_change_name),
      );

  Widget get forgotPwdBtn => TextButton(
        onPressed: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => SimpleCancelOkDialog(
              title: Text(S.current.login_forget_pwd),
              content: const Text(
                  'Please contact developer through feedback page with *Email*'),
              scrollable: true,
              hideOk: true,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    router.push(child: FeedbackPage());
                  },
                  child: Text(S.current.about_feedback),
                )
              ],
            ),
          );
        },
        child: Text(S.current.login_forget_pwd),
      );

  Widget get _toLoginBtn => TextButton(
        onPressed: () {
          setState(() {
            mode = _PageMode.login;
          });
        },
        child: Text(S.current.login_login),
      );

  Widget get _toSignupBtn => TextButton(
        onPressed: () {
          setState(() {
            mode = _PageMode.signup;
          });
        },
        child: Text(S.current.login_signup),
      );

  Widget get _toChangePwdBtn => TextButton(
        onPressed: () {
          setState(() {
            mode = _PageMode.changePwd;
          });
        },
        child: Text(S.current.login_change_password),
      );
  Widget get _toChangeNameBtn => TextButton(
        onPressed: () {
          setState(() {
            mode = _PageMode.changeName;
          });
        },
        child: Text(S.current.login_change_name),
      );

  Widget get nameInput {
    return TextField(
      controller: _nameController,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: S.current.login_username,
        border: const OutlineInputBorder(),
        errorText: _validateName(),
        errorMaxLines: 3,
      ),
    );
  }

  Widget get pwdInput {
    return TextField(
      controller: _pwdController,
      autocorrect: false,
      obscureText: obscurePwd,
      decoration: InputDecoration(
        labelText: S.current.login_password,
        border: const OutlineInputBorder(),
        errorText: _validatePwd(),
        errorMaxLines: 3,
        suffixIcon: _pwdVisibilityBtn,
      ),
    );
  }

  Widget get changePwdInput {
    return TextField(
      controller: _newPwdController,
      autocorrect: false,
      obscureText: obscurePwd,
      decoration: InputDecoration(
        labelText: S.current.login_new_password,
        border: const OutlineInputBorder(),
        errorText: _validateNewPwd(),
        errorMaxLines: 3,
        suffixIcon: _pwdVisibilityBtn,
      ),
    );
  }

  Widget get changeNameInput {
    return TextField(
      controller: _newNameController,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: S.current.login_new_name,
        border: const OutlineInputBorder(),
        errorText: _validateNewName(),
        errorMaxLines: 3,
      ),
    );
  }

  Widget get confirmPwdInput {
    return TextField(
      controller: _confirmPwdController,
      autocorrect: false,
      obscureText: obscurePwd,
      decoration: InputDecoration(
        labelText: S.current.login_confirm_password,
        border: const OutlineInputBorder(),
        errorText: _validConfirmPwd(),
        errorMaxLines: 3,
        suffixIcon: _pwdVisibilityBtn,
      ),
    );
  }

  Widget get _pwdVisibilityBtn => IconButton(
        onPressed: () {
          setState(() {
            obscurePwd = !obscurePwd;
          });
        },
        icon: FaIcon(
          obscurePwd
              ? FontAwesomeIcons.solidEyeSlash
              : FontAwesomeIcons.solidEye,
          size: 20,
        ),
      );

  String? _validateName([String? name]) {
    name ??= _nameController.text;
    if (name.isEmpty) return null; // don't hint when input
    if (RegExp(r'^\d+$').hasMatch(name)) {
      return 'number only name is not allowed';
    } else if (!RegExp(r'^[a-zA-Z0-9_]{6,18}$').hasMatch(name)) {
      return S.current.login_username_error;
    }
    return null;
  }

  String? _validatePwd([String? pwd]) {
    pwd ??= _pwdController.text;
    if (pwd.isEmpty) return null;
    if (RegExp(r'^\d+$').hasMatch(pwd)) {
      return 'number only password is not allowed';
    } else if (!RegExp(r'^[\x21-\x7e]{6,18}$').hasMatch(pwd)) {
      return S.current.login_password_error;
    }
    return null;
  }

  String? _validateNewPwd([String? newPwd]) {
    newPwd ??= _newPwdController.text;
    if (newPwd.isEmpty) return null;
    if (newPwd == _pwdController.text) {
      return S.current.login_password_error_same_as_old;
    }
    return _validatePwd(newPwd);
  }

  String? _validateNewName([String? newName]) {
    newName ??= _newNameController.text;
    if (newName.isEmpty) return null;
    if (_newNameController.text == _nameController.text) {
      return 'Name not changed';
    }
    return _validateName(_newNameController.text);
  }

  String? _validConfirmPwd() {
    String? pwd1;
    if (mode == _PageMode.changePwd) {
      pwd1 = _newPwdController.text;
    } else if (mode == _PageMode.signup) {
      pwd1 = _pwdController.text;
    }
    if (pwd1 != _confirmPwdController.text) {
      return 'Password does not match';
    }
    return null;
  }

  bool isLoginAvailable([String? name, String? pwd]) {
    name ??= _nameController.text;
    pwd ??= _pwdController.text;
    return name.isNotEmpty &&
        _validateName(name) == null &&
        pwd.isNotEmpty &&
        _validatePwd(pwd) == null;
  }

  bool isChangePasswordAvailable([String? name, String? pwd, String? newPwd]) {
    name ??= _nameController.text;
    pwd ??= _pwdController.text;
    newPwd ??= _newPwdController.text;
    return isLoginAvailable(name, pwd) &&
        newPwd.isNotEmpty &&
        _validateNewPwd(newPwd) == null;
  }

  bool isChangeNameAvailable([String? name, String? pwd, String? newName]) {
    name ??= _nameController.text;
    pwd ??= _pwdController.text;
    newName ??= _newNameController.text;
    return isLoginAvailable(name, pwd) &&
        newName.isNotEmpty &&
        _validateNewName(newName) == null;
  }

  Future<void> doLogin() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (!isLoginAvailable(name, pwd)) return;
    ChaldeaResponse.request(
      caller: (dio) =>
          dio.post('/account/login', data: {'username': name, 'pwd': pwd}),
      onSuccess: (resp) {
        _saveUserInfo(name, resp.body());
      },
    );
  }

  void doLogout() {
    db.security.delete('chaldea_user');
    db.security.delete('chaldea_auth');
    _nameController.text = '';
    _pwdController.text = '';
    _newPwdController.text = '';
    const SimpleCancelOkDialog(content: Text('Cleared local login info'))
        .showDialog(context);
  }

  void doDelete() {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (pwd.isEmpty) {
      EasyLoading.showInfo('Please fill the password');
      return;
    }
    SimpleCancelOkDialog(
      title: const Text('Delete User Account'),
      content: const Text('Including backups on server'),
      onTapOk: () async {
        ChaldeaResponse.request(
          caller: (dio) => dio.post('/account/delete', data: {
            'username': name,
            'pwd': pwd,
          }),
        );
      },
    ).showDialog(context);
  }

  Future<void> doSignUp() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (!isLoginAvailable(name, pwd)) {
      return;
    }
    ChaldeaResponse.request(
      caller: (dio) =>
          dio.post('/account/create', data: {'username': name, 'pwd': pwd}),
      onSuccess: (resp) {
        _saveUserInfo(name, resp.body());
      },
    );
  }

  Future<void> doChangePwd() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    String newPwd = _newPwdController.text;
    if (!isChangePasswordAvailable(name, pwd, newPwd)) {
      return;
    }
    ChaldeaResponse.request(
      caller: (dio) => dio.post('/account/changepassword', data: {
        'username': name,
        'pwd': pwd,
        'new_pwd': newPwd,
      }),
      onSuccess: (resp) {
        _saveUserInfo(name, resp.body());
      },
    );
  }

  Future<void> doChangeName() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    String newName = _newNameController.text;
    ChaldeaResponse.request(
      caller: (dio) => dio.post('/account/changename', data: {
        'username': name,
        'pwd': pwd,
        'new_name': newName,
      }),
      onSuccess: (resp) {
        _saveUserInfo(newName, null);
      },
    );
  }

  void _saveUserInfo(String name, String? auth) {
    db.security.put('chaldea_user', name);
    if (auth != null) {
      db.security.put('chaldea_auth', auth);
    }
    db.notifySettings();
  }
}
