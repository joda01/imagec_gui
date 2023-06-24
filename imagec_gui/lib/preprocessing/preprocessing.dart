import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/channel/channel_enums.dart';

import '../helper/scroll_syncer.dart';
import '../screens/screen_channels.dart';
import '../channel/channel.dart';


///
/// Base class for a preprocessing step
///
abstract class PreprocessingWidget extends StatelessWidget {
  PreprocessingWidget({required this.widget});

  Widget getChild();

  final Channel widget;

    Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 230,
        child: InkWell(
          onTap: () {
            print("remove preprocessing");
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