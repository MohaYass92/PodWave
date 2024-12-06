import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podwave/screens/Edit_profile.dart';
import 'package:podwave/screens/Home_Screen.dart';
import 'package:podwave/screens/New_User.dart';
import 'package:podwave/screens/Search_Screen.dart';
import 'package:podwave/screens/Library_Screen.dart';
import 'package:podwave/screens/Upload_Screen.dart';
import 'package:podwave/screens/Your_Podcasts.dart';
import '../screens/splash_screen.dart';
import 'Play_Audio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isTapped = false;
  bool _isTapped2 = false;
  bool _isTapped3 = false;
  bool _isTapped4 = false;
  int _selectedIndex = 3;
  String? _userName;
  String? _uid;
  File? _image;
  String? imageUrl;
  CollectionReference userRef = FirebaseFirestore.instance.collection("UsersImages");
  CollectionReference podRef = FirebaseFirestore.instance.collection("Podcast");
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> podcasts = [];
  List? RecentList =[] ;

  Future<void> recent()async{
    CollectionReference usersFavRef = FirebaseFirestore.instance.collection("UsersFav");
    QuerySnapshot querySnapshot = await usersFavRef.where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot snapshot = querySnapshot.docs[0];
      List<String> recList = snapshot.exists ? List<String>.from((snapshot.data() as Map<String, dynamic>)["RecentList"] ?? []) : [];
      QuerySnapshot snapshot2 = await podRef.where(FieldPath.documentId, whereIn: recList).get();

      setState(() {
        podcasts = snapshot2.docs;
        RecentList = recList;
      });
    }
  }


  getProfilePic() async {
     await userRef.where("userID" , isEqualTo: _uid).get().then((value) {
       value.docs.forEach((element) {

         setState(() {
           imageUrl = (element.data() as Map<String, dynamic>)['imageURL'];
         });
       });
     });
  }

  @override
  void initState() {
    _fetchUserName();
    getProfilePic();
    recent();

    super.initState();
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

  void _onTap(Widget nextScreen,int x) async {
    setState(() {
      if(x==1){
        _isTapped = true;
      }
      else if(x==2){
        _isTapped2 = true;
      }else if(x==3){
        _isTapped3 = true;
      }else if(x==4){
        _isTapped4 = true;
      }

    });

    await Future.delayed(Duration(milliseconds: 200));

    Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen),);

    setState(() {
      if(x==1){
        _isTapped = false;
      }
      else if(x==2){
        _isTapped2 = false;
      }else if(x==3){
        _isTapped3 = false;
      }else if(x==4){
        _isTapped4 = false;
      }
    });
  }



  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var refStorage = FirebaseStorage.instance.ref("profil_images/$_uid");
      await refStorage.putFile(File(pickedFile.path));
      var url = await refStorage.getDownloadURL();
      await userRef.add({
        "userID": _uid,
        "imageURL": url,
      });
      setState(() {
        _image = File(pickedFile.path);
        imageUrl=url;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'),backgroundColor: Colors.red,),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: ListView(
          children:[ Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Transform.translate(
                  offset: const Offset(-110, -15),
                  child:  Text(
                    'Profile',
                    style: GoogleFonts.actor(fontSize: 40, color: Colors.purple),
                  ),
                ),

                Row(
                  children: [
                    const SizedBox(width: 30,),
                    if (imageUrl != null)
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                      )
                    else
                      CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Colors.purple,
                        child: IconButton(
                          icon: const Icon(Icons.add_a_photo_outlined,color: Colors.black,),
                          onPressed: _getImage,
                        ),
                      ),
                    SizedBox(width: 15),
                    if (_userName != null && _uid != null)
                      Column(

                        children:[
                          Text(
                            _userName!,
                            style: GoogleFonts.actor(fontSize: 30, color: Colors.white),
                          ),

                      Text('ID:$_uid',
                        style: GoogleFonts.actor(fontSize: 13, color: Colors.white),
                       ),
                       ],
                     ),

                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap:(){_onTap(EditProfile(),4);},
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isTapped4 ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(_isTapped4 ? 40.0 : 0.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('  Edit profile',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                        Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:(){_onTap(Your_podcast(),3);},
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isTapped3 ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(_isTapped3 ? 40.0 : 0.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('  Your Podcasts',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                        Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                      ],
                    ),
                  ),
                ), GestureDetector(
                onTap: () {
                  _onTap(UploadScreen(),1);
                },

                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    height:60,
                    decoration: BoxDecoration(
                      color: _isTapped ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(_isTapped ? 40.0 : 0.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('  Upload',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                        Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                      ],
                    ),
                  ),
                ), GestureDetector(
                  onTap: (){_onTap(NewUserScreen(),2);},
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isTapped2 ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(_isTapped2 ? 40.0 : 0.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('  Help and support',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                        Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                      ],
                    ),
                  ),
                ),
                Transform.translate(offset: Offset(-70,25),
                    child: Text('Recently Played',style: GoogleFonts.actor(fontSize: 30,color: Colors.white),)),
                SizedBox(height: 20),
                Column(
                  children: [
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayAudio(
                                audioURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_audios%2F%22Samantha%20Irby2023-05-26%2023%3A03%3A39.510191%22?alt=media&token=5a9ea8d8-b7e0-4843-862d-bedde328d0f4",
                                imageURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F70872tlDnfUuRMGOaN5hcMEKKzzYKNch1?alt=media&token=6ddd5dc7-31de-48f5-b7ac-f14f9b539628",
                                user: "Samantha Irby",
                                title: "Fresh Air",
                                docID: "cYnJJ8snrHrzsJKTzUwI"),
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 20),
                            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network('https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F70872tlDnfUuRMGOaN5hcMEKKzzYKNch1?alt=media&token=6ddd5dc7-31de-48f5-b7ac-f14f9b539628')),
                            SizedBox(width: 10),
                            Container(
                              width: 230,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Fresh Air',style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
                                  Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayAudio(
                                audioURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_audios%2F%22Jane%20Healey2023-05-26%2022%3A57%3A25.011743%22?alt=media&token=f78d6496-b322-4466-baed-cad7b8cf3016",
                                imageURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F97151bSiLfzmvdVPapNFL4N00lp2K7F02?alt=media&token=365187d6-4606-4c22-acb9-ef1bf1a0e510",
                                user: "Jane Healey",
                                title: "Happy hour",
                                docID: "0T1kECBEEnOovF8Hv6O5"),
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 20),
                            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network('https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F97151bSiLfzmvdVPapNFL4N00lp2K7F02?alt=media&token=365187d6-4606-4c22-acb9-ef1bf1a0e510')),
                            SizedBox(width: 10),
                            Container(
                              width: 230,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Happy hour',style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
                                  Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          ]
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              // navigate to profile screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),);
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibraryScreen()),);
            }if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered_rtl),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
