

import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps/services/auth_service.dart';
import 'package:google_maps/services/database_services.dart';
import 'package:google_maps/services/navigation_services.dart';

import 'firebase_options.dart';

final GetIt _getIt = GetIt.instance;

Future<void> setUpFireBase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> registerServices() async {
  print("utils --> ${_getIt.hashCode}");

  _getIt.registerSingleton<AuthService>(AuthService());
  _getIt.registerSingleton<NavigationService>(NavigationService());
  _getIt.registerSingleton<DatabaseServices>(DatabaseServices());

  print("Services Registered");
}

String generateStorageDataId({required String uid1}) {
  String uid2 = DateTime.now().toString();
  List uids = [uid1, uid2];
  uids.sort();
  String storageId = uids.fold("", (id, uid) => "$id$uid");
  return storageId;
}
