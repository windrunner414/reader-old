import 'package:flutter/material.dart';
import 'package:reader/page/reader/turning/simulation.dart';
import 'dart:ui';
import 'dart:math';

Picture background;
Picture currentPage, prevPage, nextPage, currentPageReverse, prevPageReverse;

void main() {
  runApp(MyApp());
}

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String repeatString(String str, int num) {
  String r = '';
  for (int i = 0; i < num; ++i) {
    r += str;
  }
  return r;
}

class _MyHomePageState extends State<MyHomePage> {
  bool inDrag = false, toPrev = false;
  Offset touchStart;
  Offset beginTouchPoint, touchPoint;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size == Size.zero) {
      print('return');
      return Container();
    }
    if (background == null) {
      PictureRecorder backgroundRecorder = PictureRecorder();
      Canvas canvas = Canvas(backgroundRecorder);
      canvas.drawColor(Colors.green, BlendMode.src);
      background = backgroundRecorder.endRecording();
      print(MediaQuery.of(context).size);
      print(MediaQueryData.fromWindow(window).size);
      PictureRecorder currentPageRecorder = PictureRecorder();
      canvas = Canvas(currentPageRecorder);
      TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
              ),
              text: repeatString('第二页', 200),
            ),
          ],
        ),
      )..layout(maxWidth: MediaQuery
            .of(context)
            .size
            .width - 30)
        ..paint(canvas, Offset(15, 30));
      currentPage = currentPageRecorder.endRecording();
      PictureRecorder prevPageRecorder = PictureRecorder();
      canvas = Canvas(prevPageRecorder);
      TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
              ),
              text: repeatString('第一页', 200),
            ),
          ],
        ),
      )..layout(maxWidth: MediaQuery
          .of(context)
          .size
          .width - 30)
        ..paint(canvas, Offset(15, 30));
      prevPage = prevPageRecorder.endRecording();
      PictureRecorder nextPageRecorder = PictureRecorder();
      canvas = Canvas(nextPageRecorder);
      TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
              ),
              text: repeatString('第三页', 200),
            ),
          ],
        ),
      )..layout(maxWidth: MediaQuery
          .of(context)
          .size
          .width - 30)
        ..paint(canvas, Offset(15, 30));
      nextPage = nextPageRecorder.endRecording();
      PictureRecorder currentPageReverseRecorder = PictureRecorder();
      canvas = Canvas(currentPageReverseRecorder);
      TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black.withOpacity(0.15),
          ),
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
              ),
              text: repeatString('第二页', 200),
            ),
          ],
        ),
      )..layout(maxWidth: MediaQuery
          .of(context)
          .size
          .width - 30)
        ..paint(canvas, Offset(15, 30));
      currentPageReverse = currentPageReverseRecorder.endRecording();
      PictureRecorder prevPageReverseRecorder = PictureRecorder();
      canvas = Canvas(prevPageReverseRecorder);
      TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black.withOpacity(0.15),
          ),
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
              ),
              text: repeatString('第一页', 200),
            ),
          ],
        ),
      )..layout(maxWidth: MediaQuery
          .of(context)
          .size
          .width - 30)
        ..paint(canvas, Offset(15, 30));
      prevPageReverse = prevPageReverseRecorder.endRecording();
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: RepaintBoundary(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            if (!inDrag) {
              if (touchStart == null) {
                touchStart = details.globalPosition;
                return;
              } else {
                double distance = sqrt(
                  (details.globalPosition.dx - touchStart.dx) * (details.globalPosition.dx - touchStart.dx)
                  + (details.globalPosition.dy - touchStart.dy) * (details.globalPosition.dy - touchStart.dy)
                );
                if (distance > 10) {
                  inDrag = true;
                  beginTouchPoint = details.globalPosition;
                  if (details.globalPosition.dx - touchStart.dx <= 0) {
                    toPrev = false;
                  } else {
                    print('toPrev');
                    toPrev = true;
                  }
                }
              }
            }

            setState(() {
              touchPoint = details.globalPosition;
            });
          },
          onPanEnd: (DragEndDetails details) {
            setState(() {
              inDrag = false;
              beginTouchPoint = null;
              touchPoint = null;
              touchStart = null;
              toPrev = false;
            });
          },
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            isComplex: true,
            willChange: inDrag,
            painter: SimulationPageTurningPainter(
              beginTouchPoint: beginTouchPoint,
              touchPoint: touchPoint,
              prevPage: prevPage,
              currentPage: currentPage,
              nextPage: nextPage,
              prevPageReverse: prevPageReverse,
              currentPageReverse: currentPageReverse,
              toPrev: toPrev,
              background: background,
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
