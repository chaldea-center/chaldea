import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/feedback_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _PageMode { login, signup, changePwd }

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
  bool obscurePwd = true;

  @override
  void initState() {
    String _decode(String? v) {
      try {
        return b64(v ?? '');
      } catch (e) {
        return '';
      }
    }

    super.initState();
    _nameController = TextEditingController(text: db.prefs.userName.get())
      ..addListener(() {
        setState(() {});
      });
    _pwdController =
        TextEditingController(text: _decode(db.prefs.userPwd.get()))
          ..addListener(() {
            setState(() {});
          });
    _newPwdController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
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
          Text(
            LocalizedText.of(
              chs: '十分简易的系统，仅用于备份数据到服务器并实现多设备同步\n'
                  '极mei低you安全性保证，请务必不要使用常用密码！！！',
              jpn: 'サーバーにデータをバックアップし、マルチデバイス同期を実現するためにのみ使用されるシンプルなシステム\n'
                  'セキュリティの保証はありません。一般的なパスワードは使用しないでください！！！',
              eng:
                  'A simple account system for userdata backup to server and multi-device synchronization\n'
                  'NO security guarantee, PLEASE DON\'T set frequently used passwords!!!',
              kor: '서버에 데이터를 백업해서 멀티 디바이스기기 동기화를 구현하기만을 위한 간단한 시스템\n'
                  '시큐리티는 보장하지 않습니다. 일반적인 비밀번호는 사용하지 말아주세요!!!',
            ),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
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
              ],
            ),
          if (kDebugMode)
            ListTile(
              title: Center(
                child: Text('Server: ${db.serverDio.options.baseUrl}'),
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
    }
  }

  List<Widget> otherActions() {
    switch (mode) {
      case _PageMode.login:
        return [_toChangePwdBtn, _toSignupBtn];
      case _PageMode.signup:
        return [_toLoginBtn];
      case _PageMode.changePwd:
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

  Widget get signupBtn => ElevatedButton(
        onPressed: isLoginAvailable() ? doSignUp : null,
        child: Text(S.current.login_signup),
      );

  Widget get changePwdBtn => ElevatedButton(
        onPressed: isChangePasswordAvailable() ? doChangePwd : null,
        child: Text(S.current.login_change_password),
      );

  Widget get forgotPwdBtn => TextButton(
        onPressed: () {
          SimpleCancelOkDialog(
            title: Text(S.current.login_forget_pwd),
            content: Text(LocalizedText.of(
                chs: '请通过反馈页面的【邮件】地址联系',
                jpn: 'フィードバックページの「メールアドレス」からご連絡ください ',
                eng:
                    'Please contact developer through feedback page with *Email*',
                kor: '피드백 페이지의 *【메일주소】로 연락하여 주시길 바랍니다 ')),
            scrollable: true,
            hideOk: true,
            actions: [
              TextButton(
                  onPressed: () {
                    SplitRoute.push(context, FeedbackPage());
                  },
                  child: Text(S.current.about_feedback))
            ],
          ).showDialog(context);
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
        suffixIcon: IconButton(
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
        ),
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
        suffixIcon: IconButton(
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
        ),
      ),
    );
  }

  String? _validateName([String? name]) {
    name ??= _nameController.text;
    if (name.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9]{3,}$').hasMatch(name)) {
      return S.current.login_username_error;
    }
  }

  String? _validatePwd([String? pwd]) {
    pwd ??= _pwdController.text;
    if (pwd.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z0-9]{4,}$').hasMatch(pwd)) {
      return S.current.login_password_error;
    }
  }

  String? _validateNewPwd([String? newPwd]) {
    newPwd ??= _newPwdController.text;
    if (newPwd.isEmpty) return null;
    if (newPwd == _pwdController.text) {
      return S.current.login_password_error_same_as_old;
    }
    return _validatePwd(newPwd);
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

  Future<void> doLogin() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (isLoginAvailable(name, pwd)) {
      await catchErrorAsync(() async {
        EasyLoading.show(maskType: EasyLoadingMaskType.clear);
        var resp = ChaldeaResponse.fromResponse(await db.serverDio
            .post('/user/login', data: {
          HttpUtils.usernameKey: name,
          HttpUtils.passwordKey: b64(pwd, false)
        }));
        if (resp.success) {
          _saveUserInfo(name, pwd);
        }
        resp.showMsg(context, title: S.current.login_login);
      }).whenComplete(() => EasyLoadingUtil.dismiss(null));
    }
  }

  void doLogout() {
    db.prefs.userName.remove();
    db.prefs.userPwd.remove();
    db.notifyDbUpdate();
    SimpleCancelOkDialog(
      content: Text(LocalizedText.of(
          chs: '已清除本地登陆信息',
          jpn: 'ローカル ログイン情報が消去されました',
          eng: 'Cleared local login info',
          kor: '로컬 로그인 정보가 소실되었습니다')),
    ).showDialog(context);
  }

  @Deprecated('do not use')
  void doDelete() {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    SimpleCancelOkDialog(
      title: Text(LocalizedText.of(
          chs: '删除账户',
          jpn: 'アカウントを削除',
          eng: 'Delete User Account',
          kor: '계정 삭제')),
      content: Text(LocalizedText.of(
          chs: '包括所有服务器备份',
          jpn: 'また、すべてのサーバー バックアップを削除します',
          eng: 'Including backups on server',
          kor: '모든 서버 백업을 포함하여 삭제됩니다')),
      onTapOk: () async {
        var resp = ChaldeaResponse.fromResponse(await db.serverDio
            .post('/user/deleteAccount', data: {
          HttpUtils.usernameKey: name,
          HttpUtils.passwordKey: b64(pwd, false)
        }));
        resp.showMsg(context);
      },
    ).showDialog(context);
  }

  Future<void> doSignUp() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    if (isLoginAvailable(name, pwd)) {
      await catchErrorAsync(() async {
        EasyLoading.show(maskType: EasyLoadingMaskType.clear);
        var resp = ChaldeaResponse.fromResponse(await db.serverDio
            .post('/user/signup', data: {
          HttpUtils.usernameKey: name,
          HttpUtils.passwordKey: b64(pwd, false)
        }));
        if (resp.success) {
          _saveUserInfo(name, pwd);
        }
        resp.showMsg(context, title: S.current.login_signup);
      }).whenComplete(() => EasyLoadingUtil.dismiss(null));
    }
  }

  Future<void> doChangePwd() async {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    String newPwd = _newPwdController.text;
    if (isChangePasswordAvailable(name, pwd, newPwd)) {
      await catchErrorAsync(() async {
        EasyLoading.show(maskType: EasyLoadingMaskType.clear);
        var resp = ChaldeaResponse.fromResponse(
            await db.serverDio.post('/user/changePassword', data: {
          HttpUtils.usernameKey: name,
          HttpUtils.passwordKey: b64(pwd, false),
          HttpUtils.newPasswordKey: b64(newPwd, false),
        }));
        if (resp.success) {
          _saveUserInfo(name, newPwd);
        }
        resp.showMsg(context, title: S.current.login_change_password);
      }).whenComplete(() => EasyLoadingUtil.dismiss(null));
    }
  }

  void _saveUserInfo(String name, String pwd) {
    db.prefs.userName.set(name);
    db.prefs.userPwd.set(b64(pwd, false));
    db.notifyDbUpdate();
  }
}
