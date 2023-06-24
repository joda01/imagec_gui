
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ScrollSyncer globalCardControllervertical = ScrollSyncer();


///
/// Scroll syncer
///
class ScrollSyncer {
  StreamController<ScrollController> _streamController =
      StreamController<ScrollController>.broadcast();

  void setPosition(ScrollController position) {
    if (pos != position.offset) {
      pos = position.offset;
      _streamController.add(position);
    }
  }

  Stream<ScrollController> get onChange => _streamController.stream;
  double pos = 0;

  void dispose() {
    _streamController.close();
  }
}