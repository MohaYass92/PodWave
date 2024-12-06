import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Home_Screen.dart';
import 'package:podwave/screens/Library_Screen.dart';
import 'package:podwave/screens/Profile_Screen.dart';
import 'package:podwave/screens/splash_screen.dart';

import 'Play_Audio.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  int _selectedIndex = 1;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void searchPodcast(String searchValue) {
    FirebaseFirestore.instance
        .collection('Podcast')
        .where('title', isGreaterThanOrEqualTo: searchValue).where('title', isLessThanOrEqualTo: searchValue + '\uf8ff')
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

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children:  [
            Transform.translate(
                offset: Offset(-82, 10),
                child: Text('Discover',style: GoogleFonts.actor(fontSize: 40, color: Colors.purple),)),
            SizedBox(height: 30,),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                  )
              ),
              onChanged: (value) {
                searchPodcast(value);
              },
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        _searchResults[index]['imageURL'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(_searchResults[index]['title'],style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
                    subtitle: Text(_searchResults[index]['user'],style: TextStyle(color: Colors.white),),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayAudio(
                              audioURL: _searchResults[index]["audioURL"],
                              imageURL: _searchResults[index]["imageURL"],
                              user: _searchResults[index]["user"],
                              title: _searchResults[index]["title"]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),




            //SizedBox(height: 30),
            // Transform.translate(
            //     offset: Offset(-80,10),
            //     child: Text('Most played',style: GoogleFonts.actor(fontSize: 30, color: Colors.white),)
            // ),
            // Column(
            //   children: [
            //     SizedBox(height: 30),
            //     Container(
            //       height: 60,
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           SizedBox(width: 20),
            //           ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('images/pexels-pixabay-162389.jpg')),
            //           SizedBox(width: 10),
            //           Container(
            //             width: 230,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Horror Stories',style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
            //                 Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     SizedBox(height: 15),
            //     Container(
            //       height: 60,
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           SizedBox(width: 20),
            //           ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('images/pexels-pixabay-269140.jpg')),
            //           SizedBox(width: 10),
            //           Container(
            //             width: 230,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('On stage',style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
            //                 Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),SizedBox(height: 15),
            //     Container(
            //       height: 60,
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           SizedBox(width: 20),
            //           ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('images/pexels-wallsio-15595146.jpg')),
            //           SizedBox(width: 10),
            //           Container(
            //             width: 230,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Designers',style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
            //                 Icon(Icons.arrow_forward_outlined,color: Colors.greenAccent,)
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),


          ],
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
    }if (index == 2) {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LibraryScreen()),);
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
