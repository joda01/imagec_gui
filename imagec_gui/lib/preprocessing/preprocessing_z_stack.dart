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
  PreprocessingZStack({required super.parentChannelWidget});

  ZstackOptions selectedZStackOption = ZstackOptions.maximumIntensity;
  TextEditingController zStackController = TextEditingController()..text = "0";

  @override
  Object toJsonObject() {
    final settings = {
      "function": PreprocessingSteps.zStack.value,
      "value": selectedZStackOption.value
    };

    return settings;
  }

  @override
  void fromJsonObject(dynamic data) {
    selectedZStackOption = ZstackOptions.stringToEnum(data["value"] as String);
  }

  @override
  Widget getChild() {
    final List<DropdownMenuEntry<ZstackOptions>> zStackOptionsEntries =
        <DropdownMenuEntry<ZstackOptions>>[];
    for (final ZstackOptions entry in ZstackOptions.values) {
      zStackOptionsEntries.add(
          DropdownMenuEntry<ZstackOptions>(value: entry, label: entry.label));
    }

    return DropdownMenu<ZstackOptions>(
      width: 230,
      initialSelection: selectedZStackOption,
      controller: zStackController,
      leadingIcon: const Icon(Icons.label_outline),
      label: const Text('Z-Stack options'),
      dropdownMenuEntries: zStackOptionsEntries,
      onSelected: (value) {
        selectedZStackOption = value!;
      },
    );
  }
}
