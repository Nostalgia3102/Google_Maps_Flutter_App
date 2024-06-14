import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps/pages/login_page.dart';
import '../const.dart';
import '../models/userProfile.dart';
import '../services/auth_service.dart';
import '../services/database_services.dart';
import '../services/navigation_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseServices _databaseServices;
  String? name, email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseServices = _getIt.get<DatabaseServices>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Let's Get Going!",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              ),
              const Text("Register your account using the form below"),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _registerFormKey,
                child: Column(
                  children: [
                    // CircleAvatar(
                    //     radius: MediaQuery.of(context).size.width * 0.15),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height:150,
                            child: Image(image: AssetImage("assets/images/map.png"))),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      validator: (value) {
                        if (value != null &&
                            NAME_VALIDATION_REGEX.hasMatch(value)) {
                          name = value;
                          return null;
                        }
                        return "Enter valid name";
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Name"),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      validator: (value) {
                        if (value != null &&
                            EMAIL_VALIDATION_REGEX.hasMatch(value)) {
                          email = value;
                          return null;
                        }
                        return "Enter valid email id";
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Email"),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value != null &&
                            PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
                          password = value;
                          return null;
                        }
                        return "Enter valid password";
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Password"),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_registerFormKey.currentState?.validate() ?? false) {
                      _registerFormKey.currentState?.save();
                      bool result =
                      await _authService.register(email!, password!);
                      if (result) {
                        if (name != null) {
                          try{
                            await _databaseServices.createUserProfile(
                                userProfile: UserProfile(
                                    uid: _authService.user!.uid, name: name, markerMessageFirebase: []));
                            _navigationService.pushReplacementNamed("/google_map");
                          }catch(e){
                            print("Unable to register the user");
                            print(e);
                          }
                        }
                      } else {
                        final snackBar = SnackBar(
                          content: const Text('Invalid Credentials'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Some action to undo
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                  child: const Text("Register"),
                ),
              ),
              Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Already have an Account ?"),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
