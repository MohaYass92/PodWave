import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();

}

class _SignupScreenState extends State<SignupScreen> {

  bool _isuploading = false;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _confirmepasswordcontroller = TextEditingController();
  final _fullname = TextEditingController();
  
  Future signUp() async {
    if(passwordconfirme()){
      if(_fullname.text.isNotEmpty || _emailcontroller.text.isNotEmpty || _passwordcontroller.text.isNotEmpty || _confirmepasswordcontroller.text.isNotEmpty){
        if(isValidEmail(_emailcontroller.text.trim()))
        {if(_passwordcontroller.text.length>=8){
          setState(() {
            _isuploading = true;
          });
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailcontroller.text.trim(),
            password: _passwordcontroller.text.trim(),
          );
          if (userCredential.user != null){
            await userCredential.user?.updateProfile(displayName: _fullname.text.trim());
            var uid = FirebaseAuth.instance.currentUser!.uid;
            CollectionReference userRef = FirebaseFirestore.instance.collection("UsersFav");
            await userRef.add({
              "userID": uid,
              "FavList": [],
              "RecentList": [],
            });
            setState(() {
              _isuploading = false;
            });
            Navigator.of(context).pushNamed('/');
          } else {print('User is null');
          setState(() {
            _isuploading = false;
          });
          }
        }else{
          setState(() {
            _isuploading = false;
          });
          warning("Password must be at least 8 characters");
        }
        }
        else{
        setState(() {
          _isuploading = false;
        });}
      }else{
        setState(() {
          _isuploading = false;
        });warning("You must fill every everything");
      }
    }else{
      setState(() {
        _isuploading = false;
      });
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
  void warning(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool passwordconfirme(){
    if(_passwordcontroller.text.trim() == _confirmepasswordcontroller.text.trim())
    {return true;}
    else {warning('Passwords are not compatibles');
      return false;}
  }

  @override
  void dispose(){
    super.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _confirmepasswordcontroller.dispose();
    _fullname.dispose();
  }

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
        child: SingleChildScrollView(
          child: Transform.translate(
            offset: const Offset(0,-100),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/name.png',
                    height: 400,
                  ),
                  Transform.translate(
                    offset: const Offset(0,-140),
                    child: Text(
                      'Make a free account to start\nlistening to all your favourite\n           podcasts!',
                      style: GoogleFonts.irishGrover(
                          fontSize: 20,color: Colors.white
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-100,-130),
                    child: const Text(
                      'Full Name',
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: 20
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0,-120),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child:  TextField(
                          controller: _fullname,
                          style: TextStyle(fontSize: 20),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-120,-110),
                    child: const Text(
                      'Email',
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: 20
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0,-100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child:  TextField(
                          controller: _emailcontroller,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-100,-90),
                    child: const Text(
                      'Password',
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: 20
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0,-80),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child:  TextField(
                          obscureText: _obscureText1,
                          controller: _passwordcontroller,
                          style: TextStyle(fontSize: 20),
                          decoration:  InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText1 ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText1 = !_obscureText1;
                                });
                              },
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-58,-70),
                    child: const Text(
                      'Confirm password',
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: 20
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0,-60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child:  TextField(
                          obscureText: _obscureText2,
                          controller: _confirmepasswordcontroller,
                          style: TextStyle(fontSize: 20),
                          decoration:  InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText2 ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText2 = !_obscureText2;
                                });
                              },
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0,-30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: GestureDetector(
                        onTap: signUp,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isuploading
                              ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),)
                          :Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sign Up',
                                style: GoogleFonts.itim(fontSize: 25),
                              ),
                              const Icon(Icons.arrow_forward_sharp),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child:  Text(
                      'Already a user ?',
                      style: GoogleFonts.itim(
                        color: Colors.greenAccent,
                        fontSize: 25,
                        decoration: TextDecoration.underline,
                      )  ,
                    ),onTap: () {Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginScreen()),);},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


