import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hse_search/base/auth_service.dart';
import 'package:hse_search/base/curved_widget.dart';
import 'package:hse_search/base/loading.dart';
import 'package:hse_search/base/single_event.dart';
import 'package:hse_search/login/cubit.dart';
import 'package:hse_search/login/single_event.dart';
import 'package:hse_search/login/state.dart';
import 'package:hse_search/map/content.dart';
import 'package:hse_search/registration/registration.dart';

import '../base/constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  FocusNode? focusEmail;
  FocusNode? focusPassword;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isPasswordInvisible = true;
  bool _isCorrectEmail = false;
  bool _isCorrectPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: const Color(0xff87cefa),
          child: CurvedWidget(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[200],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/ic_flutter.svg',
                        color: const Color(0xff1e88e5),
                        width: 160,
                        height: 160,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 54, 24, 16),
                    child: TextFormField(
                      focusNode: focusEmail,
                      onFieldSubmitted: passwordController.text.isEmpty
                          ? (_) {
                              FocusScope.of(context)
                                  .requestFocus(focusPassword);
                            }
                          : null,
                      onChanged: (_) {
                        if (emailRegex.hasMatch(emailController.text)) {
                          setState(() {
                            _isCorrectEmail = true;
                          });
                        } else {
                          setState(() {
                            _isCorrectEmail = false;
                          });
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      maxLength: 64,
                      controller: emailController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Почта',
                        counterText: '',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    child: TextFormField(
                      obscureText: _isPasswordInvisible,
                      controller: passwordController,
                      autocorrect: false,
                      maxLength: 64,
                      autofocus: false,
                      focusNode: focusPassword,
                      onFieldSubmitted: _isCorrectEmail && _isCorrectPassword
                          ? (_) {
                              var auth =
                                  AuthenticationService(FirebaseAuth.instance);
                              // ignore: cascade_invocations
                              auth.signUp(
                                  email: emailController.text,
                                  password: passwordController.text);
                              Navigator.pop(context);
                              final snackBar = SnackBar(
                                content: const Text('Регистрация успешна!'),
                                action: SnackBarAction(
                                  label: 'Ок',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          : null,
                      onChanged: (_) {
                        if (passwordController.text.length > 6) {
                          setState(() {
                            _isCorrectPassword = true;
                          });
                        } else {
                          setState(() {
                            _isCorrectPassword = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.vpn_key),
                        counterText: '',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordInvisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() =>
                              _isPasswordInvisible = !_isPasswordInvisible),
                        ),
                        labelText: 'Пароль',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isCorrectEmail && _isCorrectPassword
                              ? Colors.blue
                              : const Color(0xff9e9e9e),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextButton(
                          onPressed: _isCorrectEmail && _isCorrectPassword
                              ? () {
                                  var auth = AuthenticationService(
                                      FirebaseAuth.instance);
                                  // ignore: cascade_invocations
                                  auth.signUp(
                                      email: emailController.text,
                                      password: passwordController.text);
                                  Navigator.pop(context);
                                  final snackBar = SnackBar(
                                    content: const Text('Регистрация успешна!'),
                                    action: SnackBarAction(
                                      label: 'Ок',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : null,
                          child: Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isCorrectEmail && _isCorrectPassword
                                  ? Colors.white
                                  : const Color(0xffe0e0e0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
