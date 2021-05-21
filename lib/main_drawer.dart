import 'package:HandSignRecognitionSystem/report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'utils/firebase_auth.dart';

class MainDrawer extends StatelessWidget {
  FirebaseUser currentUser;
  MainDrawer(FirebaseUser currentuser) {
    currentUser = currentuser;
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          color: Theme.of(context).primaryColor,
          child: Center(
              child: Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 10,
                ),
                child: ClipOval(
                  child: Image.network(
                      currentUser.photoUrl != null
                          ? currentUser.photoUrl
                          : 'https://f0.pngfuel.com/png/981/645/default-profile-picture-png-clip-art.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover),
                ),
              ),
              Text(
                currentUser.displayName != null
                    ? currentUser.displayName
                    : 'Test',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currentUser.email != null ? currentUser.email : 'Test',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          )),
        ),
        ListTile(
          leading: Icon(Icons.supervised_user_circle),
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.description),
          title: Text(
            'Report',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Report(currentUser)),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.keyboard_return),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            AuthProvider().logOut();
          },
        )
      ]),
    );
  }
}
