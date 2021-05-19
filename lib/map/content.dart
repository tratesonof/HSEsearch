import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hse_search/base/loading.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition initialCameraPos = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  //Variable to get users permissions
  Location location = Location();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _markers =
      FirebaseFirestore.instance.collection('markers');

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
    addMarker(screenCoords);
    setState(() {
      addingPin = false;
    });
  }

  Future<void> removeMarker(Marker marker) {
    // Call the user's CollectionReference to remove user
    return _markers.doc(marker.markerId.value).delete();
  }

  bool addingPin = false;

  late LatLng screenCoords;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: _markers.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              return GoogleMap(
                onCameraMove: (CameraPosition cameraPosition) {
                  setState(() {
                    screenCoords = LatLng(cameraPosition.target.latitude,
                        cameraPosition.target.longitude);
                  });
                },
                onTap: addingPin ? addPin : (LatLng location) {},
                markers: snapshot.data!.docs.map((DocumentSnapshot document) {
                  var docs = document.data() as Map<String, dynamic>;
                  return Marker(
                    position: LatLng((docs['LatLng'] as GeoPoint).latitude,
                        (docs['LatLng'] as GeoPoint).longitude),
                    markerId: MarkerId(document.id),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  );
                }).toSet(),
                initialCameraPosition: initialCameraPos,
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);

                  bool _serviceEnabled;
                  PermissionStatus _permissionGranted;

                  _serviceEnabled = await location.serviceEnabled();
                  if (!_serviceEnabled) {
                    _serviceEnabled = await location.requestService();
                    if (!_serviceEnabled) {
                      return;
                    }
                  }

                  _permissionGranted = await location.hasPermission();
                  if (_permissionGranted == PermissionStatus.denied) {
                    _permissionGranted = await location.requestPermission();
                    if (_permissionGranted != PermissionStatus.granted) {
                      return;
                    }
                  }
                },
              );
            },
          ),
          floatingActionButton: addingPin
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: FloatingActionButton.extended(
                      label: const Text('Cancel'),
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () {
                        setState(() {
                          addingPin = false;
                        });
                      },
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        setState(() {
                          addingPin = true;
                        });
                      },
                      label: const Text('Add a pin'),
                      icon: const Icon(Icons.directions_boat),
                    ),
                  ),
                ),
        ),
        addingPin
            ? Center(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: SvgPicture.asset(
                      'assets/svg/ic_add_marker_pointer.svg',
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _goToTheLake() async {
    final controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(initialCameraPos));
  }
}
