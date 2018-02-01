import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';


final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.green,
  accentColor: Colors.blueAccent[400],
);

final googleSignIn = new GoogleSignIn();

void main() => runApp(new MyApp());

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null){
    user = await googleSignIn.signInSilently();
    print('Signed in silently');
  }
  else if (user == null){
    await googleSignIn.signIn();
    print('signed user in');
  } else{
    print('Didn\'t need to sign user in');
  }

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
    await _ensureLoggedIn();
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
                onPressed: _ensureLoggedIn,
                child: const Text('Sign In'),
                color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
