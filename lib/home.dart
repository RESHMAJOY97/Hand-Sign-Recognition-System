import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import './main_drawer.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'dart:async';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'video.dart';
import 'package:uuid/uuid.dart';

FirebaseUser currentUser;
String result, confidence;

class HomePage extends StatefulWidget {
  HomePage(FirebaseUser currentuser) {
    currentUser = currentuser;
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _imageFile, selected;
  String path;

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
  }

  // Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      selected = await ImagePicker.pickImage(source: source);
    } on PlatformException catch (err) {
      print("Error:" + err.message);
    }
    setState(() {
      _imageFile = selected;
      path = _imageFile.path;
    });
  }

  Future classifyImage() async {
    cardKey.currentState.toggleCard();

    await Tflite.loadModel(
        // model: "assets/converted_model.tflite",
        // labels: "assets/labels.txt",

        model: "assets/converted_model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false);
    List<dynamic> output = await Tflite.runModelOnImage(path: path);

    setState(() {
      List indexList = output
          .map((array) => array['index'])
          .toList(); // list of all alphabets
      List confidenceList = output
          .map((array) => array['confidence'])
          .toList(); // list of all percentage accuracy

      if (indexList.toString() == "[0]") {
        result = 'Single';
      } else if (indexList.toString() == "[1]") {
        result = 'Please';
      } else if (indexList.toString() == "[2]") {
        result = 'Ok';
      } else if (indexList.toString() == "[3]") {
        result = 'Work';
      } else if (indexList.toString() == "[4]") {
        result = 'Tall';
      } else if (indexList.toString() == "[5]") {
        result = 'Wash';
      } else if (indexList.toString() == "[6]") {
        result = 'You';
      } else if (indexList.toString() == "[7]") {
        result = 'Sit';
      } else if (indexList.toString() == "[8]") {
        result = 'ILoveYou';
      } else if (indexList.toString() == "[9]") {
        result = 'Help';
      } else if (indexList.toString() == "[10]") {
        result = 'Like';
      } else if (indexList.toString() == "[11]") {
        result = 'Correct';
      } else if (indexList.toString() == "[12]") {
        result = 'Cold';
      } else if (indexList.toString() == "[13]") {
        result = 'Close';
      } else if (indexList.toString() == "[14]") {
        result = 'Home';
      } else if (indexList.toString() == "[15]") {
        result = 'Love';
      } else if (indexList.toString() == "[16]") {
        result = 'Fine';
      } else if (indexList.toString() == "[17]") {
        result = 'Call';
      } else if (indexList.toString() == "[18]") {
        result = 'No';
      }

      confidence = confidenceList.toString();
      print("Output:" + output.toString());
    });

    await Tflite.close();
  }

  // crop image
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      // ratioX : 1.0,
      // ratioY : 1.0,
      // maxWidth: 512,
      // maxHeight: 512,
      toolbarColor: Colors.purple,
      toolbarWidgetColor: Colors.white,
      toolbarTitle: 'Crop It',
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  // clear image
  void _clear() {
    setState(() {
      _imageFile = null;
    });
  }

  void _toogleFlipCard() {
    cardKey.currentState.toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    final FlutterTts flutterTts = FlutterTts();
    //Size screen = MediaQuery.of(context).size;
    FlutterStatusbarcolor.setStatusBarColor(Colors.black);

    speak() async {
      await flutterTts.setLanguage("en-IN");
      await flutterTts.setPitch(1);
      await flutterTts.speak("The character is " + result);
    }

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
        title: Text(
          "Let's Sign",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: Colors.black),
        elevation: 0.0,
      ),
      drawer: MainDrawer(currentUser),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.green,
        items: <Widget>[
          Icon(Icons.photo_camera, size: 25),
          Icon(Icons.photo_library, size: 25),
          Icon(Icons.videocam, size: 25),
        ],
        onTap: (index) {
          if (index == 0) {
            _pickImage(ImageSource.camera);
          }
          if (index == 1) {
            _pickImage(ImageSource.gallery);
          } else {
            // open video.dart
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Video()),
            );
          }
        },
      ),
      body: Center(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            // if (_imageFile != null) ...[
            FlipCard(
              key: cardKey,
              flipOnTouch: false,
              direction: FlipDirection.HORIZONTAL, // default
              front: Container(
                height: MediaQuery.of(context).size.height / 2 + 100,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(16.0),
                  color: Colors.white,
                ),
                margin: const EdgeInsets.only(
                    top: 20.0, bottom: 10.0, left: 20.0, right: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_imageFile != null) ...[
                      Image.file(_imageFile,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width),
                    ],
                    if (_imageFile == null) ...[
                      Image.asset("assets/images/default_image.png",
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                          child: Icon(Icons.crop),
                          onPressed: _cropImage,
                        ),
                        FlatButton(
                          child: Icon(Icons.thumb_up),
                          onPressed: classifyImage,
                        ),
                        FlatButton(
                          child: Icon(Icons.refresh),
                          onPressed: _clear,
                        ),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Uploader(file: _imageFile)]),
                  ],
                ),
              ),
              back: Container(
                height: MediaQuery.of(context).size.height / 2 + 100,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(16.0),
                  color: Colors.white,
                ),
                margin: const EdgeInsets.only(
                    top: 20.0, bottom: 10.0, left: 20.0, right: 20.0),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 30.0, horizontal: 2.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        result != null ? result : "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 200,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      Text(
                        confidence != null ? "Confidence: " + confidence : "",
                        textAlign: TextAlign.center,
                      ),
                      new SizedBox(
                        width: 200.0,
                        height: 50.0,
                        child: new RaisedButton.icon(
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          label: Text(
                            'Press to Speak',
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: Icon(
                            Icons.volume_up,
                            color: Colors.white,
                          ),
                          textColor: Colors.white,
                          splashColor: Colors.red,
                          onPressed: () => speak(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          child: Icon(Icons.arrow_back_ios),
                          onPressed: _toogleFlipCard,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //]
          ],
        ),
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  DatabaseReference dbRef;
  final FirebaseStorage _storage = FirebaseStorage(
      storageBucket: 'gs://hand-sign-recognition-system.appspot.com');

  StorageUploadTask _uploadTask;
  String downloadUrl;

  void _startUpload() {
    String filePath = 'images/${currentUser.uid}/${DateTime.now()}.png';
    dbRef = FirebaseDatabase.instance
        .reference()
        .child("reports")
        .child(currentUser.uid);
    //  .child(Uuid().v1());

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });

    Future<void> foo() async {
      await getDownloadUrl(_uploadTask);
      print(downloadUrl);
      dbRef.push().set({
        'alphabet': result,
        'confidence': confidence,
        //'image_link': _uploadTask.lastSnapshot.ref.getDownloadURL().toString(),
        'image_link': downloadUrl,
        'timeofupload': DateTime.now().toString(),
        'userid': currentUser.uid,
      }).catchError((err) {
        print(err.toString());
      });
    }

    foo();
  }

  Future<void> getDownloadUrl(StorageUploadTask _uploadTask) async {
    var dowurl = await (await _uploadTask.onComplete).ref.getDownloadURL();
    downloadUrl = dowurl.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;
          double progressPercent =
              event != null ? event.bytesTransferred / event.totalByteCount : 0;

          return Column(
            children: [
              if (_uploadTask.isComplete) Text('File Transfer Completed!'),
              if (_uploadTask.isPaused)
                FlatButton(
                  child: Icon(Icons.play_arrow),
                  onPressed: _uploadTask.resume,
                ),
              if (_uploadTask.isInProgress)
                FlatButton(
                  child: Icon(Icons.pause),
                  onPressed: _uploadTask.pause,
                ),
              LinearProgressIndicator(value: progressPercent),
              Text('${(progressPercent * 100).toStringAsFixed(2)} %'),
            ],
          );
        },
      );
    } else {
      return FlatButton.icon(
          onPressed: _startUpload,
          icon: Icon(Icons.cloud_upload),
          label: Text('Upload to Firebase'));
    }
  }
}
