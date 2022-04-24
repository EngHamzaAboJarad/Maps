import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Set<Marker> marker = <Marker>[].toSet();
  Set<Circle> circle = <Circle>[].toSet();
  Set<Polyline> polyline = <Polyline>[].toSet();
  late GoogleMapController _googleMapController;
  Location _location = Location();

  //target:عبارة عن خط الطول وخط العرض
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(31.486380, 34.431198),
    zoom: 16,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Maps'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  await permatin();
                },
                icon: Icon(Icons.location_on))
          ],
        ),
        body: GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onLongPress: (LatLng l) {
            addCircle(l);
            _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: l, zoom: 50)));
          },
          // موقع الكاميرا الاساسي الي راح تستخدمو في عملية الانشاء
          initialCameraPosition: _cameraPosition,
          onMapCreated: (GoogleMapController co) {
            setState(() {
              _googleMapController = co;
            });
            _location.onLocationChanged.listen((event) {
              var l = event.latitude;
              var g  = event.longitude;
              _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: LatLng(l!,g!),
                    zoom: 18
                  )));
            });
          },
          //لاظهار المعالم الجغرافية
          mapType: MapType.hybrid,
          onTap: (LatLng laln) {
            // log('latitude => ${laln.latitude}');
            // log('longitude => ${laln.longitude}');
            log('longitude => $laln');
            addMarker(laln);
            _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: laln, zoom: 16)));
            addPolyLine();
          },
          markers: marker,
          circles: circle,
          polylines: polyline,
        ),
      ),
    );
  }

  void addMarker(LatLng latLng) {
    Marker _ma = Marker(
        markerId: MarkerId('marker_${marker.length}'),
        position: latLng,
        infoWindow: InfoWindow(
          title: 'Marker Title - Gaza',
          snippet: 'Marker Snippet - Gaza',
        ));
    setState(() {
      marker.add(_ma);
    });
  }

  void addCircle(LatLng l) {
    Circle c = Circle(
        circleId: CircleId('Circle_${circle.length}'),
        center: l,
        consumeTapEvents: true,
        fillColor: Colors.green,
        strokeColor: Colors.blue,
        visible: true,
        zIndex: 2,
        radius: 2,
        strokeWidth: 1);
    setState(() {
      circle.add(c);
    });
  }

  void addPolyLine() {
    polyline.clear();
    Polyline po = Polyline(
        polylineId: PolylineId('polyline${polyline.length}'),
        points: [
          LatLng(31.4855804406842, 34.4319761171937),
          LatLng(31.48819079881503, 34.42872125655413),
          LatLng(31.48840865892751, 34.431204311549656),
          LatLng(31.48825598535858, 34.43191912025213),
        ],
        jointType: JointType.round,
        color: Colors.black,
        width: 10,
        startCap: Cap.squareCap,
        endCap: Cap.squareCap);
    setState(() {
      polyline.add(po);
    });
  }

  Future<void> permatin() async {
    var permission = await Permission.locationWhenInUse.request();
    if (permission.isGranted) {
      //تم المنح
    } else if (permission.isRestricted) {
      // تم منعها من النظام نفسو

    } else if (permission.isDenied) {
      //تم رفضها من اليوزر
    } else if (permission.isPermanentlyDenied) {
      //موجودة في الاندرويد اذا رفضها لازم يروح من الاعدادات من الجهاز
    }
  }
}
