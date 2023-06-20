import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:dio/dio.dart';
import '../../user/UserPage.dart';


class Homepage extends StatefulWidget {
  Homepage( {Key? key,required this.arguments}) : super(key: key);
  Map arguments;
  @override
  State<Homepage> createState() => _HomePageState(arguments:this.arguments);
}

class _HomePageState extends State<Homepage> {
  final _controller = ScrollController();
  Map arguments;
  _HomePageState({ required this.arguments});

  @override
  void initState() {
    super.initState();
    print("首页");
    print(arguments);
     _future=dio_picture();
     dio_list();
     dio_jingxuan_first();
  }

  ScrollController scrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  TextEditingController conditionController = TextEditingController();

  List categoryList = ["游戏","通用",  "教育"];
  Map categoryMap = {
    "游戏": ["经营策略", "角色扮演", "休闲益智", "动作冒险", "音乐舞蹈"],
    "通用": ["视频播放", "社交通讯", "网上购物", "音乐电台", "金融理财"],
    "教育": ["早教启蒙", "在线学习", "行业考试", "语言学习", "学生解题"]
  };

  String currentCategory = "游戏";
  String currentChip = "经营策略";

  List list_jingxuan_first = [];
  int? len_jingxuan_first;
  void dio_jingxuan_first() async {
    final dio = Dio();
    final response = await dio.get(
        "http://a408599l51.wicp.vip/App/selectAppByType?appType=$currentChip");
    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print("请求失败：${response.statusCode}");
    }
    setState(() {
      list_jingxuan_first.clear();
      list_jingxuan_first.add(response.data);
      len_jingxuan_first = list_jingxuan_first[0].length;
   //   categoryMap[currentCategory] = response.data;
    });
  }

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
          return DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: PreferredSize(
                preferredSize: Size.fromHeight(76),
                child:AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.blue[800],
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey, width: 2)),
                    toolbarHeight: 28,
                    centerTitle: true,
                    leading: Builder(
                        builder: (BuildContext context){
                          return IconButton(
                              icon: Icon(Icons.person,color: Colors.white,),
                              onPressed: (){
                                Scaffold.of(context).openDrawer();
                              }
                          );
                        }
                    ),
                    actions: [
                      IconButton(
                          onPressed: (){
                            Navigator.pushNamed(context, '/jump_search');
                          },
                          icon:Icon(Icons.search,color: Colors.white,)
                      ),
                    ],
                    bottom: TabBar(
                      isScrollable: true,
                      labelStyle: TextStyle(fontSize: 18),
                      unselectedLabelStyle: TextStyle(fontSize: 13),
                      indicatorColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      tabs: <Widget>[
                        Tab(
                          text: "精选",
                        ),
                        Tab(
                          text: "分类",
                        ),
                      ],
                    ),

                  ),
                ),
                drawer: UserPage(loginAccount:arguments['loginAccount']),
                body: TabBarView(
                  children: <Widget>[
                    Column(
                      children: [
                        //第一个是轮播图
                        Expanded(
                          flex: 3,
                          child: AspectRatio(
                            aspectRatio: 2.0,
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) {
                                return Image.network(
                                  (list_picture != null && list_picture.length > 0 && list_picture[0][index] != null && len! > 0)
                                      ? list_picture[0][index]
                                      : first_picture,
                                  //fit: BoxFit.fill,
                                );
                              },
                              itemCount: len ?? 0,
                              pagination: const SwiperPagination(),
                              control: const SwiperControl(),
                            ),
                          ),
                        ),
                        //这是第二个是一个列表
                        Expanded(
                          flex: 7,
                          child: ListView.separated(
                            controller: _controller,
                            itemCount: len_list ?? 0,
                            separatorBuilder: (context, index) {
                              return  Divider(
                                color: Colors.grey,
                              );
                            },
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        (list_list != null && list_list.length > 0 && list_list[0][index] != null && len_list! > 0)
                                            ? list_list[0][index]['appIcon']
                                            : first_picture,
                                      ),
                                    ),
                                    title: Text(
                                        "${(list_list != null && list_list.length > 0) ? list_list[0][index]['appName'] : ''} "),
                                    hoverColor: Colors.blue[200],
                                    subtitle: Text(
                                        "${(list_list != null && list_list.length > 0) ? list_list[0][index]['appVersion'] : ''} "),
                                    onTap: () {
                                      print("这是+$index");
                                      Navigator.pushNamed(context, '/jump',
                                          arguments: {
                                            "name": (list_list != null && list_list.length > 0) ? list_list[0][index]['appId'] : '',
                                          });
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(child:
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: _categoryListView(),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Column(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: _categoryView(),
                                        )),
                                    Expanded(
                                      flex: 10,
                                      child: _appListView(),)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                          ,)
                      ],
                    ),
                  ],
                )),

          );
        }
      },
    );

  }

  Widget _categoryListView() {
    return ListView.builder(
      controller: scrollController,
      itemCount: 3,
      itemBuilder: (context, index) {
        return TextButton(
          child: Text(
            categoryList[index],
            style: TextStyle(
              color:
              currentCategory == categoryList[index] ? Colors.blue : Colors.black54,
            ),
          ),
          onPressed: () {
            currentCategory = categoryList[index];
            currentChip = categoryMap[currentCategory][0];
            dio_jingxuan_first();

          },
        );
      },
    );
  }

  Widget _categoryView(){
    return
      ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: categoryMap[currentCategory].length,
        itemBuilder: (context, index) {
          return TextButton(
            child: Text(
              categoryMap[currentCategory][index],
              style: TextStyle(
                color: currentChip == categoryMap[currentCategory][index] ? Colors.blue : Colors.black54,
              ),
            ),
            onPressed: () {
              setState(() {
                currentChip = categoryMap[currentCategory][index];
                dio_jingxuan_first();
              });
            },
          );
        },
      );
  }



  Widget _appListView() {
    return Container(
      alignment: Alignment.topCenter,
      child: ListView.separated(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: len_jingxuan_first ?? 0,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                (list_jingxuan_first != null && list_jingxuan_first.length > 0 && list_jingxuan_first[0][index] != null && len_jingxuan_first! > 0)
                    ? list_jingxuan_first[0][index]['appIcon']
                    : first_picture,
              ),
            ),
            title: Text('${(list_jingxuan_first != null && list_jingxuan_first.length > 0) ? list_jingxuan_first[0][index]['appName'] : ''}'),
            subtitle: Text('${(list_jingxuan_first != null && list_jingxuan_first.length > 0) ? list_jingxuan_first[0][index]['appVersion'] : ''}'),
            onTap: () {
              print("这是+$index");
              Navigator.pushNamed(context, '/jump', arguments: {
                "name": (list_list != null && list_list.length > 0) ? list_jingxuan_first[0][index]['appId'] : ''
              });
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            height: 0.3,
            color: Colors.black26,
          );
        },
      ),
    );
  }


  List list_picture = [];
  int? len;
  String first_picture = 'http://a408599l51.wicp.vip/imgs/rotation/1.jpg';

  Future dio_picture() async {
    final dio = Dio();
    final response =
        await dio.get("http://a408599l51.wicp.vip/Rotation/selectAllRotation");
    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print("请求失败：${response.statusCode}");
    }
    setState(() {
      list_picture.add(response.data);
      len = list_picture[0].length;
    });
  }

  List list_list = [];
  int? len_list;

  void dio_list() async {
    final dio = Dio();
    final response =
        await dio.get("http://a408599l51.wicp.vip/App/selectedApp");
    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print("请求失败：${response.statusCode}");
    }
    setState(() {
      list_list.add(response.data);
      len_list = list_list[0].length;
    });
  }
}
