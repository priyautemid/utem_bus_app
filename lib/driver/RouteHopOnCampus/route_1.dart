import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_google_map_polyline_point/flutter_polyline_point.dart';
import 'package:flutter_google_map_polyline_point/point_lat_lng.dart';
import 'package:flutter_google_map_polyline_point/utils/polyline_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class route_1 extends StatefulWidget {
  @override
  _Maps createState() => _Maps();
}

class _Maps extends State<route_1> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracker'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              _getLocation();
            },
            child: Text('Add My Location'),
          ),
          TextButton(
            onPressed: () {
              _listenLocation();
            },
            child: Text('Enable Live Location'),
          ),
          TextButton(
            onPressed: () {
              _stopListening();
            },
            child: Text('Stop Live Location'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('location').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Latitude: ${snapshot.data!.docs[index]['latitude']}'),
                          Text('Longitude: ${snapshot.data!.docs[index]['longitude']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyMap(snapshot.data!.docs[index].id)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final loc.LocationData _locationResult = await location.getLocation();
        await FirebaseFirestore.instance
            .collection('location')
            .doc(_user.uid)
            .set({
          'latitude': _locationResult.latitude,
          'longitude': _locationResult.longitude,
        }, SetOptions(merge: true));
      } catch (e) {
        print(e);
      }
    } else {
      print('Location permission denied');
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(_user.uid)
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      }, SetOptions(merge: true));
    });
  }

  void _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }
}

class MyMap extends StatefulWidget {
  final String user_id;

  MyMap(this.user_id);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  GoogleMapController? _controller;
  Set<Marker> _markers = Set<Marker>();
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline _polyline = Polyline(polylineId: PolylineId("default"));
  List<LatLng> destinations = [];

  int currentDestinationIndex = 0;

  loc.LocationData? userLocation;
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _addMarkers() {
    setState(() {
      _markers = destinations
          .map(
            (latLng) => Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          ),
        ),
      )
          .toSet();
    });
  }

  Future<void> _calculatePolyline() async {
    if (userLocation != null && currentDestinationIndex < destinations.length) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyBp5YLiQ4DGhWeqALksEFsHlRT-V9ZiE1Q',
        PointLatLng(userLocation!.latitude!, userLocation!.longitude!),
        PointLatLng(destinations[currentDestinationIndex].latitude, destinations[currentDestinationIndex].longitude),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          _polyline = Polyline(
            polylineId: PolylineId("route$currentDestinationIndex"),
            points: result.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
            color: const Color(0xFF7B61FF),
            width: 6,
          );
        });
      }
    }
  }

  void _getLocation() async {
    loc.Location location = loc.Location();
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) {
      setState(() {
        userLocation = currentlocation;
        destinations = [
          LatLng(userLocation!.latitude!, userLocation!.longitude!), // User's location
          LatLng(2.3210884, 102.3287684), // Al Jazari
          LatLng(2.314922981129919, 102.3163238914054), // Lestari
          LatLng(2.3101113649921374, 102.31445255130075), // Satria
        ];

        if (_markers.isEmpty) {
          _addMarkers();
        }

        if (_polyline.points.isEmpty) {
          _calculatePolyline();
        }
      });
    });
  }


  void _addUserMarker() {
    if (userLocation != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('user'),
            position: LatLng(userLocation!.latitude!, userLocation!.longitude!),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Bus Tracker'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: destinations.isNotEmpty ? destinations[0] : LatLng(0, 0),
          zoom: 18.98,
        ),
        markers: _markers,
        polylines: {
          if (_polyline.points.isNotEmpty) _polyline,
        },
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _controller = controller;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (currentDestinationIndex < destinations.length - 1) {
              currentDestinationIndex++;
              _calculatePolyline();
            }
          });
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
