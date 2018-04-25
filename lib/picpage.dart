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



Widget buildGrid() {
  return new GridView.extent(
      maxCrossAxisExtent: 150.0,
      padding: const EdgeInsets.all(4.0),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      children: _buildGridTileList(7));
}

List<Container> _buildGridTileList(int count) {
  List<String> urlList = ['null'];

  Firestore.instance.collection('Photos').snapshots.listen((snapshot){
    snapshot.documents.forEach((doc) =>  print(doc['imageUrl']) );
//    snapshot.documents.forEach((doc) =>  urlList.add(doc['imageUrl']) );
  });
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_2936.jpg?alt=media&token=0a24d495-3352-47b6-bafa-cc84cad54dd1');
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_4424.jpg?alt=media&token=91e8df5b-e528-4bf2-94f6-e7fa032c76bd');
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_8503.jpg?alt=media&token=39b8577c-f6dc-420c-b455-a37298647953');
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_4088.jpg?alt=media&token=682afbbc-67b3-42cd-a72c-eb114abf8974');
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_1910.jpg?alt=media&token=f6908f1d-1b31-4da8-a87a-eebab67eba38');
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_3217.jpg?alt=media&token=e4a029df-e076-4bfa-bd49-d407a4cf479c');
  urlList.add('https://firebasestorage.googleapis.com/v0/b/kyn-app.appspot.com/o/image_2228.jpg?alt=media&token=8a89c776-ab86-427b-b73a-337beb4fb0e5');

//  print("Objects: " + urlList.length.toString());
//  print("stuff: " + urlList[1]);
  List<Container> containers = new List<Container>.generate(
      count,
          (int index) =>
      new Container(child: new Image.network(urlList[index+1])));
  return containers;
}