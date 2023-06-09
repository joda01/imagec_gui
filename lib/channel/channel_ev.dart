import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'channel_common.dart';

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

class ChannelSettingEV extends Channel {
  ChannelSettingEV({super.key, required super.scroll, required super.parent});

  final _ChannelSettingEV settings = _ChannelSettingEV();

  @override
  State<ChannelSettingEV> createState() => settings;

  @override
  Object toJsonObject() {
    return settings.toJsonObject();
  }
}

///
/// Title card
class _ChannelSettingEV extends State<ChannelSettingEV> {
  bool useAI = false;

  @override
  void initState() {
    super.initState();
  }

  Object toJsonObject() {
    final channelSettings = {
      "index": [1, 2],
      "type": "EV",
      "threshold_algorithm": "LI",
      "label": "CY5",
      "threshold_min": 65536,
      "threshold_max": 123,
      "min_particle_size": 0.25,
      "max_particle_size": 0.23,
      "min_circularity": 0.2,
      "snap_area_size": 2,
      "margin_crop": 1,
      "zprojection": "MAX"
    };
    return channelSettings;
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

                    RemoveChannelWidget(widget: widget)
                  ])),
                ),
              ),
            ))));
  }
}