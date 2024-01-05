import 'dart:async';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_map_polyline_point/flutter_polyline_point.dart';
import 'package:flutter_google_map_polyline_point/point_lat_lng.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class route_1 extends StatefulWidget {
  @override
  _Maps createState() => _Maps();
}

class _Maps extends State<route_1> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
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
                      subtitle: Row(
                        children: [
                          Text(snapshot.data!.docs[index]['latitude'].toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text(snapshot.data!.docs[index]['longitude'].toString()),
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

  _getLocation() async {
    try {
      // Check if the user is authenticated
      if (FirebaseAuth.instance.currentUser != null) {
        // Get the current user's UID
        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Get the current location
        final loc.LocationData _locationResult = await location.getLocation();

        // Update the location data in Firestore
        await FirebaseFirestore.instance.collection('location').doc(uid).set({
          'latitude': _locationResult.latitude,
          'longitude': _locationResult.longitude,
        }, SetOptions(merge: true));
      } else {
        print('User not authenticated.');
        // Handle the case where the user is not authenticated
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error: $e');
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
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection('location').doc(uid).set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Permission Granted');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}

class MyMap extends StatefulWidget {
  final String user_id;

  MyMap(this.user_id);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<Polyline> _polylines = [];
  List<LatLng> destinations = [
    LatLng(2.3087512637914207, 102.3191728618355),
    LatLng(2.3112621141142173, 102.31818409888656),
    LatLng(2.3093236407053785, 102.31896097668674),
    LatLng(2.3088050129260327, 102.32120161895827),
  ];

  int currentDestinationIndex = 0;

  loc.LocationData? userLocation;

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _addUserMarker();
    _getLocation();
    _calculateAllPolylines(); // Calculate all routes initially
    if (userLocation != null && currentDestinationIndex < destinations.length) {
      final destination = destinations[currentDestinationIndex];
    }
  }

  Future<void> _calculateAllPolylines() async {
    for (int i = 0; i < destinations.length; i++) {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyBp5YLiQ4DGhWeqALksEFsHlRT-V9ZiE1Q',
        PointLatLng(userLocation!.latitude!, userLocation!.longitude!),
        PointLatLng(destinations[i].latitude, destinations[i].longitude),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("route$i"),
            points: result.points.map((point) =>
                LatLng(point.latitude, point.longitude)).toList(),
            color: Colors.indigo.withOpacity(0.9), // Adjust color as needed
            width: 4,
          ));
        });
      }
    }
  }

  Future<void> _addMarkers() async {
    // Obtain the BitmapDescriptor by awaiting the completion of fromAssetImage
    BitmapDescriptor destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/bus_stop.png",
    );

    setState(() {
      _markers = destinations
          .map(
            (latLng) => Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          icon: destinationIcon,
        ),
      )
          .toSet();
    });
  }

  void _getLocation() async {
    loc.Location location = loc.Location();
    userLocation = await location.getLocation();
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(userLocation!.latitude!, userLocation!.longitude!),
          zoom: 18.98,
        ),
      ),
    );
    _addUserMarker();

    _calculateAllPolylines();
  }



  void _addUserMarker() async {
    if (userLocation != null) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;

        DatabaseReference userRef = FirebaseDatabase.instance
            .reference()
            .child('location')
            .child(uid)
            .child('bus_capacity');

        Completer<DataSnapshot> completer = Completer<DataSnapshot>();

        userRef.onValue.listen((event) {
          completer.complete(event.snapshot);
        });

        DataSnapshot snapshot = await completer.future;

        int? capacity = snapshot.value as int?;
        capacity ??= 0;

        // Obtain the BitmapDescriptor by awaiting the completion of fromAssetImage
        BitmapDescriptor userIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(),"assets/busiconmarker.png");

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId('user'),
              position: LatLng(userLocation!.latitude!, userLocation!.longitude!),
              icon: userIcon, // Use the obtained BitmapDescriptor
              infoWindow: InfoWindow(
                title: 'BLW 7273',
                snippet: 'Capacity: $capacity',
              ),
              anchor: Offset(0.5, 0.5),
            ),
          );
        });
      } catch (e) {
        print('Error adding user marker: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hop On Campus Live Bus Tracker'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
              userLocation?.latitude ?? 0, userLocation?.longitude ?? 0),
          zoom: 18.98,
        ),
        markers: _markers,
        polylines: _polylines.toSet(),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _controller = controller;
          });
        },
      ),
    );
  }
}