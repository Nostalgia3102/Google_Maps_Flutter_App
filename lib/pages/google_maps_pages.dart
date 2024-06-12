import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location/location.dart';

import '../components/alertDialog.dart';
import '../constants.dart';
import '../models/koi_class.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();
  bool modalSheetOpen = false;
  GoogleMapController? mapController;
  int _selectedIndex = 0;
  bool stateChanged = false;
  bool savedSheetOpen = false;

  static const fortisHospital = LatLng(30.67995, 76.72211);
  static const bestechMall = LatLng(30.6737072, 76.740323);

  LatLng? currentPosition;
  Map<PolylineId, Polyline> polylines = {};
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Set<Marker> _markersSetGreen = {};
  final Set<Marker> _markersSetOrange = {};
  final Set<Marker> _markersSetPink = {};
  final Set<Marker> _markersSet = {};
  final List<LatLng> _markerPositionsList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> loadMarkersFromBox() async {
    var box = await Hive.openBox('testBox');

    if (box.get('type_green') != null) {
      debugPrint("I am green");
      Set<Marker> s = retrieveMarkers('type_green');
      for (Marker m in s) {
        _markersSetGreen.add(m);
      }
    }

    if (box.get('type_orange') != null) {
      debugPrint("I am orange");
      Set<Marker> ss = retrieveMarkers('type_orange');
      for (Marker m in ss) {
        _markersSetOrange.add(m);
      }
    }

    if (box.get('type_pink') != null) {
      debugPrint("I am pink");
      Set<Marker> sss = retrieveMarkers('type_pink');
      for (Marker m in sss) {
        _markersSetPink.add(m);
      }
    }

    setState(() {
      // Combining all markers into the main set
      _markersSet.addAll(_markersSetGreen);
      _markersSet.addAll(_markersSetOrange);
      _markersSet.addAll(_markersSetPink);
    });

    for(Marker m in _markersSet){
      _markerPositionsList.add(m.position);
    }
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
    await loadMarkersFromBox();
    // final coordinates = await fetchPolylinePoints();
    // generatePolyLineFromPoints(coordinates);
  }

  void _onItemTapped(int index) {
    if (modalSheetOpen && index != 1) {
      modalSheetOpen = !modalSheetOpen;
      Navigator.pop(context);
    }
    if (index == 1) {
      scaffoldKey.currentState!.showBottomSheet((context) {
        modalSheetOpen = !modalSheetOpen;
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                      child: ElevatedButton(
                        child: const Text('X'),
                        onPressed: () {
                          modalSheetOpen = !modalSheetOpen;
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const Text("Items selected are :"),
                Expanded(child: listViewed())
              ],
            ),
          ),
        );
      });
    }

    if (index == 2) {
      scaffoldKey.currentState!.showBottomSheet((context) {
        savedSheetOpen = !savedSheetOpen;
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                      child: ElevatedButton(
                        child: const Text('X'),
                        onPressed: () {
                          savedSheetOpen = !savedSheetOpen;
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const Text("Your Lists"),
                Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Set<Marker> updatedMarkers = _markersSetGreen.map((marker) {
                              return marker.copyWith(
                                iconParam: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                              );
                            }).toSet();

                            _markersSetGreen.clear();
                            _markersSetGreen.addAll(updatedMarkers);
                            _storeMarkers(_markersSetGreen, 'type_green');
                            retrieveMarkers('type_green');
                            setState(() {});
                          },
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.flag_outlined,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Want to go")
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Starred Places")
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.heart_broken,
                              color: Colors.pink,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Favourites")
                          ],
                        )
                      ]),
                )
              ],
            ),
          ),
        );
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void addMarker(LatLng latLong, String title, [List<bool>? list]) {
    final marker = Marker(
        markerId: MarkerId(latLong.toString()),
        position: latLong,
        infoWindow: InfoWindow(
            title: title,
            snippet: latLong.toString(),
            onTap: () => onMarkerTap(MarkerModel(
                  latitude: latLong.latitude,
                  longitude: latLong.longitude,
                  markerId: latLong.toString(),
                  title: title,
                ))),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow));

    debugPrint(marker.infoWindow.title);
    debugPrint(marker.infoWindow.snippet);

    //created temp markers for memory safe operation:
    Set<Marker> tempGreenMarkers = {..._markersSetGreen};
    Set<Marker> tempOrangeMarkers = {..._markersSetOrange};
    Set<Marker> tempPinkMarkers = {..._markersSetPink};
    Set<Marker> tempMarkers = {..._markersSet};

    if (list?[0] == true) {
      tempGreenMarkers.add(marker);
    }
    if (list?[1] == true) {
      tempOrangeMarkers.add(marker);
    }
    if (list?[2] == true) {
      tempPinkMarkers.add(marker);
    }

    tempMarkers.add(marker);
    _markerPositionsList.add(latLong);

    setState(() {
      // Assign the temporary sets to the state variables
      _markersSetGreen.clear();
      _markersSetGreen.addAll(tempGreenMarkers);
      _markersSetOrange.clear();
      _markersSetOrange.addAll(tempOrangeMarkers);
      _markersSetPink.clear();
      _markersSetPink.addAll(tempPinkMarkers);
      _markersSet.clear();
      _markersSet.addAll(tempMarkers);
    });

    //HIVE Storage:

    var box = Hive.box('testBox');

    //For Type Green :
    if (list?[0] == true) {
      _storeMarkers(_markersSetGreen, 'type_green');
      debugPrint('Green: ${box.get('type_green')}');
      Set<Marker> s = retrieveMarkers('type_green');
      debugPrint(s.length.toString());
    }

    // For Type Orange :
    if (list?[1] == true) {
      _storeMarkers(_markersSetOrange, 'type_orange');
      debugPrint('Orange: ${box.get('type_orange')}');
      Set<Marker> ss = retrieveMarkers('type_orange');
      debugPrint(ss.length.toString());
    }
    // For Type Pink:
    if (list?[2] == true) {
      _storeMarkers(_markersSetPink, 'type_pink');
      debugPrint('Pink: ${box.get('type_pink')}');
      Set<Marker> sss = retrieveMarkers('type_pink');
      debugPrint(sss.length.toString());
    }
  }

  void _alertDialog(LatLng latLng) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItemDialog(latLng: latLng, addMarker: addMarker);
      },
    );
  }

  Widget listViewed() {
    return ListView.builder(
        itemCount: _markerPositionsList.length,
        itemBuilder: (BuildContext context, int index) {
          debugPrint("ListView called");
          return ListTile(
            leading: const Icon(Icons.list),
            trailing: Text(_markerPositionsList[index].toString()),
          );
        });
  }

  void _storeMarkers(Set<Marker> markers, String key) {
    var box = Hive.box('testBox');
    List<MarkerModel> markerModels = markers.map((marker) {
      return MarkerModel.fromMarker(marker);
    }).toList();
    box.put(key, markerModels);
  }

  Set<Marker> retrieveMarkers(String key) {
    var box = Hive.box('testBox');
    List<dynamic>? markerModelsData = box.get(key);

    if (markerModelsData != null) {
      debugPrint("inside retrive markers");
      List<MarkerModel> markerModels = List<MarkerModel>.from(markerModelsData);
      Set<Marker> markers =
          markerModels.map((model) {
            return model.toMarker();
          }).toSet();

      // Print each marker
      for (Marker marker in markers) {
        debugPrint(
            "The value of marker is -> ${marker.markerId.value.toString()}");
        debugPrint("The value of marker is -> ${marker.markerId}");
        debugPrint("The value of marker is -> ${marker.icon.toString()}");
      }
      return markers;
    } else {
      debugPrint("else executed");
      return {};
    }
  }

  void onMarkerTap(MarkerModel markerModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(markerModel.title ?? 'No Title'),
          content: Text(
              'Lat: ${markerModel.latitude}, Lng: ${markerModel.longitude}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _markersSet.removeWhere((marker) =>
                      marker.markerId.value == markerModel.markerId);
                  _markersSetOrange.removeWhere((marker) =>
                      marker.markerId.value == markerModel.markerId);
                  _markersSetGreen.removeWhere((marker) =>
                      marker.markerId.value == markerModel.markerId);
                  _markersSetPink.removeWhere((marker) =>
                      marker.markerId.value == markerModel.markerId);

                  _storeMarkers(_markersSetOrange, 'type_orange');
                  _storeMarkers(_markersSetPink,
                      'type_pink'); // Update stored markers after deletion
                  _storeMarkers(_markersSetGreen,
                      'type_green'); // Update stored markers after deletion
                  // Update stored markers after deletion
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Google Maps App"),
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.topLeft,
              children: [
                GoogleMap(
                  //polyline maker :
                  onMapCreated: (GoogleMapController controller) async {
                    mapController = controller;
                    // _onMapCreated();
                  },
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 13,
                  ),
                  markers: _markersSet,
                  polylines: Set<Polyline>.of(polylines.values),
                  onLongPress: _alertDialog,
                ),
                const Row(
                  children: [Icon(Icons.horizontal_split_outlined)],
                ),
                // Center(
                //   child: _widgetOptions.elementAt(_selectedIndex),
                // )
              ],
            ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: FloatingActionButton.small(
          onPressed: _onFloatingButtonPressed,
          child: const Icon(Icons.my_location_rounded)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[300],
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final currentLocation = await locationController.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      setState(() {
        currentPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      });

      // Move the camera to the current position
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(currentPosition!));
      }
    }
  }

  Future<void> _onFloatingButtonPressed() async {
    await fetchLocationUpdates();
  }

  Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapsApiKey,
      PointLatLng(fortisHospital.latitude, fortisHospital.longitude),
      PointLatLng(bestechMall.latitude, bestechMall.longitude),
    );

    if (result.points.isNotEmpty) {
      final points = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      debugPrint("Polyline Points: $points");
      return points;
    } else {
      debugPrint("Polyline Error: ${result.errorMessage}");
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    if (polylineCoordinates.isNotEmpty) {
      const id = PolylineId('polyline');
      final polyline = Polyline(
        polylineId: id,
        color: Colors.blueAccent,
        points: polylineCoordinates,
        width: 5,
      );

      setState(() {
        polylines[id] = polyline;
      });

      // Adjust the camera to fit the polyline bounds
      // LatLngBounds bounds = _boundsFromLatLngList(polylineCoordinates);
      // mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(currentPosition!));
      }
    }
  }

  // LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
  //   assert(list.isNotEmpty);
  //   double x0 = list.first.latitude;
  //   double x1 = list.first.latitude;
  //   double y0 = list.first.longitude;
  //   double y1 = list.first.longitude;
  //   for (LatLng latLng in list) {
  //     if (latLng.latitude > x1) x1 = latLng.latitude;
  //     if (latLng.latitude < x0) x0 = latLng.latitude;
  //     if (latLng.longitude > y1) y1 = latLng.longitude;
  //     if (latLng.longitude < y0) y0 = latLng.longitude;
  //   }
  //   return LatLngBounds(
  //     northeast: LatLng(x1, y1),
  //     southwest: LatLng(x0, y0),
  //   );
  // }

  void _onMapCreated() async {
    final coordinates = await fetchPolylinePoints();
    await generatePolyLineFromPoints(coordinates);
  }

  Widget? itemView() {
    return Container();
  }
}

///////////////////////////////////////////
/*
markers: {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: currentPosition!,
                      ),
                      const Marker(
                        markerId: MarkerId('sourceLocation'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: fortisHospital,
                      ),
                      const Marker(
                        markerId: MarkerId('destinationLocation'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: bestechMall,
                      )
                    },
 */
