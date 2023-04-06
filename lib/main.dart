import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orpheus_client/Screens/login/login.dart';
import 'package:orpheus_client/Screens/main/home/search.dart';
import 'storage/credentials.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/Screens/main/home/navigation.dart';
import 'package:orpheus_client/Screens/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelName: "com.ryanheise.bg_demo.channel.audio",
    androidNotificationChannelDescription: "orpheus",
    androidNotificationOngoing: true,
    androidNotificationIcon: "mipmap/ic_launcher",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Orpheus",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Noto Sans JP",
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeSelector(),
        '/login': (context) => LoginScreen(),
        '/navigation': (context) => const NavigationScreen(),
      },
    );
  }
}

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return const NavigationScreen();
            }
            return LoginScreen();
          }
          // TODO: show splash screen
          return Text("loading");
        });
  }
}
