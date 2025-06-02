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
  LoginPage({super.key});

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

  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: secrets.user?.name)
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
        title: Text(
          mode == _PageMode.login
              ? S.current.login_login
              : mode == _PageMode.signup
              ? S.current.login_signup
              : S.current.login_change_password,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          nameInput,
          const SizedBox(height: 12),
          pwdInput,
          const SizedBox(height: 12),
          if (mode == _PageMode.changePwd) ...[changePwdInput, const SizedBox(height: 12)],
          if (mode == _PageMode.changePwd || mode == _PageMode.signup) ...[confirmPwdInput, const SizedBox(height: 12)],
          if (mode == _PageMode.changeName) ...[changeNameInput, const SizedBox(height: 12)],
          Text(S.current.chaldea_account_system_hint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          mainAction(),
          OverflowBar(alignment: MainAxisAlignment.center, children: otherActions()),
          if (mode == _PageMode.login)
            OverflowBar(alignment: MainAxisAlignment.center, children: [forgotPwdBtn, logoutBtn, deleteAccountBtn]),
          if (db.settings.secrets.user?.isAdmin == true)
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: isLoginAvailable() ? doAdminResetPwd : null,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: Text('${S.current.reset}(Admin)'),
                ),
              ],
            ),
          if (kDebugMode) ListTile(title: Center(child: Text('Server: ${db.apiWorkerDio.options.baseUrl}'))),
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

  Widget get loginBtn =>
      ElevatedButton(onPressed: isLoginAvailable() ? doLogin : null, child: Text(S.current.login_login));

  Widget get logoutBtn => TextButton(
    onPressed: secrets.isLoggedIn ? doLogout : null,
    child: Text(S.current.login_logout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
  );

  Widget get deleteAccountBtn => TextButton(
    onPressed: doDelete,
    child: Text(S.current.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
  );

  Widget get signupBtn =>
      ElevatedButton(onPressed: isSignUpAvailable() ? doSignUp : null, child: Text(S.current.login_signup));

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
        builder: (context) => SimpleConfirmDialog(
          title: Text(S.current.login_forget_pwd),
          content: Text(S.current.forgot_password_hint),
          scrollable: true,
          showOk: false,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                router.push(child: FeedbackPage());
              },
              child: Text(S.current.about_feedback),
            ),
            TextButton(
              onPressed: () {
                launch(ChaldeaUrl.doc('faq'));
              },
              child: Text(S.current.faq),
            ),
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
    return TextFormField(
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
    return TextFormField(
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
    return TextFormField(
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
    return TextFormField(
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
    return TextFormField(
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
    icon: FaIcon(obscurePwd ? FontAwesomeIcons.solidEyeSlash : FontAwesomeIcons.solidEye, size: 20),
  );

  String? _validateName([String? name]) {
    name ??= _nameController.text;
    if (name.isEmpty) return null; // don't hint when input
    if (RegExp(r'^\d+$').hasMatch(name)) {
      return 'number only name is not allowed';
    } else if (!RegExp(r'^[a-zA-Z0-9_]{4,18}$').hasMatch(name)) {
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
    return name.isNotEmpty && _validateName(name) == null && pwd.isNotEmpty && _validatePwd(pwd) == null;
  }

  bool isSignUpAvailable([String? name, String? pwd, String? confirmPwd]) {
    name ??= _nameController.text;
    pwd ??= _pwdController.text;
    confirmPwd ??= _confirmPwdController.text;
    return isLoginAvailable(name, pwd) && confirmPwd == pwd;
  }

  bool isChangePasswordAvailable([String? name, String? pwd, String? newPwd]) {
    name ??= _nameController.text;
    pwd ??= _pwdController.text;
    newPwd ??= _newPwdController.text;
    return isLoginAvailable(name, pwd) && newPwd.isNotEmpty && _validateNewPwd(newPwd) == null;
  }

  bool isChangeNameAvailable([String? name, String? pwd, String? newName]) {
    name ??= _nameController.text;
    pwd ??= _pwdController.text;
    newName ??= _newNameController.text;
    return isLoginAvailable(name, pwd) && newName.isNotEmpty && _validateNewName(newName) == null;
  }

  void _update() {
    if (mounted) setState(() {});
    db.notifySettings();
  }

  Future<void> doLogin() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (!isLoginAvailable(name, pwd)) return;
    final user = await showEasyLoading(() => ChaldeaWorkerApi.login(username: name, password: pwd));
    if (user != null) {
      secrets.user = user;
      EasyLoading.showSuccess(S.current.success);
    }
    _update();
  }

  void doLogout() async {
    final resp = await showEasyLoading(() => ChaldeaWorkerApi.logout());
    if (resp != null) {
      secrets.user = null;
      if (mounted) {
        _nameController.text = '';
        _pwdController.text = '';
        _newPwdController.text = '';
      }
      if (mounted) resp.showDialog();
    }
    _update();
  }

  void doDelete() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (pwd.isEmpty || name.isEmpty) {
      EasyLoading.showInfo('Please fill name and password');
      return;
    }
    final resp = await showEasyLoading(() => ChaldeaWorkerApi.deleteUser(username: name, password: pwd));
    if (resp != null) {
      secrets.user = null;
      if (mounted) {
        _nameController.clear();
        _pwdController.clear();
      }
      if (mounted) resp.showDialog(context);
    }
    _update();
  }

  Future<void> doSignUp() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (!isLoginAvailable(name, pwd)) {
      return;
    }
    final user = await showEasyLoading(() => ChaldeaWorkerApi.signup(username: name, password: pwd));
    if (user != null) {
      // secrets.user = user;
      EasyLoading.showSuccess('${S.current.login_signup}: ${S.current.success}');
    }
    _update();
  }

  Future<void> doChangePwd() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    String newPwd = _newPwdController.text;
    if (!isChangePasswordAvailable(name, pwd, newPwd)) {
      return;
    }
    final user = await showEasyLoading(
      () => ChaldeaWorkerApi.changePassword(username: name, password: pwd, newPassword: newPwd),
    );
    if (user != null) {
      secrets.user = user;
      EasyLoading.showSuccess(S.current.success);
    }
    _update();
  }

  Future<void> doAdminResetPwd() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (!isLoginAvailable(name, pwd)) {
      return;
    }
    final confirm = await SimpleConfirmDialog(
      title: const Text('Reset Password (Admin only)'),
      content: Text('user: $name\npassword: $pwd'),
    ).showDialog(context);
    if (confirm != true) return;
    final resp = await showEasyLoading(() => ChaldeaWorkerApi.adminResetPassword(username: name, password: pwd));
    if (resp != null) {
      resp.showDialog();
    }
    _update();
  }

  Future<void> doChangeName() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    String newName = _newNameController.text;
    final user = await showEasyLoading(
      () => ChaldeaWorkerApi.renameUser(username: name, password: pwd, newUsername: newName),
    );
    if (user != null) {
      secrets.user = user;
      EasyLoading.showSuccess(S.current.success);
    }
    _update();
  }
}
