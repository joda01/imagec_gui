// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/logic/analyzer_settings.dart';
import 'package:namer_app/screens/screen_channels.dart';

import '../constants.dart';

const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    Widget footer() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: RichText(
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
          ),
        );

    Widget expander() {
      return Expanded(
          child: Container(alignment: Alignment.bottomRight, child: footer()));
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: viewportConstraints.maxHeight,
        ),
        child: IntrinsicHeight(
            child: Column(children: <Widget>[TitleCard(), expander()])),
      ));
    });
  }
}

///
/// Get started button pressed
void getStartedPressed() {
  homeState?.handleScreenChanged(ScreenSelected.channels.value);
}

///
/// Title card
class TitleCard extends StatelessWidget {
  const TitleCard({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context).colorScheme.background,
        child: SizedBox(
          // width: width,
          child: Center(
              child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                child: Text('ImageC', style: textTheme.displayLarge!)),
            Text('v1.0.0-alpha1', style: textTheme.bodyMedium!),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: Text(
                  'High throughput image analysis for biologists in scientific environments.',
                  style: textTheme.bodyLarge!),
            ),
            Wrap(spacing: 5.0, runSpacing: 1.0, children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 5, 5),
                  child: FilledButton(
                    onPressed: () {
                      getStartedPressed();
                      startNewProject();
                    },
                    child: const Text('Start new project'),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 20, 5),
                  child: FilledButton(
                    onPressed: () {
                      getStartedPressed();
                      loadSettingsFromLocalFile();
                    },
                    child: const Text('Continue where you left'),
                  ))
            ]),
          ])),
        ),
      ),
    ));
  }
}
