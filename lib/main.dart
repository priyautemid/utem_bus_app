import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:utembusapp/driver/RouteHopOnCampus/route_1.dart';
import 'package:utembusapp/driver/RouteHopOnCampus/route_2.dart';
import 'package:utembusapp/screens/login.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(apiKey: "AIzaSyA5B2bQwFcVAdMLLsqjYV9zKDf666FqNFg", appId: "1:1044759238826:android:67838c50841657aa2918d3", messagingSenderId: "1044759238826", projectId: "quickutembusapp")
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget{

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: route_2(),
    );
  }
}

