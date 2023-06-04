// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

    Widget schemeLabel() {
      return Container(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text("Welcome", style: textTheme.displayLarge!),
      ));
    }

    Widget footer() => RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              const TextSpan(
                  text: 'To create color schemes based on a '
                      'platform\'s implementation of dynamic color, '
                      'use the '),
              TextSpan(
                text: 'dynamic_color',
                style: const TextStyle(decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final url = Uri.parse(
                      'https://pub.dev/packages/dynamic_color',
                    );
                  },
              ),
              const TextSpan(text: ' package.'),
            ],
          ),
        );

    Widget expander() {
      return Expanded(
          child: FittedBox(
              alignment: Alignment.center,
              child: const Text('Flexible Content')));
    }

    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        return Align(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  schemeLabel(),
                  divider,
                  footer()
                ],
              ),
            ));
      }),
    );
  }
}
