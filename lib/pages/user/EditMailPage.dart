import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditMailPage extends StatefulWidget{
  Map arguments;
  EditMailPage({Key? key,required this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditMailPageState(arguments:this.arguments);
  }

}

class _EditMailPageState extends State<EditMailPage>{
  Map arguments;
  _EditMailPageState({required this.arguments});

  var _currentStep = 0;
  final _currentMailController = TextEditingController();
  final _currentCodeController = TextEditingController();
  final _newMailController = TextEditingController();
  final _newCodeController = TextEditingController();

  var _currentCode='';
  var _newCode='';

  String _record='';

  _getCurrentCode()async{
    for(int i=0;i<4;i++){
      _currentCode+=(Random().nextInt(10)).toString();
    }
    print('当前验证码${_currentCode}');
    Dio dio = Dio();
    String url = 'http://a408599l51.wicp.vip/Mail/sendMail';
    var response = await dio.get(url,queryParameters: {
      'code':_currentCode,
      'receiverMail':_currentMailController.text
    });
    print(response.data);
  }

  _getNewCode()async{
    _record=_newMailController.text;
    for(int i=0;i<4;i++){
      _newCode+=(Random().nextInt(10)).toString();
    }
    print('新验证码${_newCode}');
    Dio dio = Dio();
    String url = 'http://a408599l51.wicp.vip/Mail/sendMail';
    var response = await dio.get(url,queryParameters: {
      'code':_newCode,
      'receiverMail':_newMailController.text
    });
    print(response.data);
  }

  _updateMail()async{
    Dio dio = Dio();
    String url = 'http://a408599l51.wicp.vip/Login/updateMail';
    var response = await dio.post(url,queryParameters: {
      'loginAccount':arguments['loginAccount'],
      'loginMail':_newMailController.text
    });
    print(response.data);
    setState(() {
      if(response.statusCode==200){
        Fluttertoast.showToast(
            msg: "邮箱修改成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        _cancelTimer();
        Navigator.pop(context,'true');
      }else{
        Fluttertoast.showToast(
            msg: "邮箱修改失败",
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
  void initState(){
    _initTimer();
    super.initState();
  }

  var _isButtonEnable;  //按钮状态 是否可点击
  var buttonText; //初始文本
  var count;      //初始倒计时时间
  Timer? _timer;

  _initTimer(){
    _isButtonEnable=true;  //按钮状态 是否可点击
    buttonText='发送验证码'; //初始文本
    count=60;
  }

  void _buttonClickListen(){
    setState(() {
      if(_isButtonEnable){   //当按钮可点击时
        _isButtonEnable=false; //按钮状态标记
        _startTimer();
        return null;   //返回null按钮禁止点击
      }else{     //当按钮不可点击时
        return null;    //返回null按钮禁止点击
      }
    });
  }
  void _startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count--;
      setState(() {
        if(count==0){
          timer.cancel();    //倒计时结束取消定时器
          _isButtonEnable=true;  //按钮可点击
          count=60;     //重置时间
          buttonText='发送验证码';  //重置按钮文本
        }else{
          buttonText='重新发送($count)'; //更新文本内容
        }
      });
    });
  }

  void _cancelTimer() {
    if(_timer!=null){
      _timer!.cancel();//销毁计时器
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更换邮箱'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: ()=>{
          FocusScope.of(context).requestFocus(FocusNode())
        },
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: (){
            setState(() {
              FocusScope.of(context).requestFocus(FocusNode());
              if(_currentStep==0 && _currentMailController.text == arguments['loginMail'] && _currentCodeController.text==_currentCode){
                _currentStep++;
                _cancelTimer();
                _initTimer();
              }else if(_currentMailController.text!=arguments['loginMail']){
                Fluttertoast.showToast(
                    msg: "请输入正确的邮箱",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }else if(_currentCodeController.text!=_currentCode || _newCodeController.text != _newCode){
                Fluttertoast.showToast(
                    msg: "验证码错误",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }else if(_currentCodeController.text.isEmpty || _newCodeController.text.isEmpty){
                Fluttertoast.showToast(
                    msg: "验证码不能为空",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }else if(_newMailController.text != _currentMailController.text && _newCodeController.text == _newCode && _newMailController.text==_record){
                _updateMail();
              }else if(_newMailController.text == _currentMailController.text){
                Fluttertoast.showToast(
                    msg: "新旧邮箱不能相同",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }else{
                Fluttertoast.showToast(
                    msg: "邮箱绑定错误",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }
            });
          },
          controlsBuilder: (BuildContext context, ControlsDetails controls) {
            return Container(
              margin: EdgeInsets.only(top: 30),
              height: 45,
              child: ElevatedButton(
                onPressed: controls.onStepContinue,
                child: _currentStep==0? Text('下一步', style: TextStyle(color: Colors.white),)
                    :Text('提交', style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18,)),
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
            );
          },
          steps: [
            Step(
                isActive: _currentStep >= 0 ? true :false,
                title: Text('验证当前邮箱'),
                content: Container(
                  height: 160,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _currentMailController,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: '请输入当前邮箱',
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white,),
                            ),
                            prefixIcon: Icon(Icons.mail),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _currentCodeController,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white,),
                            ),
                            prefixIcon: Icon(Icons.drafts),
                            suffixIcon:Container(
                              margin: EdgeInsets.only(top: 5,bottom: 5,right: 10),
                              child: OutlinedButton(
                                  style: _isButtonEnable==true?OutlinedButton.styleFrom(
                                      side: BorderSide(width: 2, color: Color(0x80002FA7)),
                                      padding: EdgeInsets.only(left: 5,right: 5)
                                  ):OutlinedButton.styleFrom(
                                      side: BorderSide(width: 2, color: Colors.grey),
                                      padding: EdgeInsets.only(left: 5,right: 5)
                                  ),
                                  onPressed: () {
                                    if(_currentMailController.text==arguments['loginMail']){
                                      _getCurrentCode();
                                      _buttonClickListen();
                                    }else{
                                      Fluttertoast.showToast(
                                          msg: "邮箱错误",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                    }
                                  },
                                  child: Text(
                                    '$buttonText',
                                    style: _isButtonEnable==true?TextStyle(
                                        fontSize: 15,
                                        color: Color(0x90002FA7)
                                    ):TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Step(
                isActive: _currentStep == 1 ? true :false,
                title: Text('设置新邮箱'),
                content: Container(
                  height: 160,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _newMailController,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                              hintText: '请绑定新的邮箱',
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white,),
                              ),
                              prefixIcon: Icon(Icons.mail),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _newCodeController,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white,),
                            ),
                            prefixIcon: Icon(Icons.drafts),
                            suffixIcon:Container(
                              margin: EdgeInsets.only(top: 5,bottom: 5,right: 10),
                              child: OutlinedButton(
                                style: _isButtonEnable==true?OutlinedButton.styleFrom(
                                    side: BorderSide(width: 2, color: Color(0x80002FA7)),
                                    padding: EdgeInsets.only(left: 5,right: 5)
                                ):OutlinedButton.styleFrom(
                                    side: BorderSide(width: 2, color: Colors.grey),
                                    padding: EdgeInsets.only(left: 5,right: 5)
                                ),
                                onPressed: () {
                                  _getNewCode();
                                  _buttonClickListen();
                                },
                                child: Text(
                                  '$buttonText',
                                  style: _isButtonEnable==true?TextStyle(
                                      fontSize: 15,
                                      color: Color(0x90002FA7)
                                  ):TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}

// 这个页面中主要使用了2个接口，接口的详细信息如下：
//
// 1. 接口地址：`http://a408599l51.wicp.vip/Mail/sendMail`
//
// 接口参数：`code`, `receiverMail`
//
// 返回数据：未在代码中明确指出，但从代码逻辑推测，可能返回一个表示操作成功或失败的状态码或信息。
//
// 用途：这个接口在 `_getCurrentCode` 和 `_getNewCode` 函数中被调用，用于发送验证码到用户的邮箱。`code` 是生成的验证码，`receiverMail` 是用户的邮箱地址。
//
// 2. 接口地址：`http://a408599l51.wicp.vip/Login/updateMail`
//
// 接口参数：`loginAccount`, `loginMail`
//
// 返回数据：未在代码中明确指出，但从代码逻辑推测，可能返回一个表示操作成功或失败的状态码或信息。
//
// 用途：这个接口在 `_updateMail` 函数中被调用，用于更新用户的邮箱地址。`loginAccount` 是用户的登录账号，`loginMail` 是新的邮箱地址。
//
// 这2个接口都是在用户更换邮箱时被调用的，用于发送验证码到用户的邮箱，并更新用户的邮箱地址。