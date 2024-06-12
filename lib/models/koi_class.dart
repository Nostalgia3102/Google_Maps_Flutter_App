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

  MarkerModel({
    required this.latitude,
    required this.longitude,
    required this.markerId,
    this.title,
  });

  Marker toMarker() {
    return Marker(
      infoWindow: InfoWindow(title: title ?? 'No Title'),
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
    );
  }

  static MarkerModel fromMarker(Marker marker){
    return MarkerModel(
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
      markerId: marker.markerId.value,
      title: marker.infoWindow.title
    );
  }
}
/*

COMMAND TO GET class.g.dart file :
flutter packages pub run build_runner build

 */