import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'channel_common.dart';

enum ChannelLabels {
  cy3('Brightfield', 'BRIGHTFIELD'),
  cy5(
    'Darkfield',
    'DARKFIELD',
  );

  const ChannelLabels(this.label, this.value);
  final String label;
  final String value;
}

enum AIModelNucleus {
  common('Common v1', 'AI_MODEL_NUCLEUS_COMMON_V1'),
  inVitro(
    'In vitro v1',
    'AI_MODEL_NUCLUES_IN_VITRO_V1',
  ),
  inVivo(
    'In vivo v1',
    'AI_MODEL_NUCLEUS_IN_VIVO_V1',
  );

  const AIModelNucleus(this.label, this.value);
  final String label;
  final String value;
}

class ChannelSettingNucleus extends Channel {
  ChannelSettingNucleus(
      {super.key, required super.scroll, required super.parent});

  @override
  State<ChannelSettingNucleus> createState() => new _ChannelSettingNucleus();
}

///
/// Title card
class _ChannelSettingNucleus extends State<ChannelSettingNucleus> {
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
    final List<DropdownMenuEntry<AIModelNucleus>> aiModelEntries =
        <DropdownMenuEntry<AIModelNucleus>>[];
    for (final AIModelNucleus entry in AIModelNucleus.values) {
      aiModelEntries.add(
          DropdownMenuEntry<AIModelNucleus>(value: entry, label: entry.label));
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
                          "Nucleus",
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
                    // Threshold method
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
                              label: const Text('Thresholds'),
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
                            child: DropdownMenu<AIModelNucleus>(
                              width: 230,
                              initialSelection: AIModelNucleus.common,
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
