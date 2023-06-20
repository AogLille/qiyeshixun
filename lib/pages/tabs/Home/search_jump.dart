import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
class search_jumpPage extends StatefulWidget {
  const search_jumpPage({Key? key}) : super(key: key);
  @override
  State<search_jumpPage> createState() => _search_jumpState();
}

class _search_jumpState extends State<search_jumpPage> {
  TextEditingController conditionController = TextEditingController();
  final _controller = ScrollController();
  List  listMap = [];
  int ? len;
  Future dioNetwork() async {
    // 1.创建Dio请求对象
    final dio = Dio();
    // 2.发送网络请求
    final response = await dio.get("http://a408599l51.wicp.vip/App/selectAppByCondition?condition=${conditionController.text}");
    // 3.打印请求结果
    if (response.statusCode == 200) {
      print(response.data);
      //print(response.data[0]["appName"]);
    } else {
      print("请求失败：${response.statusCode}");
    }
    setState(() {
      listMap.add(response.data);
      len=listMap[0].length;
      num=1;
    });
  }
  String first_picture = 'http://a408599l51.wicp.vip/imgs/rotation/1.jpg';
  late Future _future;
  @override
  void initState() {
    super.initState();
  }

  int  num=0;
  Widget _testSearch(){
    if(num==1){
      if(listMap!=null && listMap.length>0 && listMap[0]!=null&&len! >0 ) {
        return ListView.separated(
          controller: scrollController,
          shrinkWrap: true,
          itemCount:len ??0,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage((listMap!=null && listMap.length>0 && listMap[0][index]!=null&&len! >0)
                    ? listMap[0][index]["appIcon"]:first_picture),
              ),
              title: Text("${(listMap != null && listMap.length > 0) ? listMap[0][index]['appName'] : '暂无搜索信息'} "),
              subtitle: Text("${(listMap != null && listMap.length > 0) ? listMap[0][index]['appVersion'] : '暂无搜索信息'} "),

              onTap:(){
                print("这是+$index");//listMap[0][index]['appId']
                Navigator.pushNamed(context, '/jump',arguments: {"name" :(listMap != null && listMap.length > 0) ? listMap[0][index]['appId'] : ''});
              } ,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 0.3,
              color: Colors.black26,
            );
          },
        );
      } else {
        return const Text("暂无此搜索信息，请您重新输入",textAlign: TextAlign.center,);
      }
    }
    else {
      return Container();
    }
  }

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back, color: Colors.black),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),),
        body: Container(
          padding: const EdgeInsets.all(5),
          child: ListView(
            children: [
              TextField(
                  controller: conditionController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      prefixIcon: Icon(Icons.search),
                      hintText: "请输入搜索App"
                  ),
                  onSubmitted: (value){
                    setState(() {
                      num=1;
                      listMap.clear();
                      dioNetwork();
                    });
                  },
              ),
              Container(
                padding: const EdgeInsets.all(5),
                child: _testSearch(),
              )
            ],
          ),
        )
    );
  }
}

//
//  `http://a408599l51.wicp.vip/App/selectAppByCondition?condition=${conditionController.text}`
// - 这个接口用于根据搜索条件获取应用列表。`${conditionController.text}`是一个变量，代表搜索条件。
//
// 这个接口返回的数据被用于更新应用的状态，包括应用的图标、名称、版本等信息。这些信息在搜索结果中显示，并且用户可以点击搜索结果跳转到应用的详细信息页面。
