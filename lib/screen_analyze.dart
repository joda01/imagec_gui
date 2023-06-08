// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_util';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  List<Channel> actChannels = [];

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

class ScrollSyncer {
  StreamController<ScrollController> _streamController =
      StreamController<ScrollController>.broadcast();

  void setPosition(ScrollController position) {
    if (pos != position.offset) {
      pos = position.offset;
      _streamController.add(position);
    }
  }

  Stream<ScrollController> get onChange => _streamController.stream;
  double pos = 0;

  void dispose() {
    _streamController.close();
  }
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
                              int idx = widget.parent.actChannels.length - 1;
                              widget.parent.actChannels.insert(
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

///
/// Enum values
enum ChannelTypeLabels {
  ev('EV', 'EV'),
  nucleus(
    'Nucleus',
    'NUCLEUS',
  ),
  background('Background', 'BACKGROUND'),
  cellBrightfield('Cell brightfield', 'CELL_BRIGHTFIELD'),
  cellDarkfield('Cell darkfield', 'CELL_DARKFIELD');

  const ChannelTypeLabels(this.label, this.value);
  final String label;
  final String value;
}

enum ChannelLabels {
  cy3('CY3', 'CY3'),
  cy5(
    'CY5',
    'CY5',
  ),
  cy7('CY7', 'CY7');

  const ChannelLabels(this.label, this.value);
  final String label;
  final String value;
}

enum ThresholdMethod {
  manual('Manual', 'MANUAL'),
  li(
    'Li',
    'LI',
  ),
  triangle(
    'Min error',
    'MIN_ERROR',
  ),
  min_error('Triangle', 'TRIANGLE');

  const ThresholdMethod(this.label, this.value);
  final String label;
  final String value;
}

enum AIModelEV {
  common('Common v1', 'AI_MODEL_EV_COMMON_V1'),
  inVitro(
    'In vitro v1',
    'AI_MODEL_EV_IN_VITRO_V1',
  ),
  inVivo(
    'In vivo v1',
    'AI_MODEL_EV_IN_VIVO_V1',
  );

  const AIModelEV(this.label, this.value);
  final String label;
  final String value;
}

enum ChannelIndex {
  ch01('01', 0),
  ch02('02', 1),
  ch03('03', 2),
  ch04('04', 3),
  ch05('05', 4),
  ch06('06', 5),
  ch07('07', 6),
  ch08('08', 7),
  ch09('09', 8),
  ch10('10', 9),
  ch11('11', 10),
  ch12('12', 11);
  //ch13('13', 12),
  //ch14('14', 13),
  //ch15('15', 14),
  //ch16('16', 15),
  // ch17('17', 16),
  //  ch18('18', 17);

  const ChannelIndex(this.label, this.value);
  final String label;
  final int value;
}

final ScrollSyncer controllervertical = ScrollSyncer();

abstract class Channel extends StatefulWidget {
  Channel({super.key, required this.scroll, required this.parent});

  final ScrollSyncer scroll;
  final _ChannelRow parent;
}

class ChannelSettingEV extends Channel {
  ChannelSettingEV({super.key, required super.scroll, required super.parent});

  @override
  State<ChannelSettingEV> createState() => new _ChannelSettingEV();
}

///
/// Title card
class _ChannelSettingEV extends State<ChannelSettingEV> {
  bool useAI = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    ///
    /// Channel labels
    final TextEditingController chLabelsController = TextEditingController();
    final List<DropdownMenuEntry<ChannelLabels>> channelLabelsEntries =
        <DropdownMenuEntry<ChannelLabels>>[];
    for (final ChannelLabels entry in ChannelLabels.values) {
      channelLabelsEntries.add(
          DropdownMenuEntry<ChannelLabels>(value: entry, label: entry.label));
    }

    ///
    /// Thresholds
    final TextEditingController thresholdMethodController =
        TextEditingController();
    final List<DropdownMenuEntry<ThresholdMethod>> thresholdMethodEntries =
        <DropdownMenuEntry<ThresholdMethod>>[];
    for (final ThresholdMethod entry in ThresholdMethod.values) {
      thresholdMethodEntries.add(
          DropdownMenuEntry<ThresholdMethod>(value: entry, label: entry.label));
    }

    ///
    /// AI Model
    final TextEditingController aiModelController = TextEditingController();
    final List<DropdownMenuEntry<AIModelEV>> aiModelEntries =
        <DropdownMenuEntry<AIModelEV>>[];
    for (final AIModelEV entry in AIModelEV.values) {
      aiModelEntries
          .add(DropdownMenuEntry<AIModelEV>(value: entry, label: entry.label));
    }
    final ScrollController controllervertical = ScrollController();

    widget.scroll.onChange.listen((newValue) {
      if (newValue != controllervertical &&
          controllervertical.hasClients &&
          newValue.offset >= 0.0) {
        controllervertical.jumpTo(newValue.offset);
      }
    });

    void _hasScrolled() {
      widget.scroll.setPosition(controllervertical);
    }

    controllervertical.addListener(_hasScrolled);

    return Scrollbar(
        thickness: 10,
        //thumbVisibility: true,
        interactive: true,
        controller: controllervertical,
        child: SingleChildScrollView(
            controller: controllervertical,
            scrollDirection: Axis.vertical,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: SizedBox(
                  // width: width,
                  child: Center(
                      child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "EV",
                          style: textTheme.titleLarge,
                        )),

                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(width: 220, child: ChannelSelector())),

                    //
                    // Channel labels
                    //
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: DropdownMenu<ChannelLabels>(
                          width: 230,
                          initialSelection: ChannelLabels.cy3,
                          controller: chLabelsController,
                          leadingIcon: const Icon(Icons.label_outline),
                          label: const Text('Label'),
                          dropdownMenuEntries: channelLabelsEntries,
                          onSelected: (value) {
                            //setState(() {
                            //  selectedIcon = icon;
                            //});
                          },
                        )),

                    //
                    // Divider
                    //
                    CustomDivider(),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 230,
                          child: SwitchListTile(
                            title: const Text('Use AI'),
                            secondary: const Icon(Icons.auto_awesome_outlined),
                            value: useAI,
                            onChanged: (value) {
                              setState(() {
                                useAI = value;
                              });
                            },
                          ),
                        )),

                    ////////////////////////////////////////////////////////////////////
                    //
                    // Thershold method
                    //
                    Visibility(
                        visible: !useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: DropdownMenu<ThresholdMethod>(
                              width: 230,
                              initialSelection: ThresholdMethod.manual,
                              controller: thresholdMethodController,
                              leadingIcon: const Icon(Icons.contrast),
                              label: const Text('Thresholding'),
                              dropdownMenuEntries: thresholdMethodEntries,
                              onSelected: (value) {
                                //setState(() {
                                //  selectedIcon = icon;
                                //});
                              },
                            ))),
                    //
                    // Minimum threshold
                    //
                    Visibility(
                        visible: !useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 230,
                              child: TextField(
                                obscureText: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                  RangeTextInputFormatter(min: 0, max: 100)
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.exposure),
                                    border: OutlineInputBorder(),
                                    labelText: 'Min threshold',
                                    suffixText: '%',
                                    hintText: '[0-100]',
                                    helperText:
                                        'Value of 100% means perfect white.'),
                              ),
                            ))),

                    ////////////////////////////////////////////////////////////////////
                    //
                    // AI method
                    //
                    Visibility(
                        visible: useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: DropdownMenu<AIModelEV>(
                              width: 230,
                              initialSelection: AIModelEV.common,
                              controller: aiModelController,
                              leadingIcon: const Icon(Icons.hub_outlined),
                              label: const Text('AI model'),
                              dropdownMenuEntries: aiModelEntries,
                              onSelected: (value) {
                                //setState(() {
                                //  selectedIcon = icon;
                                //});
                              },
                            ))),
                    //
                    // Minimum probability
                    //
                    Visibility(
                        visible: useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 230,
                              child: TextField(
                                obscureText: false,
                                controller: TextEditingController()
                                  ..text = '80',
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                  RangeTextInputFormatter(min: 0, max: 100)
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.percent),
                                    border: OutlineInputBorder(),
                                    labelText: 'Min probability',
                                    suffixText: '%',
                                    hintText: '[0-100]',
                                    helperText:
                                        'Minimum probability to accept a finding.'),
                              ),
                            ))),

                    //
                    // Divider
                    //
                    CustomDivider(),

                    //
                    // Minimum circularity
                    //
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 230,
                          child: TextField(
                            obscureText: false,
                            controller: TextEditingController()..text = '80',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                              RangeTextInputFormatter(min: 0, max: 100)
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.hexagon_outlined),
                                suffixText: '%',
                                border: OutlineInputBorder(),
                                labelText: 'Min. circularity',
                                hintText: '[0-100]',
                                helperText:
                                    'Value of 100% means perfect circle.'),
                          ),
                        )),

                    //
                    // Particle size
                    //
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 230,
                          child: TextField(
                            obscureText: false,
                            controller: TextEditingController()
                              ..text = '5-999999',
                            inputFormatters: [
                              CheckForNonEmptyTextField(
                                  regex:
                                      RegExp(r'^\d+\.?\d{0,2}-\d+\.?\d{0,2}')),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}-\d+\.?\d{0,2}')),
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.all_out_outlined),
                                border: OutlineInputBorder(),
                                labelText: 'Particle size range',
                                suffixText: 'µm²',
                                hintText: '[min] - [max]',
                                helperText: 'Particle size range.'),
                          ),
                        )),

                    //
                    // Snap area
                    //
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 230,
                          child: TextField(
                            obscureText: false,
                            controller: TextEditingController()..text = '0',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                              RangeTextInputFormatter(
                                  min: 0, max: double.infinity)
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.adjust),
                                suffixText: 'µm',
                                border: OutlineInputBorder(),
                                labelText: 'Snap area diameter',
                                helperText: 'Snap area diameter'),
                          ),
                        )),

                    //
                    // Divider
                    //
                    CustomDivider(),

                    //
                    // Margin crop
                    //
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 230,
                          child: TextField(
                            obscureText: false,
                            controller: TextEditingController()..text = '0',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                              RangeTextInputFormatter(
                                  min: 0, max: double.infinity)
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.crop),
                                suffixText: 'µm',
                                border: OutlineInputBorder(),
                                labelText: 'Margin crop',
                                helperText: 'Margin crop'),
                          ),
                        )),

                    //
                    // Divider
                    //
                    CustomDivider(),

                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: FilledButton(
                          // co:Theme.of(context).colorScheme.onError,

                          onPressed: () {
                            widget.parent.actChannels.remove(widget);
                            widget.parent.setState(() {});
                          },
                          child: const Text('Remove'),
                          style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error),
                        )),
                  ])),
                ),
              ),
            ))));
  }
}

///
/// Check if the number of a textfield is between the given two ranges
class CheckForNonEmptyTextField extends TextInputFormatter {
  final RegExp regex;

  CheckForNonEmptyTextField({required this.regex});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (regex.hasMatch(newValue.text)) {
      return newValue.copyWith(
        text: newValue.text,
        selection: newValue.selection,
        composing: TextRange.empty,
      );
    } else {
      return oldValue.copyWith(
        text: oldValue.text,
        selection: oldValue.selection,
        composing: TextRange.empty,
      );
    }
  }
}

///
/// Check if the number of a textfield is between the given two ranges
class RangeTextInputFormatter extends TextInputFormatter {
  final double min;
  final double max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      double? value;
      value = double.parse(newValue.text);
      if (value != null && (value >= min && value <= max)) {
        return newValue.copyWith(
          text: newValue.text,
          selection: newValue.selection,
          composing: TextRange.empty,
        );
      }
    } catch (e) {
      return newValue.copyWith(
        text: newValue.text,
        selection: newValue.selection,
        composing: TextRange.empty,
      );
    }
    return oldValue.copyWith(
      text: oldValue.text,
      selection: oldValue.selection,
      composing: TextRange.empty,
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 10.0,
        width: 230,
        child: Center(
          child: Container(
            margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
            height: 1.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ));
}

///
/// Channel index selector
class ChannelSelector extends StatefulWidget {
  const ChannelSelector({super.key});

  @override
  State<ChannelSelector> createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  Set<ChannelIndex> filters = <ChannelIndex>{};

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Choose corresponding channel', style: textTheme.labelLarge),
          const SizedBox(height: 5.0),
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: ChannelIndex.values.map((ChannelIndex exercise) {
              return FilterChip(
                label: Text(exercise.label),
                selected: filters.contains(exercise),
                //selectedColor: Theme.of(context).colorScheme.onSurface,
                showCheckmark: false,
                onSelected: (bool selected) {
                  setState(() {
                    filters.clear(); // Allow only one selection
                    if (selected) {
                      filters.add(exercise);
                    } else {
                      filters.remove(exercise);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
