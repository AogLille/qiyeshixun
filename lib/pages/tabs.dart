// TODO Implement this library.
import 'package:app_shop/pages/tabs/aduit/uploader.dart';
import 'package:app_shop/pages/tabs/manage/apply.dart';
import 'package:app_shop/pages/tabs/manage/manageHome.dart';
import 'package:app_shop/pages/tabs/message/massage_screen.dart';
import 'package:flutter/material.dart';
import 'tabs/Home/home.dart';
import 'tabs/aduit/aduit.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

//应用主页
class MyHomePage extends StatefulWidget {
  // 构造函数，接收一个名为 arguments 的 Map 参数
  Map arguments;

  MyHomePage({Key? key, required this.arguments}) : super(key: key);

  // 创建 State
  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(arguments: this.arguments);
}

// 定义 MyHomePage 的 State
class _MyHomePageState extends State<MyHomePage> {
  // 用于保存传递来的参数
  Map arguments;

  _MyHomePageState({required this.arguments});

  // 用于保存所有的页面
  final List _pageList = [];

// 当前选中的页面的索引
  int _currentIndex = 0;

  // 根据当前选中的页面索引，返回对应的标题
  appBarTitle() {
    switch (_currentIndex) {
      case 0:
        return Text("首页");
      case 1:
        return Text("App管理");
      case 3:
        return Text("消息");
    }
  }

  // 根据当前选中的页面索引，返回对应的搜索按钮
  appSearch() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/jump_search');
            },
            icon: Icon(Icons.search));
      case 1:
        return 0;
      case 3:
        return 0;
    }
  }

  // 使用 JPush 插件
  JPush jPush = JPush();
  String debugLabel = '';

  @override
  void initState() {
    super.initState();
    // 初始化页面列表
    _pageList.add(Homepage(arguments: arguments));
    _pageList.add(MangeHomeWidget(arguments: arguments));
    // 根据 loginRole 参数的值，添加不同的页面
    if (arguments['loginRole'] == "管理人员") {
      _pageList.add(Aduit(arguments: arguments));
    } else if (arguments['loginRole'] == "工作人员") {
      _pageList.add(Uploader(arguments: arguments));
    }
    _pageList.add(Massage(
      arguments: arguments,
      callback: () {
        setState(() {
          _currentIndex = 2;
        });
      },
    ));
    // 设置 JPush 的别名
    jPush.setAlias('${arguments['loginAccount']}').then((map) {
      var tags = map['tags'];
      setState(() {
        debugLabel = "设置别名成功: $map $tags";
      });
    }).catchError((error) {
      setState(() {
        debugLabel = "设置别名错误: $error";
      });
    });
  }

  // 构建方法
  @override
  Widget build(BuildContext context) {
    // 返回一个 Scaffold，包含一个 BottomNavigationBar 和相应的页面
    return Scaffold(
      body: _pageList[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue[700],
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.blue[700],
              ),
              label: '首页',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined, color: Colors.blue[700]),
            label: '管理',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.https_outlined, color: Colors.blue[700]),
              label: '审核',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.sms, color: Colors.blue[700]),
              label: '消息',
              backgroundColor: Colors.white),
        ],
      ),
      //drawer: UserPage(loginAccount:arguments['loginAccount']),
    );
  }
}
