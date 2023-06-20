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