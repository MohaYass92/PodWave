import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podwave/screens/Your_Podcasts.dart';
import 'package:podwave/screens/splash_screen.dart';


class EditPodcast extends StatefulWidget {
  final title;
  final description;
  final imageURL;
  final audioUrl;
  final category;
  final date;
  EditPodcast({
    required this.title,
    required this.description,
    required this.imageURL,
    required this.audioUrl,
    required this.category,
    required this.date,
  });

  @override
  State<EditPodcast> createState() => _EditPodcastState();
}

class _EditPodcastState extends State<EditPodcast> {

  File? selectedImage;
  var nameimage;
  String? _userName;
  String? _uid;
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? _NewimageUrl;
  String? _NewaudioUrl;
  File? _audioFile;
  String? filePath;
  bool _isUploading = false;
  String? selectedCategory;
  CollectionReference podRef = FirebaseFirestore.instance.collection("Podcast");



  String formatTime(int sec){
    return "${(Duration(seconds: sec))}".split(".")[0].padLeft(8,"0");
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      setState(() {
        _userName = user.displayName!;
        _uid = user.uid;
      });
    }
  }

  void _addImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var rand = Random().nextInt(100000);
      nameimage = "$rand$_uid";
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'),backgroundColor: Colors.red,duration: Duration(seconds: 5),),
      );
    }
  }

  addAudio()async{
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null) {
        setState(() {
          if (result != null && result.files.isNotEmpty && result.files.single != null) {
            _audioFile = File(result.files.single.path!);
            filePath = result.files.first.path;
          }
        });
      }else{
        warning("No audio file selected");
      }
    } catch (e) {
      warning('Error picking audio file $e');
    }
  }

  void warning(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  EditPod()async{
    if(_title.text.isEmpty&&_description.text.isEmpty){warning("Must fill every text field ");}
    else if(_title.text.length<2||_title.text.length>30){warning("Please choose a title between 2 and 30 letters");}
    else if(_description.text.length<10||_description.text.length>300) {warning("Description must be at least 10 characters");}
    else {


    setState(() {
      _isUploading = true;
    });
    if(selectedImage != null){
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref1 = storage.refFromURL(widget.imageURL);
      await ref1.delete().then((_) {
        print('===================Image deleted successfully========================');
      }).catchError((error) {
        print('======================Error deleting image: $error=========================');
      });
      var ref = FirebaseStorage.instance.ref("podcast_images/$nameimage");
      await ref.putFile(selectedImage!);
      print('===================Image uploaded successfully========================');
      _NewimageUrl = await ref.getDownloadURL();
      print('===================$_NewimageUrl========================');
      await podRef.where('Date', isEqualTo: widget.date).where('description', isEqualTo: widget.description)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update(
              {
                "imageURL": _NewimageUrl,
              });
        });
      });

    }
    if(_audioFile != null){
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref2 = storage.refFromURL(widget.audioUrl);
      await ref2.delete().then((_) {
        print('===================Audio deleted successfully========================');
      }).catchError((error) {
        print('======================Error deleting audio: $error=========================');
      });
      final ref = FirebaseStorage.instance.ref().child('podcast_audios/"$_userName${DateTime.now().toString()}"');

      final uploadTask = ref.putFile(_audioFile!);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);
      _NewaudioUrl = await ref.getDownloadURL();
      await podRef.where('Date', isEqualTo: widget.date).where('description', isEqualTo: widget.description)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update(
              {
                "audioURL": _NewaudioUrl,
              });
        });
      });

    }
    await podRef.where('Date', isEqualTo: widget.date).where('description', isEqualTo: widget.description)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update(
            {
          "title": _title.text.trim(),
          "description": _description.text.trim(),
          "category": selectedCategory,
        });
      });
     });


    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Podcast edited successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Your_podcast(),
      ),
    );
    }
  }


  @override
  void initState() {
    _fetchUserName();
    _title.text=widget.title;
    _description.text=widget.description;
    selectedCategory = widget.category;


    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Image.asset('images/logo.png'),
        title: Transform.translate(
          offset : Offset(-10,0),
          child: Text('PodWave',style: GoogleFonts.irishGrover(
              fontSize: 25,color: Colors.purple
          )),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async{
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()),
                );
              } catch (e) {
                print('Error signing out: $e');
              }
            },
            icon: Icon(Icons.logout),
            label: Text('Log Out'),
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(26, 34, 56, 1), // button background color
              onPrimary: Colors.purple, // button text color
            ),
          ),
        ],
        backgroundColor: Color.fromRGBO(26, 34, 56, 1),

      ),
        body:Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: ListView(
            children:[ Column(
              children: [
                Row(
                  children: [
                    Transform.translate(offset: Offset(0,-3),
                      child: IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: Icon(Icons.arrow_back,color: Colors.purple,size: 40,)),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      'Edit podcast',
                      style: GoogleFonts.actor(fontSize: 40, color: Colors.purple),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Icon(Icons.image_outlined,color: Colors.purple,size: 40,),
                    Text("Image",style: GoogleFonts.itim(color: Colors.purple,fontSize: 30)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple, width: 1),
                        image: selectedImage != null
                            ? DecorationImage(
                          image: FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        )
                            :DecorationImage(image: NetworkImage(widget.imageURL),fit: BoxFit.cover,) ,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Column(
                      children: [
                        IconButton(
                            onPressed:_addImage,
                            icon: Icon(Icons.add_a_photo_outlined,color: Colors.purple,size: 40,),),
                        Text("Change Image",style: TextStyle(color: Colors.purple,fontSize: 15),),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Text('T ',style: GoogleFonts.almendraSc(color: Colors.purple,fontSize: 50),),Text('Title',style: GoogleFonts.itim(color: Colors.purple,fontSize: 30),)
                  ],
                ),
                SizedBox(height: 10),
                Container(width: 350,
                  // Title TextField
                  child: TextField(
                    controller: _title,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        fillColor: Colors.grey,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 35),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none
                        )
                    ),

                  ),
                ), SizedBox(height: 20,),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Icon(Icons.text_snippet,color: Colors.purple,size: 40,),
                    SizedBox(width: 10,),
                    Text('description',style: GoogleFonts.itim(color: Colors.purple,fontSize: 30),)
                  ],
                ),
                SizedBox(height: 10),
                Container(width: 350,
                  // Description TextField
                  child: TextField(
                    controller: _description,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        fillColor: Colors.grey,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 35),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none
                        )
                    ),

                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Icon(Icons.audiotrack_outlined,color: Colors.purple,size: 40,),
                    Text("Audio",style: GoogleFonts.itim(color: Colors.purple,fontSize: 30)),
                  ],
                ),
                SizedBox(height: 15,),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.purple, // Set the border color here
                      width: 2, // Set the border width if desired
                    ),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Transform.translate(offset: Offset(10,0),
                            child: Icon(isPlaying ? Icons.pause_outlined : Icons.play_arrow_outlined, color: Colors.greenAccent,size: 35,)),
                        onPressed: ()async{
                          if(isPlaying){
                            player.pause();
                          }else{
                            if(_audioFile== null){
                              await player.play(UrlSource(widget.audioUrl));
                            }else{
                              await player.play(DeviceFileSource(filePath!)); // will immediately start playing
                            }

                          }
                        },
                      ),
                      Slider(
                          activeColor: Colors.greenAccent,
                          inactiveColor: Colors.white,
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble(),
                          onChanged: (value){
                            final position=Duration(seconds: value.toInt());
                            player.seek(position);
                            player.resume();
                          }),
                      Column(
                        children: [
                          IconButton( onPressed:addAudio, icon: Icon(Icons.audiotrack_outlined,color: Colors.purple,size: 30,)),
                          Transform.translate(offset: Offset(0,-10), child: Text("Change Audio",style: TextStyle(color: Colors.purple,fontSize: 15),)),

                        ],
                      ),
                    ],
                  ),
                )
                ,SizedBox(height: 20,),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Icon(Icons.category_outlined,color: Colors.purple,size: 38,),
                    Text(" Category",style: GoogleFonts.itim(color: Colors.purple,fontSize: 30)),
                  ],
                ),
                SizedBox(height: 20,),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        dropdownColor: Color.fromRGBO(35, 31, 49, 1),
                        decoration: InputDecoration(
                          labelText: 'Change a category',
                          labelStyle: TextStyle(color: Colors.purple),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple,width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple,width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(color: Colors.purple,fontSize: 20), // custom color for dropdown button
                        iconEnabledColor: Colors.purple, // custom color for dropdown arrow
                        items: const [
                          DropdownMenuItem(value: 'Arts', child: Text('Arts')),
                          DropdownMenuItem(value: 'Business', child: Text('Business')),
                          DropdownMenuItem(value: 'Comedy', child: Text('Comedy')),
                          DropdownMenuItem(value: 'Education', child: Text('Education')),
                          DropdownMenuItem(value: 'Music', child: Text('Pop culture')),
                          DropdownMenuItem(value: 'News', child: Text('News')),
                        ],
                      ),
                       const SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed:EditPod,
                        child: _isUploading
                            ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),)
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Save",style: TextStyle(color: Colors.black,fontSize: 20)),
                            Icon(Icons.upload,color: Colors.black,size: 30,)
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          fixedSize: Size(300, 50),
                        ),
                      ),



              ],
            ),
            ],
          ),
        ),
    );
  }
}
