import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/List_Categories.dart';
import 'package:podwave/screens/splash_screen.dart';


class Podcast_list extends StatefulWidget {
  final category;
  Podcast_list({required this.category});

  @override
  State<Podcast_list> createState() => _Podcast_listState();
}

class _Podcast_listState extends State<Podcast_list> {
  
  CollectionReference podRef = FirebaseFirestore.instance.collection("Podcast");


  
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
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: FutureBuilder(
          future: podRef.where("category",isEqualTo: widget.category).get(),
          builder: (context , snapshot){
            if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context , i){
                    return ListCategory(podcasts: snapshot.data?.docs[i],docID: snapshot.data!.docs[i].id);
                  });
            }else{
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.music_off_outlined,color: Colors.white,size: 30,),
                    Text(
                      "No podcasts in this category",
                      style: TextStyle(color: Colors.white,fontSize: 25),
                    ),
                  ],
                ),
              );
            }
            }
            if(snapshot.hasError){
              return Text("Error",style: TextStyle(color: Colors.white),);
            }return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),));
          }

        ),
      ),

    );
  }
}
