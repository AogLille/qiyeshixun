// 导入需要的包
import 'package:flutter/material.dart';
import 'Route.dart';

// 主函数，应用程序的入口点
void main()=>runApp(const MyApp());

// MyApp 是一个 StatelessWidget，这是整个应用程序的根
class MyApp extends StatelessWidget{
  // StatelessWidget 通常在其构造函数中接收 Key
  const MyApp({Key? key}) : super(key: key);

  // 构建方法，返回一个 MaterialApp，即整个应用程序的主要部分
  @override
  Widget build (BuildContext context){
    return MaterialApp(
      // 这个属性禁止了应用右上角的debug标签
      debugShowCheckedModeBanner: false,
      // 主题设置，使用自定义颜色
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(0x90002FA7)),
      ),
      // 初始路由，应用程序启动时显示的第一个页面
      initialRoute: '/login',
      // onGenerateRoute 是一个路由生成的回调函数
      // 当通过 Navigator.pushNamed 导航到一个命名路由时，将使用此函数生成路由
      onGenerateRoute: onGenerateRoute,
    );
  }
}

// 根据给定的颜色创建一个 MaterialColor
MaterialColor createMaterialColor(Color color) {
  // 定义强度，用于生成不同深浅的颜色
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  // 添加不同的强度值
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  // 对每个强度生成一种颜色，然后将其添加到 swatch
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });

  // 最后返回一个 MaterialColor，它是根据给定的颜色生成的
  return MaterialColor(color.value, swatch);
}
