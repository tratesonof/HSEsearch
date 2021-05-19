import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  late GoogleMapController _mapController;

  static final CameraPosition initialCameraPos = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  //Variable to get users permissions
  Location location = Location();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _markers = FirebaseFirestore.instance.collection('markers');

  Future<void> addMarker(LatLng location) {
    // Call the user's CollectionReference to add a new user
    return _markers.add({
      'Description': 'Second capital of Russia',
      // John Doe
      'LatLng': GeoPoint(location.latitude, location.longitude),
      // Stokes and Sons
      'Name': 'St. Petersburg',
      // 42
    });
  }

  void addPin(LatLng location) {
    addMarker(location);
    setState(() => _isAddingPin = false);
  }

  Future<void> removeMarker(Marker marker) {
    // Call the user's CollectionReference to remove user
    return _markers.doc(marker.markerId.value).delete();
  }

  bool _isAddingPin = false;

  late LatLng screenCoords;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () async {
                try {
                  final position = await geo.Geolocator.getCurrentPosition(
                    desiredAccuracy: geo.LocationAccuracy.high,
                  );
                  final latLng = LatLng(position.latitude, position.longitude);

                  await _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: latLng,
                        zoom: 16,
                      ),
                    ),
                  );
                } on Exception catch (_) {}
              },
              child: SvgPicture.asset('assets/svg/ic_gsp.svg'),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _markers.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              return GoogleMap(
                zoomControlsEnabled: false,
                onCameraMove: (CameraPosition cameraPosition) {
                  setState(() {
                    screenCoords = LatLng(cameraPosition.target.latitude, cameraPosition.target.longitude);
                  });
                },
                markers: snapshot.data!.docs.map((DocumentSnapshot document) {
                  var docs = document.data() as Map<String, dynamic>;
                  return Marker(
                    position: LatLng((docs['LatLng'] as GeoPoint).latitude, (docs['LatLng'] as GeoPoint).longitude),
                    markerId: MarkerId(document.id),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  );
                }).toSet(),
                initialCameraPosition: initialCameraPos,
                onMapCreated: (GoogleMapController controller) async {
                  _controllerCompleter.complete(controller);
                  _mapController = controller;

                  bool isServiceEnabled;
                  PermissionStatus isPermissionGranted;

                  isServiceEnabled = await location.serviceEnabled();
                  if (!isServiceEnabled) {
                    isServiceEnabled = await location.requestService();
                    if (!isServiceEnabled) {
                      return;
                    }
                  }

                  isPermissionGranted = await location.hasPermission();
                  if (isPermissionGranted == PermissionStatus.denied) {
                    isPermissionGranted = await location.requestPermission();
                    if (isPermissionGranted != PermissionStatus.granted) {
                      return;
                    }
                  }
                },
              );
            },
          ),
          floatingActionButton: _isAddingPin
              ? Column(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: FloatingActionButton.extended(
                        label: const Text('Confirm'),
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          addPin(screenCoords);
                        },
                      ),
                    ),
                  ),
                ],
              )
              : Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() => _isAddingPin = true);
                        },
                        label: const Text('Add a pin'),
                        icon: const Icon(Icons.directions_boat),
                      ),
                    ),
                  ),
                ),
        ),
        if (_isAddingPin)
          IgnorePointer(
            ignoring: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg/ic_add_marker_pointer.svg',
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
