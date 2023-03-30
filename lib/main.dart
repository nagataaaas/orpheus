import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/login/login.dart';
import 'package:orpheus_client/Screens/main/home/search.dart';
import 'storage/credentials.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/Screens/main/home/navigation.dart';
import 'package:orpheus_client/Screens/navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Orpheus Client",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Noto Sans JP",
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeSelector(),
        '/login': (context) => LoginScreen(),
        '/navigation': (context) => NavigationScreen(),
      },
    );
  }
}

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    isLoggedIn().then((value) {
      print("value: $value");
    });
    return FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          isLoggedIn().then((value) {
            print("value: $value");
          });
          print("snapshot: ${snapshot.data}");
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return NavigationScreen();
            }
            return LoginScreen();
          }
          // TODO: show splash screen
          return Text("loading");
        });
  }
}
