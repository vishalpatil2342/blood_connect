import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashFinished extends Notifier<bool> {
  @override
  bool build() => false;

  void finish() {
    state = true;
  }
}

final splashFinishedProvider = NotifierProvider<SplashFinished, bool>(SplashFinished.new);
