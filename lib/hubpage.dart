import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';
import 'package:kyn/platform_adaptive.dart';
import 'package:kyn/main.dart';
import 'package:meta/meta.dart';

// Message list for FireStore
class MessageList extends StatefulWidget {
  @override
  State createState() => new MessageListState();

}

class MessageListState extends State<MessageList> {
  void initState() {
    setState(() {
      session.getHeadOfHouseholdEmailFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Family/'+session.getHeadOfHouseholdEmail()+'/Messages').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return new Flexible(
            child:
            new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                    leading: me.uid == document['senderID'] ? new CircleAvatar(backgroundImage: new NetworkImage(document['userImgUrl'])):null,
                    trailing: me.uid != document['senderID'] ? new CircleAvatar(backgroundImage: new NetworkImage(document['userImgUrl'])):null,
//                  subtitle: new Text('Feb. 24 | 11:03 PM', style: new TextStyle(fontSize: 12.0)),
                    title:
                    new Card(
                      color: Colors.white,
                      child: new Column(
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              new Container(
                                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                child:  new Text(document['sender'],style: new TextStyle(fontWeight: FontWeight.bold)),

                              )

                            ],
                          ),
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: document['text'] != ''? new Text(document['text'], style: new TextStyle(fontSize: 16.0)): new Image.network(document['imageUrl'], width: 300.0,),

                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      new Card(color: Colors.lightBlue,);
                    }
                );
              }).toList(),
            )
        );
      },
    );
  }
}


// Firestore
class HubPage extends StatefulWidget{
  @override
  State createState() => new HubPageState();
}

class HubPageState extends State<HubPage>{
  GoogleSignInAccount _currentUser;
  GoogleSignIn _googleSignIn = new GoogleSignIn();

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    session.getHeadOfHouseholdEmailFromFirestore();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
//        session.currentUid = account.id;
      });
    });
    _googleSignIn.signInSilently()
        .then((account) {
      _currentUser = account;
//      session.currentUid = account.id;
      print('the current user is: ' + _currentUser.toString());
    });
  }

  CollectionReference get messages => Firestore.instance.collection('Family/' + session.getHeadOfHouseholdEmail() + '/Messages');
  CollectionReference get photos => Firestore.instance.collection('Family/' + session.getHeadOfHouseholdEmail() + '/Photos');
  TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  Future<Null> _handlePhotoButtonPressed() async {
    var imageFile = await ImagePicker.pickImage();
    var random = new Random().nextInt(10000);
    var ref = FirebaseStorage.instance.ref().child('image_$random.jpg');
    var uploadTask = ref.put(imageFile);
    var downloadUrl = (await uploadTask.future).downloadUrl;

    _textController.clear();
    _googleSignIn.signInSilently().then((user) {
      messages.document().setData(<String, String>{
        'text': '',
        'sender': user.displayName,
        'senderID': me.uid,
        'userImgUrl': user.photoUrl,
        'imageUrl': downloadUrl.toString()
      });
      photos.document().setData(<String, String>{
        'sender': user.displayName,
        'senderID': me.uid,
        'imageUrl': downloadUrl.toString()
      });
    });
  }


  void _handleMessageChanged(String text) {
    setState(() {
      _isComposing = text.length > 0;
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if(text != '') {
      _googleSignIn.signInSilently().then((user) {
        messages.document().setData(
            <String, String>{
              'text': text,
              'sender': user.displayName,
              'senderID': me.uid,
              'userImgUrl': user.photoUrl,
              'imageUrl': ''
            });
      });
    }
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new PlatformAdaptiveContainer(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(children: [
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.photo),
                  onPressed: _handlePhotoButtonPressed,
                ),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  onChanged: _handleMessageChanged,
                  decoration:
                  new InputDecoration.collapsed(hintText: 'Send a message'),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new PlatformAdaptiveButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null,
                    child: new Text('Send'),
                  )),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('The Hub'),
        ),
        body:
        new Column( children: [
          new MessageList(),
          new Divider(height: 1.0),
          new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer()),
        ],)
//        new MessageList(),
//        floatingActionButton: new FloatingActionButton(
//          onPressed: _addMessage,
//          tooltip: 'Increment',
//          child: new Icon(Icons.add),
//        ),
    );
  }
}


///////////////////////////////////////////////////////////////////////////////


