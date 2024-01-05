import 'package:flutter/material.dart';
import 'package:utembusapp/driver/RouteHopOnCampus/route_1.dart';
import 'package:utembusapp/driver/RouteHopOnCampus/route_2.dart';

class HopOnCampusMainScreen extends StatefulWidget {
  const HopOnCampusMainScreen({super.key});

  @override
  State<HopOnCampusMainScreen> createState() => _HopOnCampusMainScreen();
}

class _HopOnCampusMainScreen extends State<HopOnCampusMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hop On Campus Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => route_1()),
                );
              },
              child: Text('Al-Jazari > Lestari > Satria > KI '),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => route_2()),
                );
              },
              child: Text('KI > Satria > Lestari > Al-Jazari'),
            ),
          ],
        ),
      ),
    );
  }
}