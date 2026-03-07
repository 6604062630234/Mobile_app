import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'homepage.dart';
import 'add_schedule.dart';
import 'profile.dart'; 
import 'manage.dart';
import 'edit.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {

  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'My Schedule',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      initialRoute: isLoggedIn ? '/homepage' : '/login',

      routes: {

        '/login': (context) => const LoginPage(),

        '/homepage': (context) => const MyHomePage(title: 'My Schedule'),

        '/add': (context) => const AddSchedulePage(),

        '/profile': (context) => const ProfilePage(),

        '/manage': (context) => const ManagePage(),

        '/edit': (context) => const EditPage(),

      },
    );
  }
}