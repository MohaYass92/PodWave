import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Profile_Screen.dart';
import 'package:podwave/screens/splash_screen.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({Key? key}) : super(key: key);

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {

  @override

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
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(16.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Icon(Icons.contact_support_outlined,color: Colors.purple,size: 40,),
                  Text('Contact Us', style: GoogleFonts.actor(fontSize: 30,color: Colors.purple,fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8.0),
              Text('Leave a Message',style: GoogleFonts.actor(fontSize: 22,color: Colors.white)),
              SizedBox(height: 16.0),
              TextFormField(
              decoration: InputDecoration(
              labelText: 'Name :',
              labelStyle: GoogleFonts.actor(fontSize: 18,color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple),
              ),
              ),
              style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email :',
                    labelStyle: GoogleFonts.actor(fontSize: 18,color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              SizedBox(height: 8.0),
              TextFormField(
              decoration: InputDecoration(
              labelText: 'Message :',
                labelStyle: GoogleFonts.actor(fontSize: 18,color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple),
              ),
              ),
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                onPressed: () {
                        //envoyer un e-mail à l'équipe de support
                        showDialog(
                        context: context,
                        builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text('Message Sent'),
                                content: Text('Thank you for contacting us. We will get back to you soon.'),
                                actions: [
                                TextButton(
                                onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()),);
                                },
                                child: Text('OK'),
                                ),],);
                               },
                            );
                        },
                child: Text('Send Message',style:GoogleFonts.actor(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fixedSize: Size(150, 50),
                  ),
                ),
              ),
                SizedBox(height: 16.0),
                Text(
                  'Visit our website:',
                  style: GoogleFonts.actor(fontSize: 18,color: Colors.white),
                ),
                SizedBox(height: 8.0),
                Text(
                  'www.PodWave.com',
                  style: GoogleFonts.actor(fontSize: 18,color: Colors.blue,decoration: TextDecoration.underline),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Follow us on social media:',
                  style:GoogleFonts.actor(fontSize: 18,color: Colors.white),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.facebook,color: Colors.white,size:29),
                    Text("  PodWave",style: GoogleFonts.actor(fontSize: 18,color: Colors.white),)
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset("images/twitter.png",scale: 20,color: Colors.white,),
                    Text("  @PodWave",style: GoogleFonts.actor(fontSize: 18,color: Colors.white),)
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset("images/instagram.png",scale: 20,color: Colors.white,),
                    Text("  PodWave_DZ",style: GoogleFonts.actor(fontSize: 18,color: Colors.white),)
                  ],
                ),

              ],
              ),
              ),
        ),
      ),
          );
  }
}
