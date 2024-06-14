import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps/pages/register_page.dart';
import 'package:google_maps/services/navigation_services.dart';

import '../const.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  late AuthService _authService;
  late NavigationService _navigationServices;
  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationServices = _getIt.get<NavigationService>();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hi, Welcome Back!",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              ),
              const Text("Hello again, you have been missed..."),
              const SizedBox(
                height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height:150,
                      child: Image(image: AssetImage("assets/images/map.png"))),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
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
                    if (_loginFormKey.currentState?.validate() ?? false) {
                      _loginFormKey.currentState?.save();
                      bool result = await _authService.login(email!, password!);
                      print(result);
                      if (result) {
                        _navigationServices.pushReplacementNamed("/google_map");
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
                  child: const Text("Login"),
                ),
              ),
              Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Don't have an Account ?"),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          _navigationServices.pushNamed("/register");
                        },
                        child: const Text(
                          "Sign Up!",
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
