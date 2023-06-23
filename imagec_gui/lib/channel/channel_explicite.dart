import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'channel_common.dart';



class ChannelSettingExplicite extends Channel {
  ChannelSettingExplicite(
      {super.key,
      required super.scroll,
      required super.parent,
      required super.channelType});

  final _ChannelSettingExplicite settings = _ChannelSettingExplicite();

  @override
  State<ChannelSettingExplicite> createState() => settings;

  @override
  Object toJsonObject() {
    return super.jsonObjectBuilder();
  }

  ///
  /// Load channel settings from json object
  ///
  void loadChannelSettings(dynamic channel) {
    super.chSelector
        .setSelectedChannel(ChannelIndex.toIndex(channel["index"] as int));
    super.selectedChannelLabel =
        ChannelLabels.stringToEnum(channel["label"] as String);
    super.useAI = channel["detection_mode"] as String == "AI" ? true : false;

    // Threshold settings
    if (channel.containsKey("thresholds")) {
      super.selectedThresholdMethod = ThresholdMethod.stringToEnum(
          channel["thresholds"]["threshold_algorithm"]);
      super.selectedMinThreshold.text =
          ((channel["thresholds"]["threshold_min"] as double) * 100).toString();
    }

    // AI settings
    if (channel.containsKey("ai_settings")) {
      super.selectedMinProbability.text =
          ((channel["ai_settings"]["probability_min"] as double) * 100.0)
              .toString();

      super.selectedAIModel =
          AIModel.stringToEnum(channel["ai_settings"]["model_name"] as String);
    }

    super.selectedMinCircularity.text =
        ((channel["min_circularity"] as double) * 100).toString();
    super.selectedSnapArea.text =
        ((channel["snap_area_size"] as double)).toString();
    super.selectedMarginCrop.text =
        ((channel["margin_crop"] as double)).toString();

    super.selectedParticleSizeRange.text =
        ((channel["min_particle_size"] as double)).toString() +
            "-" +
            ((channel["max_particle_size"] as double)).toString();

    //settings.thresholdMethodController.selection =
    //    channel["thresholds"]["threshold_algorithm"];
//
    //print("d");
    //settings.aiModelController.selection = channel["ai_settings"]["model_name"];
  }
}

///
/// Title card
class _ChannelSettingExplicite extends State<ChannelSettingExplicite> {
  @override
  void initState() {
    super.initState();
  }



  ////////////////////////////////////////////////
  final TextEditingController chLabelsController = TextEditingController();
  final TextEditingController thresholdMethodController =
      TextEditingController();
  final TextEditingController aiModelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    ///
    /// Channel labels
    final List<DropdownMenuEntry<ChannelLabels>> channelLabelsEntries =
        <DropdownMenuEntry<ChannelLabels>>[];
    for (final ChannelLabels entry in ChannelLabels.values) {
      channelLabelsEntries.add(
          DropdownMenuEntry<ChannelLabels>(value: entry, label: entry.label));
    }

    ///
    /// Thresholds
    final List<DropdownMenuEntry<ThresholdMethod>> thresholdMethodEntries =
        <DropdownMenuEntry<ThresholdMethod>>[];
    for (final ThresholdMethod entry in ThresholdMethod.values) {
      thresholdMethodEntries.add(
          DropdownMenuEntry<ThresholdMethod>(value: entry, label: entry.label));
    }

    ///
    /// AI Model
    final List<DropdownMenuEntry<AIModel>> aiModelEntries =
        <DropdownMenuEntry<AIModel>>[];
    for (final AIModel entry in AIModel.values) {
      aiModelEntries
          .add(DropdownMenuEntry<AIModel>(value: entry, label: entry.label));
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
                          widget.channelType.label,
                          style: textTheme.titleLarge,
                        )),

                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(width: 220, child: widget.chSelector)),

                    //
                    // Channel labels
                    //
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: DropdownMenu<ChannelLabels>(
                          width: 230,
                          initialSelection: widget.selectedChannelLabel,
                          controller: chLabelsController,
                          leadingIcon: const Icon(Icons.label_outline),
                          label: const Text('Label'),
                          dropdownMenuEntries: channelLabelsEntries,
                          onSelected: (value) {
                            setState(() {
                              widget.selectedChannelLabel = value!;
                            });
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
                            value: widget.useAI,
                            onChanged: (value) {
                              setState(() {
                                widget.useAI = value;
                              });
                            },
                          ),
                        )),

                    ////////////////////////////////////////////////////////////////////
                    //
                    // Threshold method
                    //
                    Visibility(
                        visible: !widget.useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: DropdownMenu<ThresholdMethod>(
                              width: 230,
                              initialSelection: widget.selectedThresholdMethod,
                              controller: thresholdMethodController,
                              leadingIcon: const Icon(Icons.contrast),
                              label: const Text('Thresholds'),
                              dropdownMenuEntries: thresholdMethodEntries,
                              onSelected: (value) {
                                setState(() {
                                  widget.selectedThresholdMethod = value!;
                                });
                              },
                            ))),
                    //
                    // Minimum threshold
                    //
                    Visibility(
                        visible: !widget.useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 230,
                              child: TextField(
                                obscureText: false,
                                controller: widget.selectedMinThreshold,
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
                        visible: widget.useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: DropdownMenu<AIModel>(
                              width: 230,
                              initialSelection: widget.selectedAIModel,
                              controller: aiModelController,
                              leadingIcon: const Icon(Icons.hub_outlined),
                              label: const Text('AI model'),
                              dropdownMenuEntries: aiModelEntries,
                              onSelected: (value) {
                                widget.selectedAIModel = value!;
                              },
                            ))),
                    //
                    // Minimum probability
                    //
                    Visibility(
                        visible: widget.useAI,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 230,
                              child: TextField(
                                obscureText: false,
                                controller: widget.selectedMinProbability,
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
                            controller: widget.selectedMinCircularity,
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
                            controller: widget.selectedParticleSizeRange,
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
                            controller: widget.selectedSnapArea,
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
                            controller: widget.selectedMarginCrop,
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
