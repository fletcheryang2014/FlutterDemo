import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'entity.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilderPage(),
    );
  }
}

class FutureBuilderPage extends StatefulWidget {
  @override
  _FutureBuilderPageState createState() => _FutureBuilderPageState();
}

class _FutureBuilderPageState extends State<FutureBuilderPage> {
  Future future;

  @override
  void initState() {
    super.initState();
    future = getListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('知识体系')), 
        body: buildFutureBuilder(),
        );
  }

  FutureBuilder<List<Data>> buildFutureBuilder() {
    return FutureBuilder<List<Data>>(
        future: future,
        builder: (context, snapshot) {
          //在这里根据快照的状态，返回相应的widget
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR"),
              );
            } else if (snapshot.hasData) {
              List<Data> list = snapshot.data;
              return RefreshIndicator(
                  child: buildListView(context, list), onRefresh: refresh);
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  buildListView(BuildContext context, List<Data> list) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          Data item = list[index];
          StringBuffer str = new StringBuffer();
          for (Children children in item.children) {
            str.write(children.name + "  ");
          }
          return Column(
              children: [
                ListTile(
                  title: Text(item.name),
                  subtitle: Text(str.toString()),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.navigate_next,
                      color: Colors.grey,
                    ),
                    onPressed: () {})
                ),
                Divider()
              ]
            );
        });
  }

  //获取数据的逻辑，利用dio库进行网络请求，拿到数据后利用json_serializable解析json数据
  //并将列表的数据包装在一个future中
  Future<List<Data>> getListData() async {
    var dio = new Dio();
    Response response = await dio.get("http://www.wanandroid.com/tree/json");
    Map<String, dynamic> map = response.data;
    Entity entity = Entity.fromJson(map);
    return entity.data;
  }

  //刷新数据,重新设置future就行了
  Future refresh() async {
    setState(() {
      future = getListData();
    });
  }
}