
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podwave/screens/Profile_Screen.dart';
import 'package:podwave/screens/splash_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  String? _userName;
  String? _uid;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  File? selectedImage;
  var _imageUrl ;
  var _audioUrl ;
  String? selectedCategory;
  CollectionReference podRef = FirebaseFirestore.instance.collection("Podcast");
  Color _borderColor = Colors.deepOrange;
  Color _borderColor2 = Colors.deepOrange;
  Color _iconColor = Colors.deepOrange;
  File? _audioFile;
  bool _isUploading = false;
  var nameimage;


  void _addImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var rand = Random().nextInt(100000);
      nameimage = "$rand$_uid";
      setState(() {
        selectedImage = File(pickedFile.path);
        _borderColor2=Colors.green;
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'),backgroundColor: Colors.red,duration: Duration(seconds: 5),),
      );
    }
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

  addPodcast()async{
    if(_title.text.isEmpty&&_description.text.isEmpty){
      warning("Must fill every text field ");
    }else if(_title.text.length<2||_title.text.length>40){
      warning("Please choose a title between 2 and 30 letters");
    }else if(_description.text.length<10||_description.text.length>300){
      warning("Description must be at least 10 characters");
    }else if(selectedImage==null){
      warning("No image selected");
    }else if(_audioFile==null){
      warning("No audio file selected");
    }else if(selectedCategory==null){
      warning("No category selected");
    }else{

        setState(() {
        _isUploading = true;
        });

      var ref = FirebaseStorage.instance.ref("podcast_images/$nameimage");
      await ref.putFile(selectedImage!);
      _imageUrl = await ref.getDownloadURL();


      try {
        // Create a reference to the audio file location in Firebase Storage
        final ref = FirebaseStorage.instance.ref().child('podcast_audios/"$_userName${DateTime.now().toString()}"');

        // Upload the audio file to Firebase Storage
        final uploadTask = ref.putFile(_audioFile!);

        // Wait for the upload to complete
        await uploadTask.whenComplete(() => null);

        // Get the download URL of the uploaded audio file
        _audioUrl = await ref.getDownloadURL();

        setState(() {
          _isUploading = false;
          _audioFile = null;
        });

      } catch (e) {
        print('Error uploading audio file: $e');
        setState(() {
          _isUploading = false;
        });
        warning("Failed to upload audio file") ;
      }

      await podRef.add({
        "title" : _title.text.trim() ,
        "description" : _description.text.trim() ,
        "category" : selectedCategory ,
        "user" : _userName ,
        "userID" : _uid ,
        "imageURL" : _imageUrl ,
        "audioURL" : _audioUrl ,
        "nbrEcoute" : 0 ,
        "Date" : DateTime.now().toString() ,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Podcast uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
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
            _borderColor = Colors.green;
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

  @override
  void initState() {
    _fetchUserName();
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
    body: Container(
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
        Stack(
        children: [
        Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          border: Border.all(color: _borderColor2, width: 2),
        image: selectedImage != null
        ? DecorationImage(
        image: FileImage(selectedImage!),
        fit: BoxFit.cover,
        )
            : null,
        ),
        child: selectedImage != null
        ? null
            : Center(
        child: IconButton(
        icon: Icon(Icons.add_photo_alternate,color: Colors.purple,),
        onPressed: _addImage,
        ),
        ),
        ),
        ],
        ),SizedBox(height: 20,),

          ElevatedButton(
            onPressed: ()async {await addAudio();},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Add audio file",style: TextStyle(color: Colors.purple,fontSize: 20)),
                Icon(Icons.audiotrack_outlined,color: Colors.purple,size: 30,)
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: _borderColor, width: 2),
              ),
              fixedSize: Size(300, 50),
            ),),

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
        Icon(Icons.text_snippet,color: Colors.purple,size: 40,),SizedBox(width: 10,),Text('description',style: GoogleFonts.itim(color: Colors.purple,fontSize: 30),)
        ],
        ),
          SizedBox(height: 10),
          Container(width: 350,
                                                                // Description TextField
            child: TextField(
              controller: _description,
              style: TextStyle(fontSize: 20),
              maxLines: 3,
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

          DropdownButtonFormField<String>(
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                _iconColor=Colors.green;
              });
            },
            dropdownColor: Color.fromRGBO(35, 31, 49, 1),
            decoration: InputDecoration(
              labelText: 'Choose a category',
              labelStyle: TextStyle(color: Colors.purple),
                enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _iconColor,width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _iconColor,width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
            ),
            style: TextStyle(color: Colors.purple,fontSize: 20), // custom color for dropdown button
            iconEnabledColor: _iconColor, // custom color for dropdown arrow
            items: const [
              DropdownMenuItem(value: 'Arts', child: Text('Arts')),
              DropdownMenuItem(value: 'Business', child: Text('Business')),
              DropdownMenuItem(value: 'Comedy', child: Text('Comedy')),
              DropdownMenuItem(value: 'Education', child: Text('Education')),
              DropdownMenuItem(value: 'Music', child: Text('Pop culture')),
              DropdownMenuItem(value: 'News', child: Text('News')),
            ],
          ),

          SizedBox(height: 30,),

          ElevatedButton(
            onPressed:addPodcast ,
            child: _isUploading
                ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),)
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Upload",style: TextStyle(color: Colors.black,fontSize: 20)),
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

