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
import 'package:kyn/main.dart';
import 'package:kyn/hubpage.dart';
import 'package:meta/meta.dart';


class PicturesPage extends StatefulWidget{
  @override
  State createState() => new PicturesPageState();
}

class PicturesPageState extends State<PicturesPage>{
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
  CollectionReference get photos => Firestore.instance.collection('Family/' + session.getHeadOfHouseholdEmail() + '/Photos');


  Future<Null> _handlePhotoButtonPressed() async {
    var imageFile = await ImagePicker.pickImage();
    var random = new Random().nextInt(10000);
    var ref = FirebaseStorage.instance.ref().child('image_$random.jpg');
    var uploadTask = ref.put(imageFile);
    var downloadUrl = (await uploadTask.future).downloadUrl;

    _googleSignIn.signInSilently().then((user) {
      photos.document().setData(<String, String>{
        'sender': user.displayName,
        'senderID': me.uid,
        'imageUrl': downloadUrl.toString()
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Photos"),
        ),
        body: new StreamBuilder<QuerySnapshot>(
            stream:
              Firestore.instance.collection('Family/'+session.getHeadOfHouseholdEmail()+'/Photos').snapshots,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new Text("Loading...");
              return new Column(
              children: <Widget>[
                new Flexible(
                    child: new ListView(
                      children: snapshot.data.documents.map((DocumentSnapshot document) {
                        return new ListTile(
                          title: new Card(
                              child: new Container(
                                child: new Image.network(document['imageUrl']),
                              )
                          ),
                        );
                      }).toList(),
                    )
                )
              ],
              );
            }
        ),
        floatingActionButton: new FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            tooltip: 'Add', // used by assistive technologies
            child: new Icon(Icons.add),
            onPressed: _handlePhotoButtonPressed
        )
    );
  }
}
