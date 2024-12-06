import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Home_Screen.dart';
import 'package:podwave/screens/Signup_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isuploading = false;
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();


  Future logIn() async {
    if(_emailcontroller.text.isEmpty || _passwordcontroller.text.isEmpty){warning("You must fill every everything");}
    else{
    try {
      setState(() {
        _isuploading = true;
      });
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );
      setState(() {
        _isuploading = false;
      });
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen()),);
    }on FirebaseAuthException catch (e) {
      setState(() {
        _isuploading = false;
      });
      print(e.code);
      if (e.code == 'user-not-found'){
        warning('Invalid Email');
      }
      if (e.code == 'wrong-password'){
        warning('Invalid password');
      }
      else{
        warning(e.code);
      }
    }
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

  @override
  void dispose(){
    super.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
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
                      offset: const Offset(0,-120),
                      child: Text(
                         'Welcome to Pod Wave',
                         style: GoogleFonts.irishGrover(
                             fontSize: 30,color: Colors.white
                         ),
                   ),
                    ),
                   Transform.translate(
                     offset: const Offset(-120,-70),
                     child: const Text(
                      'Email',
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
                            controller: _emailcontroller,
                            style: TextStyle(fontSize: 20),
                            decoration: const InputDecoration(
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
                    offset: const Offset(-100,-30),
                    child: const Text(
                      'Password',
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: 20
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0,-20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child:  TextField(
                          obscureText: _obscureText,
                          controller: _passwordcontroller,
                          style: TextStyle(fontSize: 20),
                          decoration:  InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: GestureDetector(
                      onTap: logIn,
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
                              'Log in',
                              style: GoogleFonts.itim(fontSize: 25),
                            ),
                            const Icon(Icons.arrow_forward_sharp),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(offset: Offset(90, -5),
                    child: TextButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailcontroller.text);
                          // Password reset email sent successfully
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Password Reset'),
                              content: Text('A password reset email has been sent to your email address.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          // Handle any errors that occurred during the process
                          print('Error sending password reset email: $e');
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text('$e'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Text('Forgot Password?',style: GoogleFonts.itim(color: Colors.greenAccent,fontSize: 17)),
                    ),
                  ),

                  GestureDetector(
                    child: Text(
                      'New user ?',
                      style: GoogleFonts.itim(
                        color: Colors.greenAccent,
                        fontSize: 25,
                        decoration: TextDecoration.underline,
                      )  ,
                    ),
                    onTap: () {Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => SignupScreen()),);},
                  ),
                  const SizedBox(height: 35),
                  Text(
                      'Riding the wave of\n  audio adventure',
                      style: GoogleFonts.irishGrover(
                          fontSize: 35,color: Colors.purple
                      )
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


