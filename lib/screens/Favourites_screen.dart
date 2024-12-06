import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/splash_screen.dart';

import 'ListYourPodcasts.dart';
import 'List_Categories.dart';
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {

  CollectionReference podRef = FirebaseFirestore.instance.collection("Podcast");
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> podcasts = [];
  List? favoriteListO =[] ;


  Future<void> refresh2()async{
    CollectionReference usersFavRef = FirebaseFirestore.instance.collection("UsersFav");
    QuerySnapshot querySnapshot = await usersFavRef.where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot snapshot = querySnapshot.docs[0];
      List<String> favoriteList = snapshot.exists ? List<String>.from((snapshot.data() as Map<String, dynamic>)["FavList"] ?? []) : [];
      QuerySnapshot snapshot2 = await podRef.where(FieldPath.documentId, whereIn: favoriteList).get();

      setState(() {
        podcasts = snapshot2.docs;
        favoriteListO = favoriteList;
      });
    }
  }

  @override
  void initState() {
  refresh2();
  super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: refresh2,
          child: podcasts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_off_outlined, color: Colors.white, size: 30),
                Text(
                  "No podcasts available",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot podcast = podcasts[index];
              return ListCategory(
                podcasts: podcast,
                docID: podcast.id,
              );
            },
          ),
        ),
      ),
    );
  }
}



