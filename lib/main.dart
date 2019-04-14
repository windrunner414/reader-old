import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader/page/reader/reader_page.dart';
import 'package:reader/utils/toast_util.dart';
import 'package:reader/di/di.dart';
import 'package:reader/di/app_module.dart';

void main() async {
  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  appModule().then((module) {
    startDartIn(module);
  });
  //print(module);
  //startDartIn(module);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Toast(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('reader')),
      body: FlatButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ReaderPage(bookId: 'WanGuDaDi', bookName: '万古大帝')));
      }, child: Text('打开阅读器')),
    );
  }
}
