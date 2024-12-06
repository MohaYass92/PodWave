import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podwave/screens/Profile_Screen.dart';
import 'package:podwave/screens/splash_screen.dart';
class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  String? _userName = FirebaseAuth.instance.currentUser!.displayName;
  String? _uid = FirebaseAuth.instance.currentUser!.uid;
  String? _email = FirebaseAuth.instance.currentUser!.email;
  String? imageUrl;
  File? _image;
  bool _isUploading = false;
  CollectionReference userRef = FirebaseFirestore.instance.collection("UsersImages");
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();



  getProfilePic() async {
    await userRef.where("userID" , isEqualTo: _uid).get().then((value) {
      value.docs.forEach((element) {

        setState(() {
          imageUrl = (element.data() as Map<String, dynamic>)['imageURL'];
        });
      });
    });
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {

      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'),backgroundColor: Colors.red,),
      );
    }
  }

  bool isValidEmail(String email) {
    // Define a regular expression pattern for email format
    String str =r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$";
    final RegExp emailRegex = RegExp(str);
    if(emailRegex.hasMatch(email)){
      return true;
    }else {
      warning('invalid email');
      return false;
    }

  }

  EditProf()async{
    var url;
    if(_namecontroller.text.isNotEmpty && _emailcontroller.text.isNotEmpty){
      if(_namecontroller.text.length>2 || _namecontroller.text.length<20){
        if(isValidEmail(_emailcontroller.text.trim())) {
          setState(() {
            _isUploading = true;
          });
          if (_image != null) {
            if (imageUrl != null) {
              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref1 = storage.refFromURL(imageUrl!);
              await ref1.delete().then((_) {
                print(
                    '===================Image deleted successfully========================');
              }).catchError((error) {
                print(
                    '======================Error deleting image: $error=========================');
              });
            }
            var refStorage = FirebaseStorage.instance.ref(
                "profil_images/$_uid");
            await refStorage.putFile(_image!);
            url = await refStorage.getDownloadURL();
            await userRef.where("userID", isEqualTo: _uid).get().then((
                QuerySnapshot querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                doc.reference.update(
                    {
                      "imageURL": url,
                    });
              });
            });
          }
            User? user = FirebaseAuth.instance.currentUser;
            await user?.updateEmail(_emailcontroller.text.trim());
            await user?.updateDisplayName(_namecontroller.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile edited successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
          setState(() {_isUploading = false;});
        }else{warning("Invalid email");setState(() {_isUploading = false;});}
      }else{warning("Invalid username");setState(() {_isUploading = false;});}
    }else{warning("Must fill everything");setState(() {_isUploading = false;});}
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
    getProfilePic();
    _namecontroller.text = _userName!;
    _emailcontroller.text = _email!;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color.fromRGBO(62, 21, 215, 1),
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
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5,),
              Row(
                children: [
                  Transform.translate(offset: Offset(0,-3),
                    child: IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon: Icon(Icons.arrow_back,color: Colors.purple,size: 40,)),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Edit profile',
                    style: GoogleFonts.actor(fontSize: 40, color: Colors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 20,),
                  Icon(Icons.account_circle_outlined,color: Colors.purple,size: 40,),
                  Text("Profile picture",style: GoogleFonts.itim(color: Colors.purple,fontSize: 30)),
                ],
              ),
              const SizedBox(height: 10),
              if (imageUrl != null && _image == null)
                GestureDetector(
                  onTap: _getImage,
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  ),
                )
                else if(_image != null)
                GestureDetector(
                  onTap: _getImage,
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                  ),
                )
              else
                CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo_outlined,color: Colors.black,),
                    onPressed: _getImage,
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 20,),
                  Icon(Icons.drive_file_rename_outline_outlined,color: Colors.purple,size: 40,),
                  Text("Username",style: GoogleFonts.itim(color: Colors.purple,fontSize: 30)),
                ],
              ),
              const SizedBox(height: 10),
                Container(width: 350,
                // Username TextField
                  child: TextField(
                  controller: _namecontroller,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 20,),
                  Icon(Icons.email_outlined,color: Colors.purple,size: 40,),
                  Text("Email",style: GoogleFonts.itim(color: Colors.purple,fontSize: 30)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: 350,
                // Title TextField
                child: TextField(
                  controller: _emailcontroller,
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
              const SizedBox(height:30),
              ElevatedButton(
                onPressed:EditProf,
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
        ),
      ),


    );
  }
}
