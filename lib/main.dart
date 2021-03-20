import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hse_search/login/content.dart';
import 'package:hse_search/login/cubit.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        accentColor: Colors.white,
      ),
      home: BlocProvider(
        create: (BuildContext context) {
          return LoginCubit();
        },
        child: LoginScreen(),
      ),
    );
  }
}
