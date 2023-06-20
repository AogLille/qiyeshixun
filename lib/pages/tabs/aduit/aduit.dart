import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';



class Aduit  extends StatefulWidget {
  Map arguments;

  Aduit ({Key? key,required this.arguments}) : super(key: key);
  @override
  State<Aduit > createState() => _AduitState(arguments:this.arguments);
}

// 以下是一些全局变量和列表
var flag=1;// 刷新数据的标志
var  _studentGradesList=[]; // 学生等级列表
var list=[]; // 数据列表
var _typeList = [TypeBean(name: '申请人'), TypeBean(name: '申请状态'),TypeBean(name: '类型'),  TypeBean(name: '申请时间'),]; // 类型列表
List<DataColumn> _dataColumnList = [];// DataColumn列表
List<DataRow> _dataRowList = [];// DataRow列表


// 定义一个名为'_AduitState'的State类，用于管理'Aduit' widget的状态
class _AduitState extends State<Aduit> {
  late EasyRefreshController _controller; // 定义一个EasyRefresh控制器
  Map arguments;
  _AduitState({required this.arguments});// 这是构造函数，用于初始化这个State对象

  // 这个函数会在widget初始化时调用
  @override
  void initState() {
    super.initState();
    print("审核界面");
    print(arguments);
    _getData();// 获取数据
    _myDataColumnList();// 获取DataColumn列表
    _controller = EasyRefreshController();// 初始化EasyRefresh控制器

  }

  // 这是build方法，用于构建widget的UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("审核"), backgroundColor: Colors.blue[800],
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
        ),

        body:
        EasyRefresh.custom(
          // 使用EasyRefresh自定义刷新
          enableControlFinishRefresh: false,
          controller: _controller,
          header: ClassicalHeader(),
          footer: ClassicalFooter(),

          onRefresh: () async {
            // 定义刷新时的操作
            await Future.delayed(Duration(seconds: 1), () {
              print('onRefresh');
              flag = 1;
              _getData();// 获取数据
              setState(() {

              });
              _controller.resetLoadState();// 重置加载状态
            });
          },

          slivers: [

            SliverFillViewport(
                delegate: SliverChildListDelegate([
                  Container(
                     // margin: EdgeInsets.all(18),
                      child:
                      Column(
                        children: [
                          Divider(),
                          Expanded(
                              flex:9,
                              child:
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _myDataTable(),
                                ),

                              )
                          )
                        ],
                      )

                  )
                ]))




          ],


        ),

        persistentFooterButtons: <Widget>[
          FlatButton(
              onPressed: () {
                _controller.callRefresh();
              },
              child: Text("刷新", style: TextStyle(color: Colors.black))),

        ]
    );

  }

// 这个函数用于从远程服务器获取数据
  void _getData() async {
    Dio dio = Dio();
    final response = await dio.get('http://a408599l51.wicp.vip/Audit/selectShowAudit?loginAccount=${arguments['loginAccount']}');
    list = response.data;
    setState(() {
      if(flag==1) {
        _studentGradesList.clear();
        for (var i = 0; i < list.length; i++) {
          _studentGradesList.add(StudentGradesBean(
            list[i]["applyName"], list[i]["auditState"],list[i]["applyType"], list[i]["applyTime"],
            list[i]["auditNumber"], list[i]["preData"], list[i]["overData"]),
          );
        }
        flag=0;
      }
    });

  }

  // 审核通过的函数
  void auditPass(int  auditNumber ) async{
    Dio dio=Dio();
    Response response =
    await dio.post("http://a408599l51.wicp.vip/Audit/auditPass?auditNumber=$auditNumber&loginAccount=${arguments['loginAccount']}");
    flag = 1;
    _getData();
  }

  // 审核拒绝的函数
  void auditRejected(int  auditNumber ) async{
    Dio dio=Dio();
    Response response =
    await dio.post("http://a408599l51.wicp.vip/Audit/auditRejected?auditNumber=$auditNumber&loginAccount=${arguments['loginAccount']}");
    flag = 1;
    _getData();

    setState(() {
    });

  }



  _myDataRow(StudentGradesBean bean) {

    return DataRow(
      onLongPress:(){
        _openModalBottomSheet( bean.auditNumber,bean.preData,bean.overData,bean.auditState);

      },
      cells: [

        _myDataCell(bean.name),
        _ButtonaCell(bean.auditState.toString(),),
        _myDataCell(bean.applyType.toString()),
        _myDataCell(bean.applyTime.toString()),


      ],
    );
  }

  Future _openModalBottomSheet(int auditNumber, int preData, int overData, String auditState) async {
    final option = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250.0,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text('新软件',textAlign: TextAlign.center),
                  onTap: () {
                    print(preData);
                    if(preData==-1){
                      Fluttertoast.showToast(
                          msg: "无新软件",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    else{
                      Future future =Navigator.pushNamed(context, '/JpreData',arguments: {"name" :preData});
                      future.then((value) {
                        if (value == false){
                          setState(() {
                            Navigator.pop(context);
                          });
                        }

                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('旧软件',textAlign: TextAlign.center),
                  onTap: () {
                    print(overData);
                    if(overData==-1){
                      Fluttertoast.showToast(
                          msg: "无旧软件",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    else{
                      Future future = Navigator.pushNamed(context, '/JoverData',arguments: {"name" :overData});
                      future.then((value) {
                        if (value == false){
                          setState(() {
                            Navigator.pop(context);
                          });
                        }

                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('审核通过',textAlign: TextAlign.center),
                  onTap: () {
                    if(auditState=="已通过" || auditState=="已驳回")
                    {
                      Fluttertoast.showToast(
                          msg: "禁止操作",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    else{
                      auditPass(auditNumber);
                      Fluttertoast.showToast(
                          msg: "审核通过",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      setState(() {

                      });
                      Navigator.pop(context, auditNumber);
                    }
                  },
                ),
                ListTile(
                  title: Text('审核驳回',textAlign: TextAlign.center),
                  onTap: () {
                    if(auditState=="已通过" || auditState=="已驳回")
                    {
                      Fluttertoast.showToast(
                          msg: "禁止操作",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    else{
                      auditRejected(auditNumber );
                      Fluttertoast.showToast(
                          msg: "审核驳回",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      setState(() {

                      });
                      Navigator.pop(context, auditNumber);
                    }

                  },
                ),
              ],
            ),
          );
        }
    );

    print(option);
  }





  _myDataRowList() {

    if (_dataRowList.length > 0) {
      _dataRowList.clear();
    }

    _studentGradesList.forEach((element)
    {
      _dataRowList.add(_myDataRow(element));
    }
    );

    return _dataRowList;
  }
  _myDataTable() {

    return DataTable(

      columns: _myDataColumnList(),
      rows: _myDataRowList(),
      dataRowHeight: 60,
      headingRowHeight: 55,
      horizontalMargin: 0,
      columnSpacing: 20,
      dividerThickness: 2,

    );
  }
  _myDataColumn(TypeBean bean) {
    return DataColumn(
      label: Text(
        bean.name,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      tooltip: '${bean.name}',
      numeric: false,
    );
  }
  _myDataColumnList() {

    if (_dataColumnList.length > 0) {
      _dataColumnList.clear();
    }
    _typeList.forEach((element) {
      _dataColumnList.add(_myDataColumn(element));
    });
    return _dataColumnList;
  }
  _myDataCell(String s) {
    if (s.length>=4){
      return DataCell(
          SizedBox(
            width: 100,
            child:  Text(s,
              style: TextStyle
                (
                  fontSize: 12,
                  fontWeight: FontWeight.w500
              ),
            ),
          )

      );
    }
    else{
      return DataCell(
        SizedBox(
          child:  Text(s,
            style: TextStyle
              (
                fontSize: 12,
                fontWeight: FontWeight.w500
            ),
          ),
        )

    );

    }

  }

  _ButtonaCell(String s) {
    if(s=="未审核"){
      return DataCell(
        SizedBox(
          width: 80,
          height: 25,
          child:
          FlatButton(
            color: Colors.grey,
            highlightColor: Colors.grey[700],
            colorBrightness: Brightness.dark,
            splashColor: Colors.grey,
            child: Text(s),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            onPressed: () {},
          ),
        )
      );
    }
    if(s=="已通过"){
      return DataCell(
        SizedBox(
          width: 80,
          height: 25,
          child:
          FlatButton(
            color: Colors.green,
            highlightColor: Colors.green[700],
            colorBrightness: Brightness.dark,
            splashColor: Colors.grey,
            child: Text(s),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            onPressed: () {},
          ),
        )

      );
    }
    if(s=="已驳回"){
      return DataCell(
        SizedBox(
          width: 80,
          height: 25,
          child:
          FlatButton(
            color: Colors.orange,
            highlightColor: Colors.orange[700],
            colorBrightness: Brightness.dark,
            splashColor: Colors.grey,
            child: Text(s),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            onPressed: () {},
          ),
        )

      );
    }
  }
}

class TypeBean {
  const TypeBean({required this.name});
  final String name;
}

class StudentGradesBean {
  String name;
  String auditState;
  String applyType;
  String applyTime;


  int auditNumber;
  int overData;
  int preData;


  bool isSelected;

  StudentGradesBean(
      this.name,
      this.auditState,
      this.applyType,
      this.applyTime,

      this.auditNumber,
      this.overData,
      this.preData,

      {this.isSelected = true}
      );
}

// 这个页面需要以下的接口数据：
//
// 1. `http://a408599l51.wicp.vip/Audit/selectShowAudit?loginAccount=${arguments['loginAccount']}`：这是一个GET请求，通过指定的loginAccount获取审核列表数据。
//
// 返回的数据应该是一个包含以下字段的列表：
// - "applyName"：申请人姓名
// - "auditState"：审核状态
// - "applyType"：申请类型
// - "applyTime"：申请时间
// - "auditNumber"：审核编号
// - "preData"：预处理数据
// - "overData"：完成数据
//
// 2. `http://a408599l51.wicp.vip/Audit/auditPass?auditNumber=$auditNumber&loginAccount=${arguments['loginAccount']}`：这是一个POST请求，表示审核通过。
//
// 3. `http://a408599l51.wicp.vip/Audit/auditRejected?auditNumber=$auditNumber&loginAccount=${arguments['loginAccount']}`：这也是一个POST请求，表示审核被拒绝。
//
// 在调用审核通过或审核拒绝接口后，页面会再次请求审核列表接口以更新列表数据。
