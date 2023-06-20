import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget{
  final String loginAccount;
  const UserPage({Key? key,required this.loginAccount}) : super(key: key);

  @override
  _UserPageState createState()=>_UserPageState(loginAccount:this.loginAccount);
}

class _UserPageState extends State<UserPage>{
  final String loginAccount;
  _UserPageState({required this.loginAccount});

  final Map _userInfo={
    "loginAccount": "",
    "loginRole": "",
    "loginName": "",
    "loginMail": "",
    "profilePhoto": ""
  };

  late Future _future;

  @override
  void initState(){
    _future = _getUserInfo();

    super.initState();
  }

  Future _getUserInfo()async{
    Dio dio =Dio();
    String url = 'http://a408599l51.wicp.vip/Login/selectLoginById';
    var response = await dio.get(url,queryParameters: {'loginAccount':loginAccount});
    setState(() {
      _userInfo['loginAccount'] = response.data['loginAccount'].toString();
      _userInfo['loginRole'] = response.data['loginRole'].toString();
      _userInfo['loginName'] = response.data['loginName'].toString();
      _userInfo['loginMail'] = response.data['loginMail'].toString();
      _userInfo['profilePhoto'] = response.data['profilePhoto'].toString();
      print(_userInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _future,
        builder:  (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: CupertinoActivityIndicator(),);
            case ConnectionState.done:
              print('done');
              if (snapshot.hasError) {
                return Center(child: Text('网络请求出错'),);
              }
              return Stack(
                children: [
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/login.jpg'),
                            fit:BoxFit.cover
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment(-0.85,-0.12),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, '/home/headImage',arguments: {
                          'headImageUrl':_userInfo['profilePhoto'],
                          'loginAccount':_userInfo['loginAccount']
                        }).then((value) => value=='true'?initState():null);
                      },
                      child: Container(
                        height: 102,
                        width: 102,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white,width: 2),
                            borderRadius: BorderRadius.circular(90)
                        ),
                        child: ClipOval(
                          child: _userInfo['profilePhoto'].toString().isNotEmpty
                            ?Image.network('${_userInfo['profilePhoto']}',fit: BoxFit.cover,height: 100, width: 100,)
                            :null,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment(0.3,-0.15),
                    child: Text('用户名：${_userInfo['loginName']}', style: TextStyle(color: Colors.black),)
                  ),
                  Container(
                    alignment: Alignment(-1,0.2),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.settings),
                      ),
                      title: Text('设置'),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: (){
                        Navigator.pushNamed(context, '/home/setting',arguments: {
                          'loginAccount':_userInfo['loginAccount'],
                          'loginRole':_userInfo['loginRole'],
                          'loginName':_userInfo['loginName'],
                          'loginMail':_userInfo['loginMail'],
                          'profilePhoto':_userInfo['profilePhoto'],
                        });
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}