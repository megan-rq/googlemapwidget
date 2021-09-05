import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng SOURCE_LOCATION = LatLng(15.133657810561163, 120.58983928902136);
const LatLng DEST_LOCATION = LatLng(15.140356637384908, 120.59406605833263);
const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

Set<Polyline> _polylines = Set<Polyline>();
List<LatLng> polylineCoordinates = [];
late PolylinePoints polylinePoints;

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  Set<Marker> _markers = Set<Marker>();
  late LatLng currentLocation;
  late LatLng destinationLocation;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    //set up initial locations
    this.setInitialLocation();

    //set up the marker icon
    this.setSourceAndDEstinationLocationMarkerIcons();
  }

  void setSourceAndDEstinationLocationMarkerIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'assets/origin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'assets/destination.png');
  }

  void setInitialLocation() {
    currentLocation =
        LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
    destinationLocation =
        LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude);
  }

  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);

    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
            child: GoogleMap(
          myLocationEnabled: true,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          zoomControlsEnabled: false,
          polylines: _polylines,
          markers: _markers,
          mapType: MapType.terrain,
          initialCameraPosition: initialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);

            showPinsOnMap();
            setPolylines();
          },
        )),
        Positioned(top: 100, left: 0, right: 0, child: MapUserBadge()),
        Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(15),
                color: Colors.white,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipOval(
                          child: Image.asset('assets/emergency.png',
                              width: 60, height: 60, fit: BoxFit.cover),
                        )
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("NAME OF STATION",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text('Address'),
                          Text('Distance',
                              style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                    Icon(Icons.location_pin, color: Colors.red, size: 50)
                  ],
                )))
      ],
    ));
  }

  void showPinsOnMap() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: currentLocation,
          icon: sourceIcon));
      _markers.add(Marker(
          markerId: MarkerId('destinationPin'),
          position: destinationLocation,
          icon: destinationIcon));
    });
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyDmHM-IakxXdJqN59m-rYM-nBjQueCDam8",
        PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
        PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude));
    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 10,
            polylineId: PolylineId('Polyline'),
            color: Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }
}

class MapUserBadge extends StatelessWidget {
  const MapUserBadge({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset.zero)
            ]),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                      image: AssetImage('assets/user.png'), fit: BoxFit.cover),
                  border: Border.all(color: Colors.green)),
            ),
            SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('YOUR NAME',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('CURRENT LOCATION', style: TextStyle(color: Colors.grey))
                ])),
            Icon(Icons.location_pin, color: Colors.green, size: 40)
          ],
        ));
  }
}
