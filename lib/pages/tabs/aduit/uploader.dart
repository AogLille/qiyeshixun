import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';



class Uploader  extends StatefulWidget {
  Map arguments;

  Uploader ({Key? key,required this.arguments}) : super(key: key);
  @override
  State<Uploader > createState() => _UploaderState(arguments:this.arguments);
}


var flag=1;
var  _studentGradesList=[];
var list=[];
var _typeList = [TypeBean(name: '申请人'), TypeBean(name: '申请状态'),TypeBean(name: '类型'),  TypeBean(name: '申请时间'),];
List<DataColumn> _dataColumnList = [];
List<DataRow> _dataRowList = [];


class _UploaderState extends State<Uploader> {
  late EasyRefreshController _controller;
  Map arguments;
  _UploaderState({required this.arguments});

  @override
  void initState() {
    super.initState();
    print("审核界面");
    print(arguments);
    _getData();
    _myDataColumnList();
    _controller = EasyRefreshController();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("审核"), backgroundColor: Colors.blue[800],
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
          centerTitle: true,),
        body:
        EasyRefresh.custom(
          enableControlFinishRefresh: false,
          controller: _controller,
          header: ClassicalHeader(),
          footer: ClassicalFooter(),

          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1), () {
              print('onRefresh');
              flag = 1;
              _getData();
              setState(() {

              });
              _controller.resetLoadState();
            });
          },

          slivers: [

            SliverFillViewport(
                delegate: SliverChildListDelegate([
                  Container(
                      //margin: EdgeInsets.all(18),
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


  void _getData() async {

    Dio dio = Dio();

    //测试链接
    // final response = await dio.get('https://dd6db60c-0c23-4d52-ac23-1ded7ecd5c52.mock.pstmn.io/zzh');
    // List  list = json.decode(response.data);

    //正式链接
    // final response = await dio.get('http://a408599l51.wicp.vip/Audit/selectShowAudit?loginAccount=2019215091');
    final response = await dio.get('http://a408599l51.wicp.vip/Audit/selectShowAudit?loginAccount=${arguments['loginAccount']}');
    // http://a408599l51.wicp.vip/Audit/selectFromManagement
    print("'arguments['loginAccount']'");
    print(arguments['loginAccount']);
    list = response.data;

    // print(response.data.runtimeType);

    setState(() {
      if(flag==1) {
        _studentGradesList.clear();
        for (var i = 0; i < list.length; i++) {
          // print(list[i]);
          // print(list[i]['applyType']);
          _studentGradesList.add(StudentGradesBean(
              list[i]["applyName"], list[i]["auditState"],list[i]["applyType"], list[i]["applyTime"],
              list[i]["auditNumber"], list[i]["preData"], list[i]["overData"]),
          );
        }
        flag=0;
      }
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
            height: 125.0,
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