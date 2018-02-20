import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.green,
  accentColor: Colors.blueAccent[400],
);

<<<<<<< HEAD
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();



void main() => runApp(new MyApp());

Future<String> _testSignInWithGoogle() async {
  print('Testing');
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth =
  await googleUser.authentication;
  print('Google User: $googleUser'); //Make sure it takes google  user
  print('Google Auth $googleAuth');
  final FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  print('Made it');
  assert(user.email != null);
  print('Email: $user.email');
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);


  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);
  print('This user signed in: $user');
  return 'signInWithGoogle succeeded: $user';
=======
final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;

void main() => runApp(new MyApp());

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
    print('Signed in silently');
  } else if (user == null) {
    await googleSignIn.signIn();
    print('signed user in');
  } else {
    print('Didn\'t need to sign user in');
  }

  if (await auth.currentUser() == null){
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken
    );
  }

>>>>>>> master
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Kyn',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new MyHomePage(title: 'Kyn Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _isLoggedIn = false;

  Future<Null> ensureLoggedIn() async {
    setState((){
      _isLoggedIn = true;
    });
    await _testSignInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Welcome to Kyn!',
              style: Theme.of(context).textTheme.display1,
            ),
            new FlatButton(
                onPressed: _testSignInWithGoogle,
                child: const Text('Sign In'),
                color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
