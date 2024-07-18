import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'signup.dart';
import 'profile.dart';
import 'forgot_password.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final Box _boxLogin = Hive.box("login");

  final FirebaseAuthService _auth = FirebaseAuthService();
  bool isLoggingIn = false;

  final Color _primaryColor = Color(0xFFC2AA81);
  final Color _lightShadeC2AA81 = Color(0xFFE5D9C3);

  @override
  void initState() {
    super.initState();
    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightShadeC2AA81,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Login to your account",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 60),
              TextFormField(
                controller: _controllerEmail,
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                cursorColor: Color(0xFFC2AA81),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: _focusNodeEmail.hasFocus ? _primaryColor : Colors.grey),
                  prefixIcon: Icon(Icons.email_outlined, color: _primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                ),
                onEditingComplete: () => _focusNodePassword.requestFocus(),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email.";
                  } else if (!value.contains('@') || !value.contains('.')) {
                    return "Please enter a valid email.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                cursorColor: Color(0xFFC2AA81),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: _focusNodePassword.hasFocus ? _primaryColor : Colors.grey),
                  prefixIcon: Icon(Icons.password_outlined, color: _primaryColor),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: _obscurePassword
                        ? Icon(Icons.visibility_outlined, color: _primaryColor)
                        : Icon(Icons.visibility_off_outlined, color: _primaryColor),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ForgotPassword();
                      },
                    ),
                  );
                },
                child: Text("Forgot Password?", style: TextStyle(color: _primaryColor)),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: _primaryColor),
                    ),
                    onPressed: () {
                      _login();
                    },
                    child: isLoggingIn
                        ? CircularProgressIndicator(color: _primaryColor)
                        : Text(
                            "Login",
                            style: TextStyle(color: _primaryColor),
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _loginWithGoogle();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.grey,
                    ),
                    label: const Text("Signup with Google"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Signup();
                              },
                            ),
                          );
                        },
                        child: Text("Signup", style: TextStyle(color: _primaryColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoggingIn = true;
      });

      String email = _controllerEmail.text;
      String password = _controllerPassword.text;

      User? user = await _auth.signInWithEmailAndPassword(email, password);

      setState(() {
        isLoggingIn = false;
      });

      if (user != null) {
        _boxLogin.put("loginStatus", true);
        _boxLogin.put("userEmail", user.email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              username: user.displayName ?? 'User',
              email: user.email ?? 'email@example.com',
              userId: '',
            ),
          ),
        );
      } else {
        // The toast message will be shown by the FirebaseAuthService
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      isLoggingIn = true;
    });

    User? user = await _auth.signInWithGoogle();

    setState(() {
      isLoggingIn = false;
    });

    if (user != null) {
      _boxLogin.put("loginStatus", true);
      _boxLogin.put("userEmail", user.email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Profile(
            username: user.displayName ?? 'User',
            email: user.email ?? 'email@example.com',
            userId: user.uid,
          ),
        ),
      );
    } else {
      // The toast message will be shown by the FirebaseAuthService
    }
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}