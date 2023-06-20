import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

// 定义 LoginPage 的状态类 _LoginState，该类继承自 State<LoginPage> 并混入 SingleTickerProviderStateMixin，用于处理动画
class _LoginState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // 定义账号和密码输入框的控制器
  final _userAccountController = TextEditingController();
  final _userPwdController = TextEditingController();

  // 定义几个 bool 类型的变量，用于控制密码显示、清除按钮显示、信息保存的状态
  var _isShowPwd = true; // 是否显示密码
  var _isShowClear = false; // 是否显示清除按钮
  var _isSaveInfo = false; // 是否保存信息

  List<Map<String, dynamic>> userInfo = [{}]; // 保存用户信息的 List

  // 定义动画相关的变量
  late Animation<double> tween; // 补间动画
  late AnimationController controller; // 动画控制器

  // 初始化状态
  @override
  void initState() {
    // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
    _userAccountController.addListener(() {
      setState(() {
        if (_userAccountController.text.isNotEmpty) {
          _isShowClear = true;
        } else {
          _isShowClear = false;
        }
      });
    });
    // 获取保存的信息
    _getSavedInfo();

    // 初始化动画控制器和补间动画
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    tween = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    // 启动动画
    controller.forward();
  }

  // 开始动画的方法
  startAnimation() {
    setState(() {
      controller.forward(from: 0.0);
    });
  }

  // 获取保存的信息
  void _getSavedInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userAccountController.text = prefs.getString('userName')!;
    _userPwdController.text = prefs.getString('userPwd')!;
    _isSaveInfo = prefs.getBool('savedInfo')!;
  }

  // 保存信息
  void _setSavedInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userAccountController.text);
    await prefs.setString('userPwd', _userPwdController.text);
    await prefs.setBool('savedInfo', _isSaveInfo);
  }

  // 清除保存的信息
  void _clearSavedInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userAccountController.text);
    await prefs.setString('userPwd', _userPwdController.text);
    await prefs.setBool('savedInfo', _isSaveInfo);
    prefs.remove('userPwd');
  }

  // 登录方法，发送 POST 请求并处理返回的用户信息
  _login() async {
    // var url = Uri.parse('http://a408599l51.wicp.vip/Login/login');
    // Utf8Decoder decode = new Utf8Decoder();
    // var response = await http.post(url, body: {
    //   "loginAccount": _userAccountController.text,
    //   "loginPassword": _userPwdController.text
    // });
    setState(() {
      // userInfo = new List<Map<String, dynamic>>.from(
      //     json.decode(decode.convert(response.bodyBytes)));
      if (true) {
        Navigator.pushNamed(context, "/Home", arguments: {
          "loginAccount": userInfo[0]['loginAccount'],
          "loginRole": userInfo[0]['loginRole'],
          "loginName": userInfo[0]['loginName'],
          "loginMail": userInfo[0]['loginMail'],
          'profilePhoto': userInfo[0]['profilePhoto'],
        });
      } else {
        Fluttertoast.showToast(
            msg: "账号或密码错误",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

// 定义组件的布局
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () =>
          {startAnimation(), FocusScope.of(context).requestFocus(FocusNode())},
      child: Container(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 100),
              child: Text(
                'App Store',
                textAlign: TextAlign.center,
                style: TextStyle(
                    //动画设置的组件
                    fontSize: 40 * (controller.value),
                    color: Color(0xFF87CEFF),
                    letterSpacing: 3),
              ),
            ),
            Container(
              height: 320,
              margin: const EdgeInsets.fromLTRB(50, 0, 50, 20),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _userAccountController,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-Z0-9_]')),
                        LengthLimitingTextInputFormatter(20),
                      ],
                      decoration: InputDecoration(
                        hintText: '请输入账号',
                        prefixIcon: Icon(Icons.person),
                        suffixIcon: (_isShowClear)
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _userAccountController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _userPwdController,
                      obscureText: _isShowPwd,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-Z0-9+]')),
                        LengthLimitingTextInputFormatter(20),
                      ],
                      decoration: InputDecoration(
                          hintText: '请输入密码',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon((_isShowPwd)
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isShowPwd = !_isShowPwd;
                              });
                            },
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(0),
                      width: 300,
                      child: ElevatedButton(
                        child: Text('登录'),
                        onPressed: () {
                          setState(() {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _login();
                          });
                          if (_isSaveInfo) {
                            _setSavedInfo();
                          } else {
                            _clearSavedInfo();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xAA66CDAA)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 20)),
                          shape: MaterialStateProperty.all(const StadiumBorder(
                              side: BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xAA66CDAA),
                          ))),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        width: 300,
                        child: ElevatedButton(
                          child: Text('注册'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login/register');
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xAA87C1FF)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: 20)),
                            shape:
                                MaterialStateProperty.all(const StadiumBorder(
                                    side: BorderSide(
                              style: BorderStyle.solid,
                              color: Color(0xAA87C1FF),
                            ))),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isSaveInfo,
                              onChanged: (value) {
                                setState(() {
                                  _isSaveInfo = !_isSaveInfo;
                                });
                              },
                            ),
                            Text('记住密码'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/login/forget",
                              arguments: {
                                'loginAccount': _userAccountController.text
                              });
                        },
                        child:
                            Text('忘记密码', style: TextStyle(color: Colors.blue)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // 在组件被移除时，清除动画控制器
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


// 这个登录页面需要从后端接口获取的数据主要是用户的登录信息。从代码中我们可以看出，它是通过发送一个 POST 请求到 'http://a408599l51.wicp.vip/Login/login'
// 这个地址，然后在请求体中包含两个字段，即"loginAccount"和"loginPassword"，分别代表用户的登录账号和密码。
//
// 当请求成功后，后端会返回一个包含用户信息的 JSON 数据，这个数据会被转化为一个 Map 列表。根据代码，我们可以看到这个 Map 里应该包含以下的信息：
//
// - "loginAccount"：用户的登录账号。
// - "loginRole"：用户的角色。
// - "loginName"：用户的名称。
// - "loginMail"：用户的邮箱。
// - "profilePhoto"：用户的头像。
//
// 如果后端返回的数据中没有包含任何用户信息（也就是 userInfo 为空），那么会显示一条提示信息，告诉用户账号或密码错误。