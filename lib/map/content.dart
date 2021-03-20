import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  YandexMapController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YandexMap(
        onMapCreated: (YandexMapController yandexMapController) async {
          controller = yandexMapController;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }
}
