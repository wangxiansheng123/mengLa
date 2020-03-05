import 'package:fluttertoast/fluttertoast.dart';

const String resCode_login_required = '920001';

class LoginCheck {
  static bool isLoginRequire(dynamic response) {
    if (response is Map) {
      String rspCode = response['rspCode'];
      return rspCode == resCode_login_required;
    }
    return false;
  }

  static showErrorTips(Map response) {
    Fluttertoast.showToast(msg: response['rspMsg'] ?? '登录失效，请重新登录！');
  }
}
