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
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleEventSubscription {
  @override
  void didChangeDependencies() {
    final _cubit = context.read<LoginCubit>();

    setOnSingleEvent(_cubit.singleEvents.listen((event) {
      if (event is NavigateToMapSingleEvent) {
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => MapScreen()));
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
            loading: (_) => const LoadingScreen());
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
  bool passwordInvisibility = true;
  FocusNode? focusEmail;
  FocusNode? focusPassword;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool correctEmail = false;
  bool correctPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                        correctEmail = true;
                      });
                    } else {
                      setState(() {
                        correctEmail = false;
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
                  obscureText: passwordInvisibility,
                  controller: passwordController,
                  autocorrect: false,
                  maxLength: 64,
                  autofocus: false,
                  focusNode: focusPassword,
                  onFieldSubmitted: correctEmail && correctPassword
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
                        correctPassword = true;
                      });
                    } else {
                      setState(() {
                        correctPassword = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.vpn_key),
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordInvisibility
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordInvisibility = !passwordInvisibility;
                        });
                      },
                    ),
                    labelText: 'Password',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: correctEmail && correctPassword
                          ? Colors.blue
                          : const Color(0xff9e9e9e),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: correctEmail && correctPassword
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
                          color: correctEmail && correctPassword
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
    );
  }
}