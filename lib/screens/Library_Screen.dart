import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Favourites_screen.dart';
import 'package:podwave/screens/Home_Screen.dart';
import 'package:podwave/screens/Profile_Screen.dart';
import 'package:podwave/screens/Recently_screen.dart';
import 'package:podwave/screens/Search_Screen.dart';
import 'package:podwave/screens/Your_Podcasts.dart';
import 'package:podwave/screens/splash_screen.dart';

import 'Play_Audio.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {

  int _selectedIndex = 2;
  bool _isTapped = false;
  bool _isTapped2 = false;
  bool _isTapped3 = false;

  void _onTap(Widget nextScreen,int x) async {
    setState(() {
      if(x==1){
        _isTapped = true;
      }
      else if(x==2){
        _isTapped2 = true;
      }else if(x==3){
        _isTapped3 = true;
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
      }
    });
  }

  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void searchPodcast(String searchValue) {
    FirebaseFirestore.instance
        .collection('Podcast')
        .where('title', isGreaterThanOrEqualTo: searchValue.toLowerCase()).where('title', isLessThanOrEqualTo: searchValue.toLowerCase() + '\uf8ff')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _searchResults = snapshot.docs;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
              colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
    children: [
          Transform.translate(
            offset:  Offset(-90,0),
            child: Text('Library',style: GoogleFonts.actor(fontSize: 40, color: Colors.purple),),
          ),
          GestureDetector(
            onTap: (){_onTap(RecentlyPlayed(), 1); },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: _isTapped ? Colors.purple : Colors.transparent,
                borderRadius: BorderRadius.circular(_isTapped ? 40.0 : 0.0),
              ),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('  Recently played',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                  Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){_onTap(FavouritesScreen(), 2); },
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
                  Text('  Favourites',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                  Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              _onTap(Your_podcast(), 3);
            },
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
                  Text('  Podcasts',style: GoogleFonts.actor(fontSize: 25,color: Colors.white),),
                  Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
                ],
              ),
            ),
          ),
          SizedBox(height: 5,),
           Transform.translate(
             offset: Offset(-60, 0),
               child: Text('More podcasts',style: GoogleFonts.actor(fontSize: 31,color: Colors.white),)),
          // TextField(
          //   controller: _searchController,
          //   decoration: InputDecoration(
          //       fillColor: Colors.white,
          //       filled: true,
          //       hintText: 'Search',
          //       prefixIcon: Icon(Icons.search),
          //       contentPadding: EdgeInsets.symmetric(vertical: 10),
          //       border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(12),
          //           borderSide: BorderSide.none
          //       )
          //   ),
          //   onChanged: (value) {
          //     searchPodcast(value);
          //   },
          // ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: _searchResults.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         leading: ClipRRect(
            //           borderRadius: BorderRadius.circular(15),
            //           child: Image.network(
            //             _searchResults[index]['imageURL'],
            //             width: 60,
            //             height: 60,
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //         title: Text(_searchResults[index]['title'],style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
            //         subtitle: Text(_searchResults[index]['description'],style: TextStyle(color: Colors.white),),
            //         onTap: () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => PlayAudio(
            //                   audioURL: _searchResults[index]["audioURL"],
            //                   imageURL: _searchResults[index]["imageURL"],
            //                   user: _searchResults[index]["user"],
            //                   title: _searchResults[index]["title"]),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
              SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 20),
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
                  height: 200,
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          child: Image.network('https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F97151bSiLfzmvdVPapNFL4N00lp2K7F02?alt=media&token=365187d6-4606-4c22-acb9-ef1bf1a0e510'),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      Expanded(child: Text('Happy hour',style: GoogleFonts.actor(fontSize: 20,color: Colors.white)),)

                    ],
                  ),
                ),
              ),
              SizedBox(width: 40),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayAudio(
                          audioURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_audios%2F%22Sam%20Levinson2023-05-26%2022%3A51%3A35.825067%22?alt=media&token=8a482908-b886-4f74-8102-9ecd3154b547",
                          imageURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F48959JChPhru0dRPMqKHhdd30GgUmzuN2?alt=media&token=689ff6ed-d2f9-4951-9323-f663645c9fe5",
                          user: "Sam Levinson",
                          title: "Euphoria Creator Accused",
                          docID: "BtwMbjQ55mgRju0MWoHL"),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        child: Image.network('https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F48959JChPhru0dRPMqKHhdd30GgUmzuN2?alt=media&token=689ff6ed-d2f9-4951-9323-f663645c9fe5'),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      Expanded(child: Text('Euphoria Creator Accused',style: GoogleFonts.actor(fontSize: 20,color: Colors.white)),)

                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 20),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayAudio(
                      audioURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_audios%2F%22ShxtNGigs2023-05-26%2023%3A27%3A19.822451%22?alt=media&token=792b63d6-1341-44e9-ba43-d0a81d8869db",
                      imageURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F67967vZNBxTn23PUN9SynackGsLj2NgW2?alt=media&token=0d274aba-ba31-4a76-a7ea-02df99ebc2cc",
                      user: "ShxtNGigs",
                      title: "Worst Thing Has Done On A Date",
                      docID: "FSJVU8sK6ZTyquInvqF6"),
                ),
              );
            },
            child: Container(
              height: 225,
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    child: Image.network('https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F67967vZNBxTn23PUN9SynackGsLj2NgW2?alt=media&token=0d274aba-ba31-4a76-a7ea-02df99ebc2cc'),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  SizedBox(height: 5,),
                  Text('Worst Thing Has Done On A Date',style: GoogleFonts.actor(fontSize: 20,color: Colors.white))

                ],
              ),
            ),
          ),
              SizedBox(width: 40),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayAudio(
                          audioURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_audios%2F%22Samantha%20Irby2023-05-26%2023%3A03%3A39.510191%22?alt=media&token=5a9ea8d8-b7e0-4843-862d-bedde328d0f4",
                          imageURL: "https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_audios%2F%22Peterschmidt2023-05-26%2023%3A10%3A09.451881%22?alt=media&token=edd54f24-c7ce-4a83-92ce-6702650c692f",
                          user: "Peterschmidt",
                          title: "Universe of art",
                          docID: "WLa5MEzxa3rruSvooWTB"),
                    ),
                  );
                },
                child: Container(
                  height: 225,
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        child: Image.network('https://firebasestorage.googleapis.com/v0/b/pod-wave.appspot.com/o/podcast_images%2F94151o68mRGudaQSG7cskEDF1muY8Ua63?alt=media&token=c9f1d221-18d2-40b8-9fc0-4996759504af'),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      Expanded(child: Text('Universe of art',style: GoogleFonts.actor(fontSize: 20,color: Colors.white)),)

                    ],
                  ),
                ),
              ),
            ],
          ),
      SizedBox(height: 40,)
          ],
          ),
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
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),);
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
