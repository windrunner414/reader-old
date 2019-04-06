import 'package:flutter/material.dart';
import 'package:reader/page/reader/reader.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:reader/model/book.dart';
import 'package:reader/utils/net.dart';
import 'package:reader/config.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/dao/book_dao.dart';
import 'package:reader/page/reader/reader_page.dart';

void main() {
  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: MyHomePage(),
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
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ReaderPage(bookId: '1', bookName: '修罗武神')));
      }, child: Text('打开阅读器')),
    );
  }
}
