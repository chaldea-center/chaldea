import 'package:chaldea/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _nameController;
  late TextEditingController _pwdController;
  late TextEditingController _newPwdController;
  bool obscurePwd = true;
  bool changePwdMde = false;

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
        leading: BackButton(),
        title: Text('${S.current.login_login}/${S.current.login_signup}'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          TextField(
            controller: _nameController,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: S.current.login_username,
              border: OutlineInputBorder(),
              errorText: _validateName(),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 12)),
          TextField(
            controller: _pwdController,
            autocorrect: false,
            obscureText: obscurePwd,
            decoration: InputDecoration(
              labelText: S.current.login_password,
              border: OutlineInputBorder(),
              errorText: _validatePwd(),
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
          ),
          SwitchListTile.adaptive(
            value: changePwdMde,
            title: Text(S.current.login_change_password),
            onChanged: (v) {
              setState(() {
                changePwdMde = v;
              });
            },
          ),
          Padding(padding: EdgeInsets.only(bottom: 12)),
          if (changePwdMde)
            TextField(
              controller: _newPwdController,
              autocorrect: false,
              obscureText: obscurePwd,
              decoration: InputDecoration(
                labelText: S.current.login_new_password,
                border: OutlineInputBorder(),
                errorText: _validateNewPwd(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePwd = !obscurePwd;
                    });
                  },
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: obscurePwd ? Colors.grey : null,
                  ),
                ),
              ),
            ),
          Text(
            S.current.login_hint_text,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            overflowButtonSpacing: 6,
            children: [
              if (!changePwdMde)
                ElevatedButton(
                  onPressed: isLoginAvailable() ? doLogin : null,
                  child: Text(S.current.login_login),
                ),
              if (!changePwdMde)
                ElevatedButton(
                  onPressed: isLoginAvailable() ? doSignUp : null,
                  child: Text(S.current.login_signup),
                ),
              if (changePwdMde)
                ElevatedButton(
                  onPressed: isChangePasswordAvailable() ? doChangePwd : null,
                  child: Text(S.current.login_change_password),
                ),
              if (!changePwdMde)
                ElevatedButton(
                  onPressed: doLogout,
                  child: Text(S.current.login_logout),
                ),
              if (!changePwdMde)
                ElevatedButton(
                  onPressed: isLoginAvailable() ? doDelete : null,
                  child: Text(S.current.delete),
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).errorColor),
                ),
            ],
          )
        ],
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
    if (newPwd == _pwdController.text)
      return S.current.login_password_error_same_as_old;
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
      });
      EasyLoading.dismiss();
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
          eng: 'Cleared local login info')),
    ).showDialog(context);
  }

  void doDelete() {
    String name = _nameController.text;
    String pwd = _pwdController.text;
    SimpleCancelOkDialog(
      title: Text(LocalizedText.of(
          chs: '删除账户', jpn: 'アカウントを削除', eng: 'Delete User Account')),
      content: Text(LocalizedText.of(
          chs: '包括所有服务器备份',
          jpn: 'また、すべてのサーバー バックアップを削除します',
          eng: 'Including backups on server')),
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
      });
      EasyLoading.dismiss();
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
      });
      EasyLoading.dismiss();
    }
  }

  void _saveUserInfo(String name, String pwd) {
    db.prefs.userName.set(name);
    db.prefs.userPwd.set(b64(pwd, false));
    db.notifyDbUpdate();
  }
}
