import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/splash_screen.dart';

class PlayAudio extends StatefulWidget {
  final audioURL;
  final imageURL;
  final title;
  final user;
  final docID;
  PlayAudio({required this.audioURL, required this.imageURL, required this.user, required this.title, this.docID});

  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {

  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  IconData FavIcon =CupertinoIcons.heart;
  CollectionReference userRef = FirebaseFirestore.instance.collection("UsersFav");





  String formatTime(int sec){
    return "${(Duration(seconds: sec))}".split(".")[0].padLeft(8,"0");
  }
  initPlayer() async{
    await player.play(UrlSource(widget.audioURL));

  }

  initFav()async{
    QuerySnapshot querySnapshot = await userRef.where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot snapshot = querySnapshot.docs[0];
      List<String> favoriteList = snapshot.exists ? List<String>.from((snapshot.data() as Map<String, dynamic>)["FavList"] ?? []) : [];
      if (favoriteList.contains(widget.docID)) {
        // Podcast is already in the favorite list
        setState(() {
          FavIcon = CupertinoIcons.heart_fill;
        });
      } else {
        // Podcast is not in the favorite list
        setState(() {
          FavIcon = CupertinoIcons.heart;
        });
      }

    }
  }

  addtoRecent()async{
    QuerySnapshot querySnapshot = await userRef.where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot snapshot = querySnapshot.docs[0];
      List<String> recentList = snapshot.exists ? List<String>.from((snapshot.data() as Map<String, dynamic>)["RecentList"] ?? []) : [];
      if (recentList.contains(widget.docID)) {
        // Podcast is already in the Recent list
        recentList.remove(widget.docID);
        recentList.insert(0, widget.docID);

      } else {
        // Podcast is not in the Recent list
        recentList.insert(0, widget.docID);
      }
      await snapshot.reference.update({
        "RecentList": recentList,
      });
    }
  }

  addORremoveFav()async{
    QuerySnapshot querySnapshot = await userRef.where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot snapshot = querySnapshot.docs[0];
      List<String> favoriteList = snapshot.exists ? List<String>.from((snapshot.data() as Map<String, dynamic>)["FavList"] ?? []) : [];
      if (favoriteList.contains(widget.docID)) {
        // Podcast is already in the favorite list, so remove it
        favoriteList.remove(widget.docID);
        setState(() {
          FavIcon = CupertinoIcons.heart;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Podcast removed from favourites'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Podcast is not in the favorite list, so add it
        favoriteList.add(widget.docID);
        setState(() {
          FavIcon = CupertinoIcons.heart_fill;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Podcast Added to favourites'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await snapshot.reference.update({
        "FavList": favoriteList,
      });

    }

    // print(favoriteList);
  }

  @override
  void initState() {
    super.initState();
    addtoRecent();
    initFav();
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
    initPlayer();
  }

  void add15Seconds() async {
    // Get the current position of the audio
    Duration? currentPosition = await player.getCurrentPosition();

    // Add 15 seconds to the current position
    Duration newPosition = currentPosition! + const Duration(seconds: 15);

    // Seek to the new position in the audio stream
    player.seek(newPosition);
  }
  void sub15Seconds() async {
    // Get the current position of the audio
    Duration? currentPosition = await player.getCurrentPosition();

    // Add 15 seconds to the current position
    Duration newPosition = currentPosition! - const Duration(seconds: 15);

    // Seek to the new position in the audio stream
    player.seek(newPosition);
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
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
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
          child: Column(
          children: [
          Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.greenAccent, size: 40),
            onPressed: () {
              player.stop();
              Navigator.pop(context);
            },
          ),
    ),
            SizedBox(height: 30),
            Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 1),
            image: DecorationImage(
            image: NetworkImage(widget.imageURL),
            fit: BoxFit.cover,
            ),
            ),
            ),
            SizedBox(height: 20),
            Text(widget.title, style: GoogleFonts.actor(color: Colors.white, fontSize: 30)),
            SizedBox(height: 5),
            Text(widget.user, style: GoogleFonts.actor(color: Colors.purple, fontSize: 20)),
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
            Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.translate(offset :Offset(0,-10),
                        child: Text(formatTime(position.inSeconds),style: TextStyle(color: Colors.greenAccent),)),
                    IconButton(
                      icon: Icon(FavIcon,color: Colors.greenAccent,size: 40),
                      onPressed: addORremoveFav,
                    ),
                    Transform.translate(offset :Offset(0,-10),
                        child: Text(formatTime((duration-position).inSeconds),style: TextStyle(color: Colors.greenAccent),)),
                  ],
                ),
              ),
            ),
            Transform.translate(offset :Offset(0,-30),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0,-15),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 40,
                      child: Center(
                        child: IconButton(
                            icon: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..scale(-1.0, 1.0),
                                child: Icon(Icons.refresh_rounded,color: Colors.greenAccent,size: 70,)),
                            onPressed: sub15Seconds ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    radius: 40,
                    child: Center(
                      child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause_outlined : Icons.play_arrow, color: Colors.black,size: 35,),
                      onPressed: ()async{
                        if(isPlaying){
                          player.pause();
                        }else{
                          await player.play(UrlSource(widget.audioURL));
                        }
                      },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0,-16),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 40,
                      child: Center(
                        child: IconButton(
                            icon: Icon(Icons.refresh_rounded,color: Colors.greenAccent,size: 70,),
                            onPressed: add15Seconds ,)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
          ),
        ),
      ),
    );
  }
}
