import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin SingleEventMixin<E, S> on Cubit<S> {
  final _singleEventsController = StreamController<E>.broadcast();

  Stream<E> get singleEvents => _singleEventsController.stream;

  @override
  Future<void> close() async {
    await _singleEventsController.close();
    await super.close();
  }

  void send(E event) {
    try {
      _singleEventsController.add(event);
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }
}

mixin SingleEventSubscription<W extends StatefulWidget> on State<W> {
  StreamSubscription _singleEventsSubscription;

  @override
  void dispose() {
    _singleEventsSubscription?.cancel();
    super.dispose();
  }

  void setOnSingleEvent(StreamSubscription onSingleEvent) {
    _singleEventsSubscription?.cancel();
    _singleEventsSubscription = onSingleEvent;
  }
}
