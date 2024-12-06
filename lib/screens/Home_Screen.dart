import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podwave/screens/Library_Screen.dart';
import 'package:podwave/podcast.dart';
import 'package:podwave/screens/Podcast_Categories_lists.dart';
import 'package:podwave/screens/Profile_Screen.dart';
import 'package:podwave/screens/Upload_Screen.dart';
import 'package:podwave/screens/splash_screen.dart';
import 'package:podwave/screens/Search_Screen.dart';
import 'package:google_fonts/google_fonts.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

List<String> imagePaths = [
  'images/pexels-pixabay-270288.jpg',
  'images/pexels-pixabay-268533.jpg',
  'images/pexels-asad-photo-maldives-3293148.jpg',
  'images/pexels-sevenstorm-juhaszimrus-443383.jpg',
  'images/pexels-wallsio-15595146.jpg',
];

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastPressed;
  int _currentIndex = 0;
  int _selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentIndex == imagePaths.length - 1) {
          _currentIndex = 0;
          _pageController.jumpToPage(0);
        } else {
          _currentIndex++;
          _pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressed == null || now.difference(_lastPressed!) > Duration(seconds: 2)) {
          _lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ));
          return false;
        }
        return true;
      },
      child: Scaffold(
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
        body: ListView(
          children: [Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(29, 27, 61, 1),Color.fromRGBO(29, 27, 61, 1),Color.fromRGBO(29, 27, 61, 1), Color.fromRGBO(62, 21, 215, 1)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            //color: Color.fromRGBO(29, 27, 61, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(0,-80),
                  child: Container(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imagePaths.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          child: Center(
                            child: Image.asset(
                              imagePaths[index],
                              width: 400,
                              height: 300,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Transform.translate(offset: Offset(-100,-130),
                  child: Text('Categories',style: GoogleFonts.alef(
                      fontSize: 30,color: Colors.white),),
                ),
                Transform.translate(
                  offset: Offset(0, -110),
                  child: Container(
                    height: 170,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Podcast_list(category:"Arts",)),);
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 200,
                                    height: 130,
                                    child: Image.asset('images/pexels-thirdman-6732517.jpg'),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0,15),
                                    child: Text('Arts', style: TextStyle(color: Colors.white,fontSize: 17))),
                              ],
                            ),
                          ),
                        ), Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Podcast_list(category:"Comedy",)),);
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 200,
                                    height: 130,
                                    child: Image.asset('images/pexels-pixabay-269140.jpg'),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0,15),
                                    child: Text('Comedy', style: TextStyle(color: Colors.white,fontSize: 17))),
                              ],
                            ),
                          ),
                        ), Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Podcast_list(category:"Business",)),);
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 200,
                                    height: 130,
                                    child: Image.asset('images/pexels-pixabay-534216.jpg'),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0,15),
                                    child: Text('Business', style: TextStyle(color: Colors.white,fontSize: 17))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0,-170),
                  child: Container(
                    height: 400,
                    width: 450,
                    child: Image.asset('images/upload_image2.png'),
                  ),
                ),
                Transform.translate(
                  offset:Offset(-125,-300),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: GestureDetector(
                      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => UploadScreen()),);},
                      child: Container(
                       color: Colors.greenAccent,
                        height: 30,
                        width: 130,
                        alignment: Alignment.center,
                        child: Text('Upload podcast',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),

                        ),
                    ),
                  ),
                ),
                Transform.translate(offset: Offset(-60,-275),
                  child: Text('More categories',style: GoogleFonts.alef(
                      fontSize: 30,color: Colors.white),),
                ),
                Transform.translate(
                  offset: Offset(0,-260),
                  child: Container(
                    height: 170,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Podcast_list(category:"Education",)),);
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 200,
                                    height: 130,
                                    child: Image.asset('images/pexels-pixabay-267885.jpg'),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0,15),
                                    child: Text('Education', style: TextStyle(color: Colors.white,fontSize: 17))),
                              ],
                            ),
                          ),
                        ), Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Podcast_list(category:"Music",)),);
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 200,
                                    height: 130,
                                    child: Image.asset('images/pexels-wendy-wei-1190298.jpg'),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0,15),
                                    child: Text('Pop culture', style: TextStyle(color: Colors.white,fontSize: 17))),
                              ],
                            ),
                          ),
                        ), Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Podcast_list(category:"News",)),);
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 200,
                                    height: 130,
                                    child: Image.asset('images/pexels-cottonbro-studio-3944417.jpg'),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0,15),
                                    child: Text('News', style: TextStyle(color: Colors.white,fontSize: 17))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),]
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
              if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),);
              }if (index == 2) {
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

      ),
    );
  }
}

