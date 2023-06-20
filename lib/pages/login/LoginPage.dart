import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginState createState()=>_LoginState();
}

class _LoginState extends State<LoginPage> with SingleTickerProviderStateMixin{

  final _userAccountController = TextEditingController();
  final _userPwdController = TextEditingController();

  var _isShowPwd = true;
  var _isShowClear = false;
  var _isSaveInfo = false;

  List<Map<String, dynamic>> userInfo=[{}];

  //补间动画
  late Animation<double> tween  ;
  late AnimationController controller;

  @override
  void initState(){

    _userAccountController.addListener((){
      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      setState(() {
        if (_userAccountController.text.isNotEmpty) {
          _isShowClear = true;
        }else{
          _isShowClear = false;
        }
      });
    });
    _getSavedInfo();
    print('初始化');
    super.initState();

    controller=AnimationController(
        duration: const Duration(milliseconds: 2000),vsync: this);
    tween=Tween(begin: 0.0,end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          print(tween.value);
        });
      });
    controller.forward();
  }

  startAnimation(){
    setState(() {
      controller.forward(from: 0.0);
    });
  }

  void _getSavedInfo()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userAccountController.text=prefs.getString('userName')!;
    _userPwdController.text=prefs.getString('userPwd')!;
    _isSaveInfo = prefs.getBool('savedInfo')!;
    print(_userAccountController.text);
    print(_userPwdController.text);
    if(_isSaveInfo){
      print('记住密码');
    }else{
      print('忘记密码');
    }
  }

  void _setSavedInfo()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userAccountController.text);
    await prefs.setString('userPwd', _userPwdController.text);
    await prefs.setBool('savedInfo', _isSaveInfo);
  }

  void _clearSavedInfo()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userAccountController.text);
    await prefs.setString('userPwd', _userPwdController.text);
    await prefs.setBool('savedInfo', _isSaveInfo);
    var a = prefs.getString('userName')!;
    print(a);
    var b = prefs.getString('userPwd')!;
    print(b);
    if(_isSaveInfo){
      print('已经记住密码');
    }else{
      print('已经忘记密码');
    }
    prefs.remove('userPwd');
  }

  _login() async {
    var url = Uri.parse('http://a408599l51.wicp.vip/Login/login');
    Utf8Decoder decode = new Utf8Decoder();
    var response = await http.post(url, body: {"loginAccount": _userAccountController.text, "loginPassword": _userPwdController.text});
    setState(() {
      userInfo = new List<Map<String, dynamic>>.from(json.decode(decode.convert(response.bodyBytes)));
      print(userInfo);
      if(userInfo.isNotEmpty){
        Navigator.pushNamed(context,"/Home" , arguments: {
          "loginAccount" : userInfo[0]['loginAccount'],
          "loginRole" : userInfo[0]['loginRole'],
          "loginName" : userInfo[0]['loginName'],
          "loginMail" : userInfo[0]['loginMail'],
          'profilePhoto':userInfo[0]['profilePhoto'],
        });
      }else{
        Fluttertoast.showToast(
            msg: "账号或密码错误",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: ()=>{
          startAnimation(),
          FocusScope.of(context).requestFocus(FocusNode())
        },
        child:Container(
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 100, 20,100),
                child: Text(
                  'App Store',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    //动画设置的组件
                      fontSize: 40 * (controller.value),
                      color: Color(0xFF87CEFF),
                      letterSpacing: 3
                  ),
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
                          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: InputDecoration(
                          hintText: '请输入账号',
                          prefixIcon: Icon(Icons.person),
                          suffixIcon: (_isShowClear)
                              ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: (){
                              _userAccountController.clear();
                            },
                          )
                              :null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _userPwdController,
                        obscureText: _isShowPwd,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9+]')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: InputDecoration(
                            hintText: '请输入密码',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon((_isShowPwd) ? Icons.visibility_off : Icons.visibility),
                              onPressed: (){
                                setState(() {
                                  _isShowPwd=!_isShowPwd;
                                });
                              },
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 50,),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(0),
                        width: 300,
                        child: ElevatedButton(
                          child: Text('登录'),
                          onPressed: (){
                            setState(() {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _login();
                            });
                            if(_isSaveInfo){
                              _setSavedInfo();
                            }else {
                              _clearSavedInfo();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xAA66CDAA)),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20)),
                            shape: MaterialStateProperty.all(
                                const StadiumBorder(
                                    side: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Color(0xAA66CDAA),
                                    )
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                        flex: 1,
                        child: Container(
                          width: 300,
                          child: ElevatedButton(
                            child: Text('注册'),
                            onPressed: (){
                              Navigator.pushNamed(context, '/login/register');
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xAA87C1FF)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20)),
                              shape: MaterialStateProperty.all(
                                  const StadiumBorder(
                                      side: BorderSide(
                                        style: BorderStyle.solid,
                                        color: Color(0xAA87C1FF),
                                      )
                                  )
                              ),
                            ),
                          ),
                        )
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isSaveInfo,
                                onChanged: (value){
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
                            Navigator.pushNamed(context, "/login/forget",arguments: {
                              'loginAccount':_userAccountController.text
                            });
                          },
                        child: Text('忘记密码',style: TextStyle(color: Colors.blue)),)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }
}