import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_badger/flutter_app_badger.dart';

import '../../user/UserPage.dart';
import '../aduit/aduit.dart';

int number = 0;
String ac = "";

class Massage extends StatefulWidget {
  Map arguments;

  Function callback;
  Massage({Key? key, required this.arguments,required this.callback}) : super(key: key);

  @override
  _MassageState createState() => _MassageState(arguments:this.arguments);
}
class KeyUtils{
  static GlobalKey<NavigatorState> globalKey = new GlobalKey<NavigatorState>();
}


Map listData = [{}] as Map;

List<Map<String, dynamic>> msgInfo=[{}];


class _MassageState extends State<Massage>{


  Map arguments;
  _MassageState({ required this.arguments});



  String debugLable = 'Unknown';   /*错误信息*/
  final JPush jpush = new JPush(); /* 初始化极光插件*/

  late Future _future;

  // 初始化操作，包括获取消息信息，配置极光推送等
  @override
  void initState(){
    print("测试传参2");
    print(arguments);

    super.initState();

    listData = arguments;
    _future = _getMsgInfo();
    // String account = arguments.values.first;
    String account = arguments["loginAccount"];
    //初始化
    ac = account;

    // 配置jpush
    // debug就填debug:true，我这是生产环境所以production:true
    jpush.setup(appKey: 'eb9271690c95100d5c7eeae7' ,channel: 'developer-default',production: true,debug: false);
    // 监听jpush
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        number++;
        FlutterAppBadger.updateBadgeCount(number);
        print(message);
      },
      onOpenNotification: (Map<String, dynamic> message) async {


        // Navigator.of(context).push(
        //         MaterialPageRoute(
        //             builder: (BuildContext context){
        //               return massage_screen();
        //             })
        //     );
        //点击通知栏消息，在此时通常可以做一些页面跳转等

      },
    );

  }

  // 从服务器获取消息
  Future _getMsgInfo() async{
    String loginaccount = arguments["loginAccount"];
    var url = Uri.parse('http://a408599l51.wicp.vip/Message/selectMessageByAccount?loginAccount=$loginaccount');
    Utf8Decoder decode = new Utf8Decoder();
    var response = await http.get(url);
    setState(() {
      msgInfo = new List<Map<String, dynamic>>.from(json.decode(decode.convert(response.bodyBytes)));
      // listData = msgInfo;
      // print(listData);
      FlutterAppBadger.removeBadge();
      number=0;
    });

  }

  //构建界面，包括AppBar，Drawer，消息列表等
  @override
  Widget build(BuildContext context) {

    HomeContent home = HomeContent();
    home.callback = widget.callback;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: KeyUtils.globalKey,
        home: Scaffold(
          appBar: AppBar(title: const Text("消息"),
            backgroundColor: Colors.blue[800],

            centerTitle: true,leading: Builder(
              builder: (BuildContext context){
                return IconButton(
                    icon: Icon(Icons.person,color: Colors.white,),
                    onPressed: (){
                      Scaffold.of(context).openDrawer();
                    }
                );
              }
          ),),
          drawer: UserPage(loginAccount:widget.arguments['loginAccount']),
            body: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(child: CupertinoActivityIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return Container(
                        child: RefreshIndicator(
                          child: home,
                          onRefresh: _handleRefresh,
                        ),

                      );
                  }
                }
            ),




        ));
  }

  //下拉刷新操作
  Future<Null> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 2),(){
      setState(() {
        _getMsgInfo();
      });
    });
  }


}

// 显示消息的列表
class HomeContent extends StatelessWidget {

  Function? callback;

  get PassportManager => null;
  //自定义方法
  List<Widget> _getData() {

    var tempList = msgInfo.map((value) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(value["senderPhoto"]),
        ),
        title: Text(value["messageContent"]),
        subtitle: Text(value["messageTime"]),
        onTap: () {
          // Navigator.of(KeyUtils.globalKey.currentState!.context)
          //     .pushReplacementNamed('/Aduit');
        print("aaa");
        callback!();

        /*  Navigator.of(KeyUtils.globalKey.currentState!.context).push(
              MaterialPageRoute(
                  builder: (BuildContext context){
                    return Aduit(arguments: listData,);
                  })
          );*/
        },
      );
    });
    return tempList.toList();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return ListView(
      children: this._getData(),
    );
  }
}



// 在这段代码中，需要从后端接口获取的数据有以下两部分：
//
// 1. 用户的消息信息：通过访问'http://a408599l51.wicp.vip/Message/selectMessageByAccount'接口获取，需要的参数是'loginAccount'。返回的数据中，可能包含的字段有：
// - "senderPhoto"：消息发送者的头像
// - "messageContent"：消息的内容
// - "messageTime"：消息的发送时间
//
// 2. JPush的推送消息：在接收到极光推送的通知时，可能会获得一些包含在推送消息中的数据，但具体数据结构和内容取决于推送消息的内容。
// 需要注意的是，以上的分析基于代码中的实现，具体的数据结构和内容可能会根据实际的后端接口和业务需求有所不同。