import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
abstract class ViewState with _$ViewState {
  const factory ViewState.content({
    required String email,
    required String password,
  }) = ContentState;

  const factory ViewState.loading() = LoadingState;
}