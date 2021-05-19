import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hse_search/base/loading.dart';
import 'package:hse_search/base/single_event.dart';
import 'package:hse_search/login/cubit.dart';
import 'package:hse_search/login/single_event.dart';
import 'package:hse_search/login/state.dart';
import 'package:hse_search/map/content.dart';

import '../base/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleEventSubscription {
  @override
  void didChangeDependencies() {
    final _cubit = context.read<LoginCubit>();

    setOnSingleEvent(_cubit.singleEvents.listen((event) {
      if (event is NavigateToMapSingleEvent) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const MapScreen()),
        );
      }
    }));

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, ViewState>(
      builder: (_, state) {
        return state.map(
          content: (contentState) => LoginContent(contentState),
          loading: (_) => const LoadingScreen(),
        );
      },
    );
  }
}

class LoginContent extends StatefulWidget {
  const LoginContent(this.state, {Key? key}) : super(key: key);

  final ContentState state;

  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
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
          color: Colors.grey[200],
          child: Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/svg/ic_logo.svg',
                  color: const Color(0xff1e88e5),
                  width: 320,
                  height: 320,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 54, 24, 16),
                child: TextFormField(
                  focusNode: focusEmail,
                  onFieldSubmitted: passwordController.text.isEmpty
                      ? (_) {
                          FocusScope.of(context).requestFocus(focusPassword);
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
                    labelText: 'Email',
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
                          context.read<LoginCubit>().login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
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
                        _isPasswordInvisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _isPasswordInvisible = !_isPasswordInvisible),
                    ),
                    labelText: 'Password',
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
                      color: _isCorrectEmail && _isCorrectPassword ? Colors.blue : const Color(0xff9e9e9e),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: _isCorrectEmail && _isCorrectPassword
                          ? () {
                              context.read<LoginCubit>().login(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                            }
                          : null,
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isCorrectEmail && _isCorrectPassword ? Colors.white : const Color(0xffe0e0e0),
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
    );
  }
}
