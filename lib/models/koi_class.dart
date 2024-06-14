import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
part 'koi_class.g.dart';
@HiveType(typeId: 0)
class MarkerModel extends HiveObject {
  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  @HiveField(2)
  String markerId;

  @HiveField(3)
  String? title;

  @HiveField(4)
  String? colors; //aka snippet

  @HiveField(5)
  void Function(MarkerModel)? onTapMarker; //aka onMarkerTap

  MarkerModel({
    required this.latitude,
    required this.longitude,
    required this.markerId,
    this.title,
    this.colors,
    this.onTapMarker
  });

  Marker toMarker() {
    BitmapDescriptor? icons;

    if(colors == 'type_all'){
    debugPrint("Entered in 012");
    icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);}
    else if(colors == 'type_0_1'){
    debugPrint("Entered in 01");
    icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);}
    else if(colors == 'type_1_2'){
    debugPrint("Entered in 12");
    icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);}
    else if(colors == 'type_2_0'){
      debugPrint("Entered in 20");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);}
    else if(colors == 'type_green'){
      debugPrint("Entered in GREEN");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }else if(colors == 'type_orange'){
      debugPrint("Entered in ORANGE");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }else if(colors == 'type_pink'){
      debugPrint("Entered in PINK");
      icons = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }else{
      debugPrint("Entered in DEFAULT");
      icons = BitmapDescriptor.defaultMarker;
    }

    return Marker(
      infoWindow: InfoWindow(title: title ?? 'No Title', snippet: colors ?? '', onTap: () {
        if(onTapMarker!=null){
          onTapMarker!(this);
        }
      },),
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      icon: icons,
    );
  }

  static MarkerModel fromMarker(Marker marker){
    return MarkerModel(
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
      markerId: marker.markerId.value,
      title: marker.infoWindow.title,
      colors: marker.infoWindow.snippet,
    );
  }
}

/*
COMMAND TO GET class.g.dart file :
flutter packages pub run build_runner build
*/