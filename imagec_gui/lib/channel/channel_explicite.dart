import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/channel/channel.dart';
import 'package:namer_app/preprocessing/preprocessing_z_stack.dart';
import '../preprocessing/preprocessing_margin_crop.dart';
import '../preprocessing/preprocessing.dart';
import '../preprocessing/preprocessing_rolling_ball.dart';
import 'channel_enums.dart';

class ChannelSettingExplicite extends Channel {
  ChannelSettingExplicite(
      {super.key,
      required super.scroll,
      required super.parent,
      required super.channelType}) {
  }

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
    //
    // Common
    //
    super
        .chSelector
        .setSelectedChannel(ChannelIndex.toIndex(channel["index"] as int));
    super.selectedChannelLabel =
        ChannelLabels.stringToEnum(channel["label"] as String);
    super.selectedChannelName.text = channel["name"] as String;

    //
    // Load preprocessing steps
    //
    final preprocessingSteps = channel["preprocessing"] as List<dynamic>;
    for (final dynamic preprocessing in preprocessingSteps) {
      if (preprocessing["function"] as String == Z_STACK_LABEL) {
        super.preprocessingZStack.fromJsonObject(preprocessing);
      } else {
        final preWidget = addPreprocessingStep(PreprocessingSteps.stringToEnum(
            preprocessing["function"] as String));
        preWidget.fromJsonObject(preprocessing);
      }
    }

    //
    // Detection
    //
    final detectionDynamic = channel["detection"];

    super.useAI = detectionDynamic["mode"] as String == "AI" ? true : false;
    // Threshold settings
    if (detectionDynamic.containsKey("threshold")) {
      super.selectedThresholdMethod = ThresholdMethod.stringToEnum(
          detectionDynamic["threshold"]["threshold_algorithm"]);

      double minThreshodl =
          ((detectionDynamic["threshold"]["threshold_min"] as double) * 100);
      if (minThreshodl >= 0) {
        super.selectedMinThreshold.text = minThreshodl.toString();
      }
    }

    // AI settings
    if (detectionDynamic.containsKey("ai")) {
      double minProbability =
          ((detectionDynamic["ai"]["probability_min"] as double) * 100);
      if (minProbability >= 0) {
        super.selectedMinProbability.text = minProbability.toString();
      }

      super.selectedAIModel =
          AIModel.stringToEnum(detectionDynamic["ai"]["model_name"] as String);
    }

    //
    // Filtering
    //
    final filterDynamic = channel["filter"];
    double minCircularity =
        ((filterDynamic["min_circularity"] as double) * 100);
    if (minCircularity >= 0) {
      super.selectedMinCircularity.text = minCircularity.toString();
    }

    double snapAreaSize = ((filterDynamic["snap_area_size"] as double));
    if (snapAreaSize >= 0) {
      super.selectedSnapArea.text = snapAreaSize.toString();
    }

    double marginCrop = ((filterDynamic["margin_crop"] as double));
    if (marginCrop >= 0) {
      super.selectedMarginCrop.text = marginCrop.toString();
    }

    double minParticleSize = ((filterDynamic["min_particle_size"] as double));
    double maxParticleSize = ((filterDynamic["max_particle_size"] as double));

    if (minParticleSize >= 0 && maxParticleSize >= 0) {
      super.selectedParticleSizeRange.text =
          minParticleSize.toString() + "-" + maxParticleSize.toString();
    }

    //settings.thresholdMethodController.selection =
    //    channel["thresholds"]["threshold_algorithm"];
//
    //print("d");
    //settings.aiModelController.selection = channel["ai_settings"]["model_name"];
  }

  ///
  /// Adds an preprocessing step
  ///
  PreprocessingWidget addPreprocessingStep(
      PreprocessingSteps preprocessingStep) {
    PreprocessingWidget widgetNew;

    switch (preprocessingStep) {
      case PreprocessingSteps.marginCrop:
        widgetNew = PreprocessingWidgetMarginCrop(
          parentChannelWidget: this,
        );
        break;
      case PreprocessingSteps.rollingBall:
        widgetNew = PreprocessingRollingBall(
          parentChannelWidget: this,
        );
        break;
      case PreprocessingSteps.bluer:
        widgetNew = PreprocessingRollingBall(
          parentChannelWidget: this,
        );
        break;
      default:
        widgetNew = PreprocessingWidgetMarginCrop(
          parentChannelWidget: this,
        );
        break;
    }
    preprocessingSteps.add(widgetNew);

    return widgetNew;
  }
}

///
/// Title card
class _ChannelSettingExplicite extends State<ChannelSettingExplicite> {
  ////////////////////////////////////////////////
  final TextEditingController chLabelsController = TextEditingController();
  final TextEditingController thresholdMethodController =
      TextEditingController();
  final TextEditingController aiModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  ///
  /// Remove preprocessing step
  ///
  void removePreprocessingStep(PreprocessingWidget wdgt) {
    setState(() {
      widget.preprocessingSteps.remove(wdgt);
    });
  }

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
      //widget.scroll.setPosition(controllervertical);
    }

    controllervertical.addListener(_hasScrolled);

    ///
    /// Show add preprocessing dialog
    ///
    void showAddPreprocessingStepDialog() {
      ///
      /// Channel labels
      final TextEditingController preprocessingStepController =
          TextEditingController();
      final List<DropdownMenuEntry<PreprocessingSteps>>
          availablePreprocessingSteps =
          <DropdownMenuEntry<PreprocessingSteps>>[];
      for (final PreprocessingSteps entry in PreprocessingSteps.values) {
        availablePreprocessingSteps.add(DropdownMenuEntry<PreprocessingSteps>(
            value: entry, label: entry.label));
      }

      PreprocessingstepSelector preprocessingSelector =
          PreprocessingstepSelector();

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select function'),
          content: SizedBox(
              //height: 200,
              width: 450,
              child: preprocessingSelector),
          actions: <Widget>[
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text('Okay'),
              onPressed: () {
                for (final step in preprocessingSelector.getSelectedChannel()) {
                  //print("S" + step.label);
                  widget.addPreprocessingStep(step);
                  try {
                    setState(() {});
                  } catch (e) {}
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

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

                    // Channel name
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 230,
                          child: TextField(
                            obscureText: false,
                            controller: widget.selectedChannelName,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.text_fields),
                              border: OutlineInputBorder(),
                              labelText: 'Name',
                            ),
                          ),
                        )),

                    // Channel selector
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
                    CustomDivider(
                      text: 'Preprocessing',
                      paddingBottom: 25,
                    ),
                    widget.preprocessingZStack,
                    Column(
                      children: widget.preprocessingSteps,
                    ),

                    //
                    // Add preprocessing step button
                    //
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: FilledButton(
                        onPressed: () {
                          showAddPreprocessingStepDialog();
                        },
                        child: Wrap(
                            children: [const Icon(Icons.add), const Text('')]),
                      ),
                    ),

                    //
                    // Divider
                    //
                    CustomDivider(text: 'Detection'),
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
                    CustomDivider(
                      text: 'Filtering',
                    ),

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
                    CustomDivider(text: ""),

                    RemoveChannelWidget(widget: widget)
                  ])),
                ),
              ),
            ))));
  }
}
