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
class PreprocessingZStack extends StatelessWidget {
  PreprocessingZStack();

  ZstackOptions selectedZStackOption = ZstackOptions.maximumIntensity;
  TextEditingController zStackController = TextEditingController()..text = "0";

  @override
  Object toJsonObject() {
    final settings = {
      "function": Z_STACK_LABEL,
      "value": selectedZStackOption.value
    };

    return settings;
  }

  @override
  void fromJsonObject(dynamic data) {
    selectedZStackOption = ZstackOptions.stringToEnum(data["value"] as String);
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<ZstackOptions>> zStackOptionsEntries =
        <DropdownMenuEntry<ZstackOptions>>[];
    for (final ZstackOptions entry in ZstackOptions.values) {
      zStackOptionsEntries.add(
          DropdownMenuEntry<ZstackOptions>(value: entry, label: entry.label));
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 230,
        child: DropdownMenu<ZstackOptions>(
          width: 230,
          initialSelection: selectedZStackOption,
          controller: zStackController,
          leadingIcon: const Icon(Icons.label_outline),
          label: const Text('Z-Stack projection'),
          dropdownMenuEntries: zStackOptionsEntries,
          onSelected: (value) {
            selectedZStackOption = value!;
          },
        ),
      ),
    );
  }
}
