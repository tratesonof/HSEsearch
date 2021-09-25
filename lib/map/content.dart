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

  static final CameraPosition initialCameraPos =
      const CameraPosition(target: LatLng(55.75222, 37.61556), zoom: 16);

  late Marker tappedMarker;

  bool _isAddingPin = false;

  late LatLng screenCoords;

  //Variable to get users permissions
  Location location = Location();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _markers =
      FirebaseFirestore.instance.collection('markers');

  final inputDescriptionController = TextEditingController();

  Future<void> addMarker(LatLng location, String description) {
    // Call the user's CollectionReference to add a new user
    return _markers.add({
      'Description': description,
      // John Doe
      'LatLng': GeoPoint(location.latitude, location.longitude),
      // Stokes and Sons
      'Name': 'St. Petersburg',
      // 42
    });
  }

  void addPin(LatLng location, String description) {
    addMarker(location, description);
    setState(() => _isAddingPin = false);
  }

  Future<void> removeMarker(
    MarkerId markerId,
  ) {
    // Call the user's CollectionReference to remove user
    return _markers.doc(markerId.value).delete();
  }

  final emailController = TextEditingController();


  void _showBottomSheet(String description, MarkerId markerId) {

    final phoneNumberController = TextEditingController();
    final universityController = TextEditingController();
    final descriptionController = TextEditingController();

    phoneNumberController.text = '89268641850';
    universityController.text = 'Высшая Школа Экономики';
    descriptionController.text = description;

    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Column(
            children: [
              TextFormField(
                controller: emailController,
                maxLength: 64,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.person)),
                  labelText: 'Почта',
                  counterText: '',
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
                enabled: false,
              ),
              TextFormField(
                controller: phoneNumberController,
                maxLength: 64,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.phone),
                  ),
                  labelText: 'Телефон',
                  counterText: '',
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
                enabled: false,
              ),
              TextFormField(
                controller: universityController,
                maxLength: 64,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.account_balance),
                  ),
                  labelText: 'Университет',
                  counterText: '',
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
                enabled: false,
              ),
              TextFormField(
                controller: descriptionController,
                maxLength: 64,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.info),
                  ),
                  labelText: 'Описание',
                  counterText: '',
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
                enabled: true,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        removeMarker(markerId);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text(
                      'Удалить маркер',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text('Добавьте описание к метке...'),
          content: TextFormField(
            controller: inputDescriptionController,
            maxLength: 256,
            maxLines: null,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                addPin(screenCoords, inputDescriptionController.text);
                setState(() {
                  emailController.text = 'example@yandex.ru';
                  inputDescriptionController.text = '';
                });
              },
              child: const Text('Подтвердить'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                inputDescriptionController.text = '';
              },
              child: const Text('Отменить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                    screenCoords = LatLng(cameraPosition.target.latitude,
                        cameraPosition.target.longitude);
                  });
                },
                markers: snapshot.data!.docs.map((DocumentSnapshot document) {
                  var docs = document.data() as Map<String, dynamic>;
                  return Marker(
                    position: LatLng((docs['LatLng'] as GeoPoint).latitude,
                        (docs['LatLng'] as GeoPoint).longitude),
                    markerId: MarkerId(document.id),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                    onTap: () {
                      _showBottomSheet(
                          docs['Description'], MarkerId(document.id));
                    },
                  );
                }).toSet(),
                initialCameraPosition: initialCameraPos,
                onMapCreated: (GoogleMapController controller) async {
                  _controllerCompleter.complete(controller);
                  _mapController = controller;
                  emailController.text = 'student@yandex.ru';

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

                  try {
                    final position = await geo.Geolocator.getCurrentPosition(
                      desiredAccuracy: geo.LocationAccuracy.high,
                    );
                    final latLng =
                        LatLng(position.latitude, position.longitude);

                    setState(() {
                      screenCoords = latLng;
                    });

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
              );
            },
          ),
          floatingActionButton: _isAddingPin
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: TextButton.icon(
                            onPressed: () async {
                              try {
                                final position =
                                    await geo.Geolocator.getCurrentPosition(
                                  desiredAccuracy: geo.LocationAccuracy.high,
                                );
                                final latLng = LatLng(
                                    position.latitude, position.longitude);

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
                            label: const Text('Моя позиция'),
                            icon: const Icon(Icons.gps_fixed),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: TextButton.icon(
                                label: const Text('Подтвердить'),
                                icon: const Icon(Icons.check),
                                onPressed: _showDialog,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: TextButton.icon(
                                  label: const Text('Отменить'),
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _isAddingPin = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: TextButton.icon(
                            onPressed: () async {
                              try {
                                final position =
                                    await geo.Geolocator.getCurrentPosition(
                                  desiredAccuracy: geo.LocationAccuracy.high,
                                );
                                final latLng = LatLng(
                                    position.latitude, position.longitude);

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
                            label: const Text('Моя позиция'),
                            icon: const Icon(Icons.gps_fixed),
                          ),
                        ),
                      ),
                      Padding(
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
                            label: const Text('Добавить маркер'),
                            icon: const Icon(Icons.add_location_alt_rounded),
                          ),
                        ),
                      ),
                    ],
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

class CustomMarker {
  CustomMarker(this.marker, this.description);

  final Marker marker;
  final String description;
}
