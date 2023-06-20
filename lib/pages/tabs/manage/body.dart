import 'dart:convert';

import 'package:app_shop/pages/tabs/manage/search_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'delete.dart';
import 'edit.dart';

class ManageBodyWidget extends StatefulWidget{
  const ManageBodyWidget({Key? key,required this.arguments}) : super(key: key);

  final Map arguments;
  @override
  State<StatefulWidget> createState() {
    return _ManageBodyState();
  }
}

class _ManageBodyState extends State<ManageBodyWidget>{
  ScrollController scrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();

  List categoryList = ["游戏","通用","教育"];
  Map categoryMap = {
    "游戏":[
      "经营策略", "角色扮演", "休闲益智","动作冒险","音乐舞蹈"
    ],
    "通用": [
      "视频播放", "社交通讯", "网上购物","音乐电台","金融理财"
    ],

    "教育":[
      "早教启蒙", "在线学习", "行业考试","语言学习","学生解题"
    ]
  };

  String currentCategory = "游戏";
  String currentChip = "经营策略";

  FocusNode focusNode = FocusNode();
  List<Map<String, dynamic>> listMap = [];

  late Future _future;
  @override
  void initState(){
    super.initState();
    _future = getListByType();
  }

  Future getListByType () async{
    var client = http.Client();
    final url = Uri.parse("http://a408599l51.wicp.vip/App/selectAppByType?appType=$currentChip");
    Utf8Decoder decode = const Utf8Decoder();
    await client.get(url).then((response) async {
      if (response.statusCode == 200) {
        setState(() {
          listMap = List<Map<String, dynamic>>.from(json.decode(decode.convert(response.bodyBytes)));
        });
        print(listMap);
      } else {
        print(response.statusCode);
      }
    });
  }

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
          return Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30))
                        ),
                        prefixIcon: Icon(Icons.search),
                        hintText: "请输入搜索App"
                    ),
                    onTap: (){
                      focusNode.unfocus();
                      Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) => SearchListWidget(arguments: widget.arguments,),
                            settings: const RouteSettings(name: "路由名"),
                          )
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: _categoryListView(),),
                      Expanded(flex: 3, child: Column(
                        children: [
                          Expanded(flex: 1, child: _categoryView(),),
                          Expanded(flex: 14, child: _appListView(),),
                        ],
                      ))

                    ],
                  ),
                )
              ],
            ),
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
          child: Text(categoryList[index],
            style: TextStyle(
              color: currentCategory == categoryList[index] ? Colors.blue : Colors.black54,
            ),
          ),
          onPressed: (){
            setState(() {
              currentCategory = categoryList[index];
              currentChip = categoryMap[currentCategory][0];
              getListByType();
            });

          },
        );
      },

    );
  }

  Widget _categoryView(){
    return ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: categoryMap[currentCategory].length,
      itemBuilder: (context, index) {
        return TextButton(
          child: Text(categoryMap[currentCategory][index],
            style: TextStyle(
              color: currentChip == categoryMap[currentCategory][index] ? Colors.blue : Colors.black54,
            ),
          ),
          onPressed: (){
            setState(() {
              currentChip = categoryMap[currentCategory][index];
              getListByType();
            });
          },
        );
      },
    );
  }

  Widget _appListView() {
    return ListView.separated(
      controller: scrollController,
      shrinkWrap: true,
      itemCount: listMap.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(listMap[index]["appIcon"]),
          ),
          title: Text(listMap[index]["appName"]),
          subtitle: Text(listMap[index]["appVersion"]),
          onLongPress: (){
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context){
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text("更改"),
                      onTap: () {
                        Future future = Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => EditAppWidget(appId: listMap[index]["appId"],arguments: widget.arguments,),
                              settings: RouteSettings(name: "路由名",arguments: listMap[index]["appId"]),
                            )
                        );
                        future.then((value) {
                          if(value == false || value == null){
                            setState(() {
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever),
                      title: const Text("删除"),
                      onTap: (){
                        Future future = Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => DeleteAppWidget(appId: listMap[index]["appId"],arguments: widget.arguments,),
                              settings: RouteSettings(name: "路由名",arguments: listMap[index]["appId"]),
                            )
                        );
                        future.then((value) {
                          if(mounted){
                            setState(() {

                            });
                          }
                          if(value == false || value == null){
                            setState(() {
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 0.3,
          color: Colors.black26,
        );
      },
    );
  }
}