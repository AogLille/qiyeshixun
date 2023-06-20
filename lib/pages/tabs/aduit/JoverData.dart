// 这是跳转接口
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

// 这是一个名为jumppage的StatefulWidget
class jumppage extends StatefulWidget {
  final  arguments; // 这个页面可以接受参数
  jumppage({Key? key, this.arguments}) : super(key: key);

  // 创建对应的状态管理类
  @override
  State<jumppage> createState() => _jumpState(arguments:this.arguments);
}

// 这是jumppage的状态管理类
class _jumpState extends State<jumppage> {
  final  arguments; // 接收参数
  _jumpState({this.arguments});

  @override
  void initState(){
    super.initState();
    _future=dioNetwork(); // 页面初始化时，执行dioNetwork函数，发起网络请求
  }
  List  listMap = [];
  List <String> ScreenShoot=[]; // 存储应用截图的链接
  int? Screen_count; // 记录应用截图的数量
  //final Map<String, dynamic> listMap = new Map<String, dynamic>();

  // 使用Dio库进行网络请求
  Future dioNetwork() async {
    final dio = Dio();
    final response = await dio.get("http://a408599l51.wicp.vip/App/selectAppById?appId=${arguments['overData']}"); // 通过应用ID获取应用信息

    if (response.statusCode == 200) { // 请求成功
      print(response.data);
      print(response.data["appName"]);

    } else { // 请求失败
      print("请求失败：${response.statusCode}");
    }
    // 更新状态，保存获取的数据，处理应用截图的链接，计算截图的数量
    setState(() {
      listMap.add(response.data);
      ScreenShoot= listMap[0]['appScreenshot'].split(';');
      print(ScreenShoot[1]);
      print("ScreenShoot.length");
      print(ScreenShoot.length);
      Screen_count=ScreenShoot.length;
      print(Screen_count);
    });
  }

  String first_picture = 'http://a408599l51.wicp.vip/imgs/rotation/1.jpg'; // 默认的应用截图链接

  late Future _future;

  // 在这里构建UI界面
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(child: CupertinoActivityIndicator()); // 在获取数据时，显示加载动画
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
                    Navigator.pop(context,false); // 点击返回按钮，回到上一页
                  },),
              ),
              // 数据获取完成后，使用ListView展示获取的数据
              body:ListView(
                padding: EdgeInsets.all(10),
                children:<Widget> [
                  // 应用的基本信息
                  Container(
                    child:Row(
                      children: [
                        Expanded(child: ListTile(
                          leading: ClipOval(
                            child: Image.network(
                              (listMap != null && listMap.length > 0 && listMap[0] != null )
                                  ? listMap[0]['appIcon']
                                  : first_picture, // 应用图标
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
                  // 应用截图的轮播图
                  Container(
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return Image.network(
                            (listMap!= null && Screen_count !> 0 && ScreenShoot[index] != null && listMap.length>0 )
                                ? ScreenShoot[index] // 应用截图
                                : first_picture, // 如果没有应用截图，显示默认的图片
                            fit: BoxFit.fill,
                          );
                        },
                        itemCount: Screen_count ?? 4, // 图片的数量
                        pagination: const SwiperPagination(), // 显示轮播指示器
                        control: const SwiperControl(), // 显示轮播控制器
                      ),
                    ),
                  ),
                  // 以下三个Container分别展示应用简介、应用版本号、应用作者名、应用更新日志等信息
                  // 其中每个Container都有一定的样式设置，例如背景渐变、圆角、阴影等
                  // 每个Container里面都包含一个Padding控件，设置内边距，然后在Padding控件内部展示具体的信息
                  Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors:[Colors.white,Colors.grey]),
                          borderRadius: BorderRadius.circular(3.0),
                          boxShadow: const [
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
                  // 版本号和作者名
                  Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors:[Colors.white,Colors.grey]),
                          borderRadius: BorderRadius.circular(3.0),
                          boxShadow: const [
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
                  // 更新日志
                  Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors:[Colors.white,Colors.grey]),
                          borderRadius: BorderRadius.circular(3.0),
                          boxShadow: const [
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

// 这个页面需要的接口数据包括：
//
// 1. `appId`：用于通过 GET 请求获取特定应用的详细信息。
//
// 以下数据会从接口获取并在页面中展示：
// 2. `appName`：应用的名称。
// 3. `appIcon`：应用的图标URL。
// 4. `appType`：应用的类型。
// 5. `appScreenshot`：应用的截图URLs，这些URLs被 `;` 分隔，用于展示在轮播图中。
// 6. `appExplain`：应用的简介。
// 7. `appVersion`：应用的版本号。
// 8. `appAuthor`：应用的作者名。
// 9. `appLog`：应用的更新日志。
//
// 以上这些数据是从接口 "http://a408599l51.wicp.vip/App/selectAppById?appId=${arguments['overData']}" 获取的。其中 `appId` 是通过页面的 `arguments` 参数传入的。
