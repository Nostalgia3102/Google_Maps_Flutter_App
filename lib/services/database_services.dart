import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/models/koi_class.dart';
import 'package:google_maps/models/koi_class_firebase.dart';
import 'package:google_maps/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/userProfile.dart';
import 'auth_service.dart';

class DatabaseServices {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late AuthService _authService;

  CollectionReference? _usersCollection;

  DatabaseServices() {
    _authService = _getIt.get<AuthService>();
    _setUpCollectionReferences();
  }

  void _setUpCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection("users").withConverter<UserProfile>(
            fromFirestore: (snapshots, _) =>
                UserProfile.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (user_profile, _) => user_profile.toJson());
  }

    Future<void> createUserProfile({required UserProfile userProfile}) async {
      await _usersCollection?.doc(userProfile.uid).set(userProfile);
    }

    Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
      //to chat with own-self :
      // return _usersCollection?.where("uid").snapshots() as Stream<QuerySnapshot<UserProfile>>;
      return _usersCollection
          ?.where("uid", isNotEqualTo: _authService.user!.uid)
          .snapshots() as Stream<QuerySnapshot<UserProfile>>;
    }

    // Future<bool> checkStorageDataExists(String uid1) async {
    //   String chatID = generateStorageDataId(uid1: uid1);
    //   final result = await _storageDataCollection?.doc(chatID).get();
    //   if (result != null) {
    //     return result.exists;
    //   }
    //   return false;
    // }

    // Future<void> createNewStorageData(
    //     {required String uid1, required String uid2}) async {
    //   String storageDataID = generateStorageDataId(uid1: uid1);
    //   final docRef = _storageDataCollection!.doc(storageDataID);
    //   final chat = Chat(
    //     id: chatID,
    //     participants: [uid1, uid2],
    //     messages: [],
    //   );
    //   await docRef.set(chat);
    // }

    Future<void> sendMarkerModel(String uid1, MarkerModelFirebase mmf) async {
      String newMarker = _authService.user!.uid.toString();
      final docRef = _usersCollection!.doc(newMarker);
      await docRef.update({
        "markerMessageFirebase": FieldValue.arrayUnion(
          [
            mmf.toFirestore(),
          ],
        ),
      });
    }

  Stream<DocumentSnapshot<Object?>> getMarkerModelData() {
      String uid = _authService.user!.uid;
      debugPrint("Get Data");
      debugPrint(_usersCollection?.toString());
      debugPrint(_usersCollection?.doc(uid).toString());
      debugPrint(_usersCollection?.doc(uid).snapshots().toString());
      return _usersCollection!.doc(uid).snapshots() as Stream<DocumentSnapshot<Object>>;
    }
}