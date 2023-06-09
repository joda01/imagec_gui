import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/channel/channel_enums.dart';

import '../channel/channel_explicite.dart';
import '../helper/scroll_syncer.dart';
import '../screens/screen_channels.dart';
import '../channel/channel.dart';


///
/// Base class for a preprocessing step
///
abstract class PreprocessingWidget extends StatelessWidget {
  PreprocessingWidget({required this.parentChannelWidget});

  Widget getChild();

  final ChannelSettingExplicite parentChannelWidget;

  Object toJsonObject();
  void fromJsonObject(dynamic);

    Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 230,
        child: InkWell(
          onTap: () {
            parentChannelWidget.settings.removePreprocessingStep(this);
          },
          hoverColor: Theme.of(context).colorScheme.onInverseSurface,
          focusColor: Theme.of(context).colorScheme.onInverseSurface,
          radius: 0,
          child: Badge(
            label: Text("--"),
            child: getChild()
          ),
        ),
      ));

}