import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseUser currentUser;

class Report extends StatefulWidget {
  Report(FirebaseUser currentuser) {
    currentUser = currentuser;
  }

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final dbRef = FirebaseDatabase.instance
      .reference()
      .child("reports")
      .child(currentUser.uid);
  var lists = new List();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Report',
      home: Scaffold(
      //  resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.green,
        appBar: AppBar(
          title: Text(
            "My Reports",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: new IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: FutureBuilder(
            future: dbRef.once(),
            builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.hasData) {
                lists.clear();
                Map<dynamic, dynamic> values = snapshot.data.value;
                values.forEach((key, values) {
                  lists.add(values);
                });
                return new ListView.builder(
                    shrinkWrap: true,
                    itemCount: lists.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        margin: new EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.network(lists[index]["image_link"]),
                            Container(
                              child: Text(
                                "Alphabet: " + lists[index]["alphabet"],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(
                                "Confidence: " + lists[index]["confidence"],
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(
                                "Time: " + lists[index]["timeofupload"],
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
