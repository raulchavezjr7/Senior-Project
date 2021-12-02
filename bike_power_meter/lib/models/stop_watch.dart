import 'package:flutter/cupertino.dart';

class StopTimer with ChangeNotifier {
  Stopwatch timer = Stopwatch();

  StopTimer();

  String formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  timerstart() {
    timer.start();
  }

  int timerRead() {
    return timer.elapsedMilliseconds;
  }

  timerStop() {
    timer.stop();
    timer.reset();
  }
}
