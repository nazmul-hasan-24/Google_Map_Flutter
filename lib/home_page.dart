import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_project/key.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Location _locationController = Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng lakshmipur = LatLng(22.9454623406675, 90.83181738853455);
  static const LatLng dalalBazar =
      LatLng(22.967591577256044, 90.80768655985594);
  Set<Polyline> polylines = {};
  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    getLocationUpdate();
    getPolylinePoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real Time Location Tracker"),
        backgroundColor: Colors.indigo,
      ),
      body: currentPosition == null
          ? const Center(
              child: Text("Loading...."),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  _mapController.complete(controller),
              initialCameraPosition: const CameraPosition(
                  target: lakshmipur, zoom: 17), // Initial position
              mapType: MapType.normal,
              myLocationEnabled: true,
              
              markers: {
                 Marker(
                  markerId: const MarkerId("curent position"),
                  infoWindow:  InfoWindow(
                    title: "My current location",
                     snippet:  ( '${currentPosition!.latitude} ${currentPosition!.longitude}' ),
                    
                  ),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentPosition!
                )
              },
              
              polylines: {
                Polyline(
                  
                  polylineId: const PolylineId('current'),
                  endCap: Cap.customCapFromBitmap(BitmapDescriptor.defaultMarker),
                  points: [
                     LatLng(currentPosition!.latitude, currentPosition!.longitude),
                    const  LatLng(22.925877973754034, 90.76823059469461),
                  ]
                ),
              },
          
            ),
    );
  }

  Future<void> cameraPosition(LatLng pos) async {
    GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<void> getLocationUpdate() async {
    PermissionStatus permissionGranted;
    bool serviseEnable = await _locationController.serviceEnabled();
    if (serviseEnable) {
      serviseEnable = await _locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen(
      (LocationData curentLocation) {
        if ((curentLocation.latitude != null) &&
            (curentLocation.longitude != null)) {
          setState(
            () {
              currentPosition =
                  LatLng(curentLocation.latitude!, curentLocation.longitude!);
              cameraPosition(currentPosition!);
              Timer.periodic(const Duration(seconds: 10), (timer) {
                currentPosition =
                    LatLng(curentLocation.latitude!, curentLocation.longitude!);
              });
            },
          );
        }
      },
    );
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polyLineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(lakshmipur.latitude, lakshmipur.longitude),
      PointLatLng(dalalBazar.latitude, dalalBazar.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polyLineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    } else {
  
    }
    return polyLineCoordinates;
  }

  void generatePolyLineFromPoints(LatLng newPosition) async {
    currentPosition = newPosition;
    if (polylines.isNotEmpty) {
      final previousPolyline = polylines.first;
      final updatePolyline = previousPolyline.copyWith(pointsParam: [
        ...previousPolyline.points,
        currentPosition as LatLng,
      ]);
      setState(() {
        polylines.remove(previousPolyline);
        polylines.add(updatePolyline);
      });
    } else {
      polylines.add(
        Polyline(
            polylineId: const PolylineId("polyline"),
            color: Colors.indigo,
            width: 6,
            points: [currentPosition] as List<LatLng>),
      );
    }
  }
}
///90:35:4B:30:30:86:B9:73:AB:C9:23:61:37:19:21:AE:56:50:69:A3
/////com.example.google_map_project
///com.example.google_map_project