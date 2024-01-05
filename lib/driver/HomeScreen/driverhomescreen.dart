import 'package:flutter/material.dart';
import 'package:utembusapp/driver/RouteHopOnCampus/HopOnCampusScreen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HopOnCampusMainScreen()),
                );
              },
              child: Text('Hop On Campus'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KampusTeknologiPage()),
                );
              },
              child: Text('Kampus Teknologi'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KediamanLuarPage()),
                );
              },
              child: Text('Kediaman Luar'),
            ),
          ],
        ),
      ),
    );
  }
}

class HopOnCampusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hop On Campus Page'),
      ),
      body: Center(
        child: Text('Content for Hop On Campus Page'),
      ),
    );
  }
}

class KampusTeknologiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kampus Teknologi Page'),
      ),
      body: Center(
        child: Text('Content for Kampus Teknologi Page'),
      ),
    );
  }
}

class KediamanLuarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kediaman Luar Page'),
      ),
      body: Center(
        child: Text('Content for Kediaman Luar Page'),
      ),
    );
  }
}
