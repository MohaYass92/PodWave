import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Signup_Screen.dart';
import 'package:podwave/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1),Color.fromRGBO(35, 31, 49, 1), Color.fromRGBO(62, 21, 215, 1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'images/logo name.png',
                  height: 400,
                ),
                // SizedBox(height: 20),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: Text(
                      'You’re moments away from\ndiscovering podcasts that\n         will delight you!',
                      style: GoogleFonts.irishGrover(
                          fontSize: 25,color: Colors.purple
                      )
                  ),
                ),

                GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child:  Center(
                          child: Text(
                            'Sign up',style: GoogleFonts.itim(fontSize: 25)
                          ),
                        ),

                      ),

                    ),
                     onTap: () {Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => SignupScreen()),);},
                  ),
                Transform.translate(
                  offset: const Offset(0, 40),
                  child: GestureDetector(
                    child: const Text(
                        'Already a user ?',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                            )  ,
                    ),
                    onTap: () {Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginScreen()),);},
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

