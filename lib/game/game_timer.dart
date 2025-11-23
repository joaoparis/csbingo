import 'dart:async';

import 'package:flutter/material.dart';

class GameTimer extends ChangeNotifier {
  Duration? _duration;
  DateTime? _startAt;
  Timer? _ticker;
  final ValueNotifier<String> timerText = ValueNotifier<String>('00:00');
  final StreamController<void> _onTimerFinished = StreamController.broadcast();

  Stream<void> get onTimerFinished => _onTimerFinished.stream;

  Duration get remaining {
    if (_duration == null) return Duration.zero;
    final elapsed = _computeElapsed();
    final rem = _duration! - elapsed;
    return rem.isNegative ? Duration.zero : rem;
  }

  bool get isRunning => _startAt != null;

  void startTimer(Duration duration) {
    _duration = duration;
    _startAt = DateTime.now();

    _startTicker();
    _updateTimerTextAndNotify();
  }

  void resetTimer() {
    _stopTicker();
    _duration = null;
    _startAt = null;
    timerText.value = '00:00';
    notifyListeners();
  }

  Duration _computeElapsed() {
    if (_startAt == null) return Duration.zero;
    final now = DateTime.now();
    return now.difference(_startAt!);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _updateTimerTextAndNotify();
      if (remaining == Duration.zero) {
        _onTimerFinished.add(null);
        _stopTicker();
        // optional: notifyListeners or update state to "time's up"
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _updateTimerTextAndNotify() {
    final rem = remaining;
    final text = _formatDuration(rem);
    // Only update and notify when the displayed text actually changes
    if (timerText.value != text) {
      timerText.value = text;
      notifyListeners();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _onTimerFinished.close();
    timerText.dispose();
    super.dispose();
  }
}
