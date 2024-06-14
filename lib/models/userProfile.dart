import 'dart:convert';

import 'koi_class_firebase.dart';

class UserProfile {
  String? uid;
  String? name;
  List<MarkerModelFirebase>? markerMessageFirebase;

  // String? markerModelCollectionId;
  // String? pfpURL;

  UserProfile(
      {required this.uid,
      required this.name,
      required this.markerMessageFirebase
      // required this.markerModelCollectionId
      // required this.pfpURL,
      });

  UserProfile.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        markerMessageFirebase = List.from(json['markerMessageFirebase'])
            .map((m) => MarkerModelFirebase.fromFirestore(m))
            .toList();

  // markerModelCollectionId = json['markerModelCollectionId'];
  // pfpURL = json['pfpURL'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['markerMessageFirebase'] = markerMessageFirebase?.map((m) => m.toFirestore()).toList() ?? [];
    // data['markerModelCollectionId'] = markerModelCollectionId;
    // data['pfpURL'] = pfpURL;
    return data;
  }

  @override
  String toString() {
    return "$uid - $name - ${markerMessageFirebase?.length}";
  }
}
