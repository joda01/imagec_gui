// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_util';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/channel_common.dart';
import '../channel/channel_ev.dart';

const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class ScreenAnalyze extends StatelessWidget {
  const ScreenAnalyze({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    Widget title() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text("Welcome", style: textTheme.displayLarge!),
      );
    }

    Widget footer() => RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              const TextSpan(
                  text:
                      'Copyright 2023 J.D | many thanks to Melanie Schuerz and Anna Mueller | '),
              TextSpan(
                text: 'imagec.org',
                style: const TextStyle(decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final url = Uri.parse(
                      'https://www.imagec.org',
                    );
                  },
              ),
              const TextSpan(text: ''),
            ],
          ),
        );

    Widget expander() {
      return Expanded(
          child: Container(alignment: Alignment.bottomCenter, child: footer()));
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return ChannelRow();
    });
  }
}

class ChannelRow extends StatefulWidget {
  const ChannelRow({super.key});

  @override
  State<ChannelRow> createState() => _ChannelRow();
}

class _ChannelRow extends State<ChannelRow>
    with AutomaticKeepAliveClientMixin<ChannelRow> {
  final ScrollController controllerHorizontal = ScrollController();

  @override
  void initState() {
    super.initState();
    actChannels.add(AddChannelButton(
      scroll: controllervertical,
      parent: this,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 10,
      thumbVisibility: true,
      interactive: true,
      controller: controllerHorizontal,
      child: SingleChildScrollView(
          controller: controllerHorizontal,
          scrollDirection: Axis.horizontal,
          child: Row(
              //    mainAxisAlignment: MainAxisAlignment.,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: actChannels)),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class AddChannelButton extends Channel {
  AddChannelButton({
    super.key,
    required super.scroll,
    required super.parent,
  });

  @override
  State<AddChannelButton> createState() => _AddChannelButton();
}

class _AddChannelButton extends State<AddChannelButton> {
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Theme.of(context).colorScheme.background,
                child: SizedBox(
                    // width: width,
                    child: Center(
                        child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 60,
                        child: FloatingActionButton(
                          onPressed: () {
                            // Add your onPressed code here!

                            //myChannelRows = Object();
                            widget.parent.setState(() {
                              int idx = actChannels.length - 1;
                              actChannels.insert(
                                  idx,
                                  ChannelSettingEV(
                                    key: UniqueKey(),
                                    scroll: controllervertical,
                                    parent: widget.parent,
                                  ));
                            });
                          },
                          //backgroundColor: Colors.green,
                          child: const Icon(Icons.add),
                        ),
                      ))
                ]))))));
  }
}
