//这是跳转接口
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/cupertino.dart';

class jumppage extends StatefulWidget {
  final arguments;
  jumppage({Key? key, this.arguments}) : super(key: key);
  @override
  State<jumppage> createState() => _jumpState(arguments: this.arguments);
}

class _jumpState extends State<jumppage> {
  final arguments;
  _jumpState({this.arguments});

  @override
  void initState() {
    super.initState();
    _future = dioNetwork();
  }
  List listMap = [];
  List<String> ScreenShoot = [];
  int? Screen_count;
  Future dioNetwork() async {
    // 1.创建Dio请求对象
    final dio = Dio();
    // 2.发送网络请求
    final response = await dio.get(
        "http://a408599l51.wicp.vip/App/selectAppById?appId=${arguments['name']}");
    // 3.打印请求结果
    if (response.statusCode == 200) {
      print(response.data);
      print(response.data["appName"]);
    } else {
      print("请求失败：${response.statusCode}");
    }
    setState(() {
      listMap.add(response.data);
      ScreenShoot = listMap[0]['appScreenshot'].split(';');
      Screen_count = ScreenShoot.length-1;
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
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: AppBar(
                  title: Text(
                    "${(listMap != null && listMap.length > 0) ? listMap[0]['appName'] : ''} ",
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context,false),
                  ),
                ),
              ),
              body: ListView(
                padding: EdgeInsets.all(10),
                children: <Widget>[
                  Container(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                (listMap != null &&
                                        listMap.length > 0 &&
                                        listMap[0] != null)
                                    ? listMap[0]['appIcon']
                                    : first_picture,
                              ),
                            ),
                            title: Text(
                                "${(listMap != null && listMap.length > 0) ? listMap[0]['appName'] : ''} "),
                            subtitle: Text(
                                "所属类型：${(listMap != null && listMap.length > 0) ? listMap[0]["appType"] : ""}"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      height: 65,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey.shade50]),
                          borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 18.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                  "版本号：${(listMap != null && listMap.length > 0) ? listMap[0]['appVersion'] : ''}",
                                  textAlign: TextAlign.center,
                                )),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  "作者账号：${(listMap != null && listMap.length > 0) ? listMap[0]['appAuthor'] : ''}",
                                  textAlign: TextAlign.center,
                                )),
                          ],
                        ),
                      )),
                  Container(
                    height: 250,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return  Image.network(
                          (listMap != null &&
                              Screen_count! > 0 &&
                              ScreenShoot[index] != null &&
                              listMap.length > 0)
                              ? ScreenShoot[index]
                              : first_picture,

                        );
                      },
                      itemCount: Screen_count ?? 0,
                      viewportFraction: 0.8,
                      scale: 0.9,
                    ),
                  ),
                  Container(
                    child: ExpansionTile(
                        title:Text('简介'),
                        children:<Widget>[
                          ListTile(
                            title: Text(
                            "${(listMap != null && listMap.length > 0) ? listMap[0]['appExplain'] : ''}",
                              style: TextStyle(
                                fontSize: 14,
                              ),),

                          )
                        ]
                    ),
                  ),
                  Container(
                    child: ExpansionTile(
                        title:Text('日志'),
                        children:<Widget>[
                          ListTile(
                            title:
                            Text(
                              "${(listMap != null && listMap.length > 0) ? listMap[0]['appLog'] : ''}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          )
                        ]
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
