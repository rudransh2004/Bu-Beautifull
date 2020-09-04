import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";
import 'package:bubeautifull/fullscreenshowmemes.dart';



class Meme extends StatefulWidget {
  @override
  _MemeState createState() => _MemeState();
}

class _MemeState extends State<Meme> {
  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> memesList;
  final CollectionReference collectionReference =
  Firestore.instance.collection("image memes");
  @override
  void initState() {
    super.initState();
    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        memesList = datasnapshot.documents;
      });
    });


  }
  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      body: memesList != null
          ? new StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(8.0),
        crossAxisCount: 4,
        itemCount: memesList.length,
        itemBuilder: (context,i){
          String imgPath  = memesList[i].data['url'];
          return new Material(
            elevation: 8.0,
            borderRadius:new BorderRadius.all(new Radius.circular(8.0)),
            child: new InkWell(
              onTap: ()=> Navigator.push(context,new MaterialPageRoute(
                  builder:(context)=>
                  new FullScreenImagePage(imgPath))),
              child: new Hero(
                tag: imgPath,
                child:new FadeInImage(
                  placeholder: new AssetImage("assets/images.jpg"),
                  image: new NetworkImage((imgPath)),
                  fit:BoxFit.cover,
                ),
              ),

            ),

          );
        },
        staggeredTileBuilder: (i)=> new StaggeredTile.count(2,i.isEven?2:3),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      )
          : new Center(
        child: new CircularProgressIndicator(),

      ),
    );
  }
}




