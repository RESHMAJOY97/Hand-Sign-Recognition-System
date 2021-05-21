import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'camera.dart';
import 'bndbox.dart';
import 'package:hexcolor/hexcolor.dart';

List<CameraDescription> cameras;

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  onSelect() async {
    //List<CameraDescription> cameras;
    //Size screen = MediaQuery.of(context).size;

    WidgetsFlutterBinding.ensureInitialized();
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }

    String res;
    res = await Tflite.loadModel(
      model: "assets/converted_model.tflite",
      labels: "assets/labels.txt",

      // model: "assets/model_unquant.tflite",
      // labels: "assets/labels.txt",

      // model: "assets/yolo/mobilenet_v1_1.0_224.tflite",
      // labels: "assets/yolo/mobilenet_v1_1.0_224.txt",
    );

    setState(() {
      _model = "mobilenet";
    });

    print(res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      // 33ffbb
      backgroundColor: HexColor("#33ffbb"),
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image(
                      image: new AssetImage("assets/images/video.gif"),
                      height: 400.0,
                      fit: BoxFit.fill),
                  Center(
                    child: Text(
                      "Click on button to capture",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Center(
                        child: ClipOval(
                          child: Material(
                            color: Colors.amberAccent,
                            child: InkWell(
                              splashColor: Colors.red,
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: Icon(Icons.lens, color: Colors.red),
                              ),
                              onTap: () {
                                onSelect();
                              },
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            )
          : Stack(
              children: [
                Camera(
                  cameras,
                  _model,
                  setRecognitions,
                ),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model),
              ],
            ),
    );
  }
}
