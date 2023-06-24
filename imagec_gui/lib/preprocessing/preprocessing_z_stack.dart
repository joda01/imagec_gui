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
class PreprocessingZStack extends PreprocessingWidget {
  PreprocessingZStack({required super.widget});

  @override
  Widget getChild() {
    return TextField(
      obscureText: false,
      controller: widget.selectedMarginCrop,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        RangeTextInputFormatter(min: 0, max: double.infinity)
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.filter_none_outlined),
          suffixText: 'µm',
          border: OutlineInputBorder(),
          labelText: 'Z-Stack',
          helperText: 'How to handle z-stack'),
    );
  }
}
