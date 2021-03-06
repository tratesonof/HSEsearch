import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hse_search/base/auth_service.dart';
import 'package:hse_search/base/single_event.dart';
import 'package:hse_search/login/single_event.dart';
import 'package:hse_search/login/state.dart';

class LoginCubit extends Cubit<ViewState>
    with SingleEventMixin<SingleEvent, ViewState> {
  LoginCubit() : super(const ViewState.content(email: '', password: ''));

  void login({@required String? email, @required String? password}) async {
      emit(const ViewState.loading());
      await Future.delayed(const Duration(seconds: 2));
      send(const NavigateToMapSingleEvent());
  }

  void registration() {
    send(const NavigateToRegistrationSingleEvent());
  }
}
