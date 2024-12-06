import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(26, 34, 56, 1),
          elevation: 6.0,
          selectedIconTheme: IconThemeData(
            color: Colors.greenAccent,
          ),
          unselectedIconTheme: IconThemeData(
            color: Colors.black,
          ),
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,

        ),
      ),
       home: const Auth(),

    );
  }
}
