import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget{
  Map arguments;
  UserInfoPage({Key? key,required this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserInfoPageState(arguments:this.arguments);
  }
}

class _UserInfoPageState extends State<UserInfoPage>{
  Map arguments;
  _UserInfoPageState({required this.arguments});

  String _loginMail='';
  String _loginPassword='';

  _getUserInfo()async{
    Dio dio =Dio();
    String url = 'http://a408599l51.wicp.vip/Login/selectLoginById';
    var response = await dio.get(url,queryParameters: {'loginAccount':arguments['loginAccount']});
    setState(() {
     _loginMail = response.data['loginMail'].toString();
     _loginPassword = response.data['_loginPassword'].toString();
      print(_loginMail);
     print(_loginPassword);
    });
  }

  @override
  void initState() {
    super.initState();
    print(arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账号与安全'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('用户头像'),
            trailing: Container(
              height: 50,
              width: 50,
              child:ClipOval(
                child: arguments['profilePhoto'].toString().isNotEmpty
                    ?Image.network('${arguments['profilePhoto']}',fit: BoxFit.cover,):null,
              ),
            )
          ),
          ListTile(
            title: Text('账号名'),
            trailing: Text('${arguments['loginAccount']}'),
          ),
          ListTile(
            title: Text('用户名'),
            trailing: Text('${arguments['loginName']}'),
          ),
          ListTile(
            title: Text('绑定的邮箱'),
            trailing: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _loginMail.isEmpty ?Text('${arguments['loginMail']}'):Text('$_loginMail'),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/home/setting/userInfo/editMail',arguments: {
                'loginMail':arguments['loginMail'],
                'loginAccount':arguments['loginAccount'],
              }).then((value) => value=='true'?_getUserInfo():null);
            },
          ),
          ListTile(
            title: Text('修改密码'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (){
              Navigator.pushNamed(context, '/home/setting/userInfo/editPwd',arguments: {
                'loginPassword':arguments['loginPassword'],
                'loginAccount':arguments['loginAccount'],
              }).then((value) => value=='true'?_getUserInfo():null);
            },
          ),
          ListTile(
            title: Text('账号角色'),
            trailing: Text('${arguments['loginRole']}'),
          ),
        ],
      ),
    );
  }
}

//这个页面使用了一个HTTP GET请求来获取用户的信息。
//
//接口地址: 'http://a408599l51.wicp.vip/Login/selectLoginById'
//
//接口参数: 'loginAccount'，该参数值来自于页面初始化时传入的参数。
//
//返回数据: 根据代码片段，返回的数据应该是一个包含用户信息的对象，这个对象至少包括 'loginMail' 和 '_loginPassword' 这两个字段。
//
//用途:
//1. '_loginMail' 是用户的电子邮件地址，它被用于在用户信息页显示，以及在修改电子邮件地址时作为初始值。
//2. '_loginPassword' 是用户的密码，它在修改密码时被用作初始值。
//
//在这个页面中，这个接口的主要作用是在用户修改了电子邮件地址或密码之后，重新获取并显示更新后的信息。
