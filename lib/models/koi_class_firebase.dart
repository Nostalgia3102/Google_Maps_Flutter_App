import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'koi_class.dart';

class MarkerModelFirebase {
  double latitude;
  double longitude;
  String markerId;
  String? title;
  String? colors; // aka snippet
  void Function(MarkerModelFirebase)? onTapMarker; // aka onMarkerTap

  MarkerModelFirebase({
    required this.latitude,
    required this.longitude,
    required this.markerId,
    this.title,
    this.colors,
    this.onTapMarker,
  });

  Marker toMarker() {
    BitmapDescriptor? icons;

    if (colors == 'type_all') {
      debugPrint("Entered in 012");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    } else if (colors == 'type_0_1') {
      debugPrint("Entered in 01");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    } else if (colors == 'type_1_2') {
      debugPrint("Entered in 12");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    } else if (colors == 'type_2_0') {
      debugPrint("Entered in 20");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    } else if (colors == 'type_green') {
      debugPrint("Entered in GREEN");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (colors == 'type_orange') {
      debugPrint("Entered in ORANGE");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (colors == 'type_pink') {
      debugPrint("Entered in PINK");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    } else {
      debugPrint("Entered in DEFAULT");
      icons = BitmapDescriptor.defaultMarker;
    }
    return Marker(
      infoWindow: InfoWindow(
        title: title ?? 'No Title',
        snippet: colors ?? '',
        onTap: () {
          if (onTapMarker != null) {
            onTapMarker!(this);
          }
        },
      ),
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      icon: icons,
    );
  }

  static MarkerModelFirebase fromMarker(Marker marker) {
    return MarkerModelFirebase(
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
      markerId: marker.markerId.value,
      title: marker.infoWindow.title,
      colors: marker.infoWindow.snippet,
    );
  }

  // Convert MarkerModelFirebase to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'markerId': markerId,
      'title': title,
      'colors': colors,
    };
  }

  // Create MarkerModelFirebase from Firestore document
  factory MarkerModelFirebase.fromFirestore(Map<String, dynamic> doc) {
    Map<String, dynamic> data = doc;
    return MarkerModelFirebase(
      latitude: data['latitude'],
      longitude: data['longitude'],
      markerId: data['markerId'],
      title: data['title'],
      colors: data['colors'],
    );
  }

  MarkerModel toMarkerModel() {
    return MarkerModel(
      latitude: latitude,
      longitude: longitude,
      markerId: markerId,
      title: title,
      colors: colors,
      onTapMarker: (marker) {
        if (onTapMarker != null) {
          onTapMarker!(this);
        }
      },
    );
  }

}

// Firestore collection reference with converter
// final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//
// final _markersCollection = _firebaseFirestore.collection("markers").withConverter<MarkerModelFirebase>(
//   fromFirestore: (snapshot, _) => MarkerModelFirebase.fromFirestore(snapshot),
//   toFirestore: (markerModel, _) => markerModel.toFirestore(),
// );
