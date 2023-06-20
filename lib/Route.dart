import 'package:app_shop/pages/login/ForgetPwdPage.dart';
import 'package:app_shop/pages/login/LoginPage.dart';
import 'package:app_shop/pages/login/RegisterPage.dart';
import 'package:app_shop/pages/login/UserAgreementPage.dart';
import 'package:app_shop/pages/tabs.dart';
import 'package:app_shop/pages/tabs/Home/jump.dart';
import 'package:app_shop/pages/tabs/Home/search_jump.dart';
import 'package:app_shop/pages/tabs/aduit/aduit.dart';
import 'package:app_shop/pages/tabs/manage/body.dart';
import 'package:app_shop/pages/user/EditHeadPortraitPage.dart';
import 'package:app_shop/pages/user/EditMailPage.dart';
import 'package:app_shop/pages/user/EditPwdPage.dart';
import 'package:app_shop/pages/user/UserInfoPage.dart';
import 'package:app_shop/pages/user/UserSettingsPage.dart';
import 'package:flutter/material.dart';



// 定义应用的路由
// key 是路由的名字，value 是一个函数，该函数返回对应的页面 Widget
// 函数接收两个参数：一个是 context，一个是 arguments，用于传递页面参数
final routes= {
  '/Aduit': (context,{arguments}) => Aduit(arguments:arguments),
  '/JpreData':(context,{arguments})=>jumppage(arguments:arguments),
  '/JoverData':(context,{arguments})=>jumppage(arguments:arguments),
  '/Massage': (context,{arguments}) => ManageBodyWidget(arguments:arguments),
  '/ManageBodyWidget': (context,{arguments}) => ManageBodyWidget(arguments:arguments),
  '/Home': (context,{arguments}) => MyHomePage(arguments:arguments),
  '/jump':(context,{arguments})=>jumppage(arguments:arguments),
  '/jump_search':(context)=>search_jumpPage(),
  '/login': (context) => LoginPage(),
  '/login/register': (context) => RegisterPage(),
  '/login/register/agreement':(context) => UserAgreementPage(),
  '/login/forget':(context,{arguments}) => ForgetPwdPage(arguments:arguments),
  '/home/setting':(context,{arguments}) => UserSettingsPage(arguments:arguments),
  '/home/setting/userInfo':(context,{arguments}) => UserInfoPage(arguments:arguments),
  '/home/setting/userInfo/editPwd':(context,{arguments}) => EditPwdPage(arguments:arguments),
  '/home/setting/userInfo/editMail':(context,{arguments}) => EditMailPage(arguments:arguments),
  '/home/headImage':(context,{arguments}) => EditHeadPortraitPage(arguments:arguments),
};

// 定义 onGenerateRoute 函数，它是 MaterialApp 的一个参数，用于生成路由
var onGenerateRoute = (RouteSettings settings){
  // 获取路由名
  final String? name = settings.name;
  // 在 routes 中查找对应的页面生成函数
  final Function? pageContentBuilder = routes[name];
  // 如果找到了
  if (pageContentBuilder != null) {
    // 如果有传递参数
    if (settings.arguments != null) {
      // 创建并返回一个新的页面路由
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      // 没有传递参数时也创建并返回一个新的页面路由
      final Route route =
      MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};