import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps/services/auth_service.dart';
import 'package:google_maps/services/navigation_services.dart';
import 'package:google_maps/utils.dart';
import 'package:hive_flutter/adapters.dart';

import 'models/koi_class.dart';

final GetIt _getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MarkerModelAdapter());
  await Hive.openBox('testBox');
  await setUpFireBase();
  await registerServices();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late AuthService _authService;
  late NavigationService _navigationService;
  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: _authService.user != null ? "/google_map" : "/login",
      routes: _navigationService.routes,
    );
  }
}