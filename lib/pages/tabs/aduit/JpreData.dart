//这是跳转接口
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
class jumppage extends StatefulWidget {
  final  arguments;
  jumppage({Key? key, this.arguments}) : super(key: key);
  @override
  State<jumppage> createState() => _jumpState(arguments:this.arguments);
}


class _jumpState extends State<jumppage> {

  final  arguments;
  _jumpState({this.arguments});


  @override
  void initState(){
    super.initState();
    _future=dioNetwork();
  }
  List  listMap = [];
  List <String> ScreenShoot=[];
  int? Screen_count;
  //final Map<String, dynamic> listMap = new Map<String, dynamic>();
  Future dioNetwork() async {
    // 1.创建Dio请求对象
    final dio = Dio();
    // 2.发送网络请求
    final response = await dio.get("http://a408599l51.wicp.vip/App/selectAppById?appId=${arguments['preData']}");

    // 3.打印请求结果
    if (response.statusCode == 200) {
      print(response.data);
      print(response.data["appName"]);

    } else {
      print("请求失败：${response.statusCode}");
    }
    setState(() {
      listMap.add(response.data);
      ScreenShoot= listMap[0]['appScreenshot'].split(';');
      print(ScreenShoot[1]);
      print("ScreenShoot.length");
      print(ScreenShoot.length);
      Screen_count=ScreenShoot.length;
      print(Screen_count);
      // print(listMap["appName"]);

    });
  }

  String first_picture = 'http://a408599l51.wicp.vip/imgs/rotation/1.jpg';

  late Future _future;
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(child: CupertinoActivityIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            return Scaffold(
              appBar: AppBar(
                title:  Text(
                  "APP详情界面",
                ),
                backgroundColor: Colors.red,
                leading: IconButton(icon: Icon(Icons.arrow_back),
                  onPressed: (){
                    Navigator.pop(context,false);
                  },),
              ),

              body:ListView(
                padding: EdgeInsets.all(10),
                children:<Widget> [
                  Container(
                    child:Row(
                      children: [
                        Expanded(child: ListTile(
                          leading: ClipOval(
                            child: Image.network(
                              (listMap != null && listMap.length > 0 && listMap[0] != null )
                                  ? listMap[0]['appIcon']
                                  : first_picture,
                              fit: BoxFit.fill,
                            ),
                          ),
                          title: Text("软件名称：${(listMap!=null && listMap.length>0)? listMap[0]['appName'] : ''} "),
                          subtitle:Text("所属类型：${(listMap!=null && listMap.length>0) ? listMap[0]["appType"] :""}"),
                        ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return Image.network(
                            (listMap!= null && Screen_count !> 0 && ScreenShoot[index] != null && listMap.length>0 )
                                ? ScreenShoot[index]
                                : first_picture,
                            fit: BoxFit.fill,
                          );
                        },
                        itemCount: Screen_count ?? 4,
                        pagination: const SwiperPagination(),
                        control: const SwiperControl(),
                      ),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors:[Colors.white,Colors.grey]), //背景渐变
                          borderRadius: BorderRadius.circular(3.0), //3像素圆角
                          boxShadow: const [ //阴影
                            BoxShadow(
                                color:Colors.black54,
                                offset: Offset(2.0,2.0),
                                blurRadius: 4.0
                            )
                          ]
                      ),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
                        child: Text("简介:${(listMap!=null && listMap.length>0)? listMap[0]['appExplain'] : ''}"),
                      )
                  ),
                  Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors:[Colors.white,Colors.grey]), //背景渐变
                          borderRadius: BorderRadius.circular(3.0), //3像素圆角
                          boxShadow: const [ //阴影
                            BoxShadow(
                                color:Colors.black54,
                                offset: Offset(2.0,2.0),
                                blurRadius: 4.0
                            )
                          ]
                      ),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
                        child: Row(
                          children: [
                            Expanded(flex: 1,child:Text("版本号：${(listMap!=null && listMap.length>0)? listMap[0]['appVersion'] : ''}", textAlign: TextAlign.center,)),
                            Expanded(flex: 1,child: Text("作者名：${(listMap!=null && listMap.length>0)? listMap[0]['appAuthor'] : ''}", textAlign: TextAlign.center,)),
                          ],
                        ),
                      )
                  ),
                  Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors:[Colors.white,Colors.grey]), //背景渐变
                          borderRadius: BorderRadius.circular(3.0), //3像素圆角
                          boxShadow: const [ //阴影
                            BoxShadow(
                                color:Colors.black54,
                                offset: Offset(2.0,2.0),
                                blurRadius: 4.0
                            )
                          ]
                      ),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
                          child:Column(children: [
                            Text("日志:",textAlign: TextAlign.left ),
                            Text("${(listMap!=null && listMap.length>0)? listMap[0]['appLog'] : ''}"),
                          ],)
                      )
                  ),
                ],
              ),
            );
        }
      },
    );

  }
}
