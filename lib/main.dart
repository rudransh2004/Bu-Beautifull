import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import "package:rflutter_alert/rflutter_alert.dart";
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import "package:image_cropper/image_cropper.dart";
import 'package:emoji_picker/emoji_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:bubeautifull/drawer.dart';
import 'package:bubeautifull/MemesShow.dart';

void main(){

  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home:Myapp(),
  ),
  );
}

class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {


  String fileName;
  Filter _filter;
  List<Filter> filters = presetFiltersList;
  File imageFile;
  File _image;

  Future getimagefile(ImageSource source) async {
    imageFile = await ImagePicker.pickImage(source: source);
    fileName = basename(imageFile.path);
    setState(() {
      _image = imageFile;
    });

  }


  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        GallerySaver.saveImage(croppedFile.path, albumName: "BU-BEUTIFULL");
        imageFile = croppedFile;
      });
    }
  }

  Future applyphotofilters(context) async {
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);

    Map _imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) =>
        new PhotoFilterSelector(
          title: Text("Photo Filter Example"),
          image: image,
          filters: presetFiltersList,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (_imagefile != null && _imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = _imagefile['image_filtered'];
      });
    }
  }
  Future saveinthegallery()async{
    GallerySaver.saveImage(imageFile.path, albumName: "BU-BEUTIFULL");
  }

  Future emojipicker() async{
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        print(emoji);
      },);
  }
  int _currentindex = 0;
  final tabs = [
    Center(child: Text("CROP your image here")),
    Center(child: Text("ADD Text to your image here")),
    Center(child: Text("FILTER your image here")),
    Center(child: Text("ADD emojis here")),
    Center(child: Text("ERASE your text written")),
  ];

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;

    return Scaffold(

      backgroundColor: Colors.black,
      body: Column(
        children:[
          Center(
            child: imageFile == null
                ? Text(
              "Please select an image",
            )
                : Image.file(
              imageFile,
              height: 600,
              width: 600,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right:250,bottom:420),
            child:ButtonTheme(
              minWidth: mediaQuery.width,
              height:40,
              child:RaisedButton(
                textColor: Colors.white,
                elevation: 40.0,
                shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ) ,
                color: Colors.blue,
                child: Text("Save!"),
                onPressed: (){
                  saveinthegallery();
                },
              ),
            ),
          ),
        ],
      ),


      drawer:Drawer(

        child: ListView(
          // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    image: DecorationImage(
                        image: AssetImage("assets/gold.jpg"),
                        fit: BoxFit.cover)
                ),
              ),

              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Photo Editor"),
              ),
              ListTile(
                leading: Icon(Icons.insert_emoticon),
                title: Text("Generate Memes"),
                onTap:() {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Meme()));
                }
              ),
              ListTile(
                leading: Icon(Icons.gif),
                title: Text("GIF"),
              ),
            ]
        ) ,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        return Alert(
            context: context,
            title: "Choose your image",
            desc: "Click the one of the button to get your image for editing",
            buttons: [
              DialogButton(
                child: Text('Take a photo'),
                onPressed: () {
                  getimagefile(ImageSource.camera);
                },
              ),
              DialogButton(
                child: Text('Gallery'),
                onPressed: () {
                  getimagefile(ImageSource.gallery);
                },)
            ]
        ).show();
      }, child: Icon(Icons.add_a_photo)),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.transparent,
        currentIndex: _currentindex,
        iconSize: 25,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.crop),
              color: Colors.white,
              onPressed: () {
                _cropImage();
              },
            ),
            title: Text("Crop"),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.text_fields),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Draw()));
              },
            ),
            title: Text("Text"),
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.photo_filter),
              color: Colors.white,
              onPressed: () {
                applyphotofilters(context);
              },
            ),
            title: Text("Filters"),
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.insert_emoticon),
              color: Colors.white,
              onPressed: () {
                emojipicker();
              },
            ),
            title: Text("Emojis"),
            backgroundColor: Colors.yellow,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.phonelink_erase),
              color: Colors.white,
              onPressed: () {
              },
            ),
            title: Text("Erase"),
            backgroundColor: Colors.orange,
          ),
        ],
        onTap: (index)
        {setState(()
        {
          _currentindex = index;
        },
        );
        },
      ),


    );
  }
}
