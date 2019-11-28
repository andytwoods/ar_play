import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'home.dart';

List<CameraDescription> cameras;

class SelectedNotification extends Notification {
  final String item;

  const SelectedNotification({this.item});
}

Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final title = 'Andy CV AR Bodgy McBodgeFace';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
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
      home: MyHomePage(title: title),
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
  ArCoreController arCoreController;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isAr = false;
  String item_to_model;

  void _incrementCounter(String item) {
    setState(() {


      if (item == 'cup')
        item = 'keyboard';
      else if (item == 'keyboard') item = 'cup';
      if (item.length > 0) {
        item_to_model = item;
        isAr = true;
      }
    });
  }

  String objectSelected = "images/TocoToucan.gif";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter('');
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // Th
      body: NotificationListener<SelectedNotification>(
        onNotification: (SelectedNotification notification) {
          print(notification.item);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("selected: " + notification.item),
                  content: new Text("pick action"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("AR"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _incrementCounter(notification.item);
                      },
                    ),
                    new FlatButton(
                      child: new Text("Continue"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });

          return true;
        },
        child: SafeArea(
            child: isAr == true
                ? ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                    enableTapRecognizer: true,
                  )
                : HomePage(cameras)),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    widget.arCoreController = controller;
    widget.arCoreController.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _add3dModel(hit);
  }

  void _add3dModel(ArCoreHitTestResult plane) {
    final toucanNode = ArCoreReferenceNode(
        name: "Toucano",
        objectUrl: item_to_model == 'cup'
            ? "https://raw.githubusercontent.com/andytwoods/ar_play/master/assets/models/walkman.gltf"
            : "https://raw.githubusercontent.com/andytwoods/ar_play/master/sampledata/Laptop_out/Laptop.gltf",

        //obcject3DFileName: 'models/walkman.gltf',
        position: plane.pose.translation,
        rotation: plane.pose.rotation,
        scale: vector.Vector3(14, 14, 14));
    print('added');

    widget.arCoreController.addArCoreNodeWithAnchor(toucanNode);
  }

  @override
  void dispose() {
    widget.arCoreController.dispose();
    super.dispose();
  }
}
