import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/channel/channel_enums.dart';

import '../helper/scroll_syncer.dart';
import '../screens/screen_channels.dart';
import '../channel/channel.dart';

import 'package:namer_app/preprocessing/preprocessing.dart';


///
/// Margin crop preprocessing
///
class PreprocessingRollingBall extends PreprocessingWidget {
  PreprocessingRollingBall({required super.parentChannelWidget});

  TextEditingController rollingBallSize = TextEditingController()
    ..text = "0";

  @override
  Object toJsonObject() {
    final settings = {
      "function": PreprocessingSteps.rollingBall.value,
      "value": rollingBallSize.text
    };

    return settings;
  }

  @override
  void fromJsonObject(dynamic data) {
    rollingBallSize.text = data["value"] as String;
  }


  @override
  Widget getChild() {
    return TextField(
      obscureText: false,
      controller: rollingBallSize,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        RangeTextInputFormatter(min: 0, max: double.infinity)
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lens_blur),
          suffixText: 'µm',
          border: OutlineInputBorder(),
          labelText: 'Ball size',
          helperText: 'Rolling ball background subtraction'),
    );
  }
}
