import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kyn/widgets.dart';
import 'package:kyn/hubpage.dart';
import 'package:kyn/platform_adaptive.dart';



// iOS Default Theme
final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);
// Android Default Theme
final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.deepPurple,
  accentColor: Colors.lightBlueAccent[100],
);

// Create Firebase & Google account objects
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

// Main
void main() => runApp(new MyApp());


// This widget is the root of your application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Kyn',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new MyHomePage(title: 'Kyn Home'),
      routes: <String, WidgetBuilder>{
//        "/": (BuildContext context) => new MyHomePage(),
        "/LoggedInPage": (BuildContext context) => new LoggedInPage(),
        "/CalendarPage": (BuildContext context) => new CalendarPage(),
        "/QuestionsPage": (BuildContext context) => new QuestionsPage(),
        "/RulesPage": (BuildContext context) => new RulesPage(),
        "/PicturesPage": (BuildContext context) => new PicturesPage(),
        "/FamilyPage": (BuildContext context) => new FamilyPage(),
        "/ResourcesPage": (BuildContext context) => new ResourcesPage(),
        "/HubPage": (BuildContext context) => new HubPage(),
      }
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
  GoogleSignInAccount _currentUser;

  @override
  void initState(){
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      setState((){
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<Null> _handleSignIn() async {
    try{
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//  print('Google User: $googleUser'); //Make sure it takes google  user
//  print('Google Auth $googleAuth');
      final FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Assures user information has been obtained
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
//  print('This user signed in: $user');
    } catch(error){
      print(error);
    }
  }

  // Google & Firebase Sign-out
  Future<Null> _handleSignOut() async {
    try{
      FirebaseAuth.instance.signOut();
      _googleSignIn.disconnect();
    }catch(error){
      print(error);
    }
  }

  Future<Null> _switchLoggedInPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/LoggedInPage");
    }
  }


  Widget _buildBody(){
    if(_currentUser != null){
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            color: Colors.deepPurple,
            child:
              new Text(
                'Kyn.',
//                style: Theme.of(context).textTheme.display1,
                  style: new TextStyle(fontFamily: "Source Serif Pro", fontSize: 100.0, fontWeight: FontWeight.bold, color: Colors.white)
              ),
          ),
          new Container(
            color: Colors.deepPurple,
            child: new Column(
              children: <Widget>[
                new Text("Welcome, " + _currentUser.displayName, style: new TextStyle(fontFamily: "Source Serif Pro", fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
//                new ListTile(
//                  leading: new GoogleUserCircleAvatar(
//                    identity: _currentUser,
//                  ),
//                  title: new Text("Welcome, " +_currentUser.displayName),
//                  subtitle: new Text(_currentUser.email),
//                ),
                new IconButton(icon: new Icon(Icons.vpn_key, color: Colors.white), iconSize: 40.0 , onPressed: _switchLoggedInPage),

                new FlatButton(
                  child: new Text('Not you? Sign out.', style: new TextStyle(color: Colors.white, fontSize: 12.0) ),
                  onPressed: _handleSignOut,
                ),
              ],
            ),
          ),
        ],
      );
    }else{
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            color: Colors.deepPurple,
            child:
            new Text(
                'Kyn.',
//                style: Theme.of(context).textTheme.display1,
                style: new TextStyle(fontFamily: "Source Serif Pro", fontSize: 100.0, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ),
          new Container(
            child:
            new RaisedButton(
              child: new GoogleSignInWidget(),
              padding: new EdgeInsets.all(0.0),
              color: Colors.transparent,
              onPressed: _handleSignIn,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: new Container(
          color: Colors.deepPurple,
          child: new Center(
            child: _buildBody(),
          ),
        ),
    );
  }
}

class LoggedInPage extends StatefulWidget{
  @override
  _LoggedInPageState createState() => new _LoggedInPageState();
}
class _LoggedInPageState extends State<LoggedInPage> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentUser = _googleSignIn.currentUser;
    });
    _googleSignIn.signInSilently();
  }

  Future<Null> _switchCalendarPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/CalendarPage");
    }
  }
  Future<Null> _switchQuestionsPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/QuestionsPage");
    }
  }
  Future<Null> _switchRulesPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/RulesPage");
    }
  }
  Future<Null> _switchPicturesPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/PicturesPage");
    }
  }
  Future<Null> _switchResourcesPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/ResourcesPage");
    }
  }
  Future<Null> _switchFamilyPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/FamilyPage");
    }
  }
  Future<Null> _switchHubPage() async{
    if(_currentUser != null){
      Navigator.of(context).pushNamed("/HubPage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Hi, " + _currentUser.displayName + "!"), backgroundColor: Colors.deepPurple,),
      body: new Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new IconButton(icon: new Icon(
                          Icons.calendar_today, color: Colors.deepPurple),
                          iconSize: 40.0,
                          onPressed: _switchCalendarPage),
                      new Text("Calendar", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new IconButton(
                          icon: new Icon(Icons.help, color: Colors.deepPurple),
                          iconSize: 40.0,
                          onPressed: _switchQuestionsPage),
                      new Text("Questions", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new IconButton(icon: new Icon(
                          Icons.business_center, color: Colors.deepPurple),
                          iconSize: 40.0,
                          onPressed: _switchRulesPage),
                      new Text("Rules", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new IconButton(icon: new Icon(
                          Icons.chat_bubble, color: Colors.deepPurple),
                          iconSize: 60.0,
                          onPressed: _switchHubPage),
                      new Text("The Hub", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new IconButton(
                          icon: new Icon(Icons.photo, color: Colors.deepPurple),
                          iconSize: 40.0,
                          onPressed: _switchPicturesPage),
                      new Text("Pictures", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new IconButton(icon: new Icon(
                          Icons.people, color: Colors.deepPurple),
                          iconSize: 40.0,
                          onPressed: _switchFamilyPage),
                      new Text("Family", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new IconButton(
                          icon: new Icon(Icons.phone, color: Colors.deepPurple),
                          iconSize: 40.0,
                          onPressed: _switchResourcesPage),
                      new Text("Resources", style: new TextStyle(
                          fontFamily: "Source Serif Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple))
                    ],
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}

class CalendarPage extends StatefulWidget{
  @override
  _CalendarPageState createState() => new _CalendarPageState();
}
class _CalendarPageState extends State<CalendarPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Calendar"),
      ),
    );
  }
}

class QuestionsPage extends StatefulWidget{
  @override
  _QuestionsPageState createState() => new _QuestionsPageState();
}
class _QuestionsPageState extends State<QuestionsPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Questions"),
      ),
    );
  }
}

class RulesPage extends StatefulWidget{
  @override
  _RulesPageState createState() => new _RulesPageState();

}
class _RulesPageState extends State<RulesPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Rules"),
      ),
    );
  }
}

class PicturesPage extends StatefulWidget{
  @override
  _PicturesPageState createState() => new _PicturesPageState();
}
class _PicturesPageState extends State<PicturesPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Pictures"),
      ),
    );
  }
}

class FamilyPage extends StatefulWidget{
  @override
  _FamilyPageState createState() => new _FamilyPageState();
}
class _FamilyPageState extends State<FamilyPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Family"),
      ),
    );
  }
}

class ResourcesPage extends StatefulWidget{
  @override
  _ResourcesPageState createState() => new _ResourcesPageState();
}
class _ResourcesPageState extends State<ResourcesPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Resources"),
      ),
    );
  }
}

//class HubPage extends StatefulWidget{
//  _HubPageState createState() => new _HubPageState();
//}
//
//class _HubPageState extends State<HubPage>{
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text("The Hub"),
//      ),
//      body: new ChatScreen(),
//    );
//  }
//}