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
class PreprocessingWidgetMarginCrop extends PreprocessingWidget {
  PreprocessingWidgetMarginCrop({required super.parentChannelWidget});


  TextEditingController marginCropSize = TextEditingController()
    ..text = "0";

  @override
  Object toJsonObject() {
    final settings = {
      "function": PreprocessingSteps.marginCrop.value,
      "value": marginCropSize.text
    };

    return settings;
  }

  @override
  void fromJsonObject(dynamic data) {
    marginCropSize.text = data["value"] as String;
  }


  @override
  Widget getChild() {
    return TextField(
      obscureText: false,
      controller: marginCropSize,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        RangeTextInputFormatter(min: 0, max: double.infinity)
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.crop),
          suffixText: 'µm',
          border: OutlineInputBorder(),
          labelText: 'Margin size',
          helperText: 'Margin to crop'),
    );
  }
}
