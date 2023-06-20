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

  Future<Null> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 2),(){
      setState(() {
        _getMsgInfo();
      });
    });
  }


}

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





