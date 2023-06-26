import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/channel/channel_enums.dart';

import '../helper/scroll_syncer.dart';
import '../preprocessing/preprocessing.dart';
import '../preprocessing/preprocessing_z_stack.dart';
import '../screens/screen_channels.dart';

///
/// Abstract channel class
///
abstract class Channel extends StatefulWidget {
  Channel(
      {super.key,
      required this.scroll,
      required this.parent,
      required this.channelType}) {}

  final ScrollSyncer scroll;
  final State parent;
  final ChannelTypeLabels channelType;

  // Taken settings
  final ChannelSelector chSelector = ChannelSelector();
  ChannelLabels selectedChannelLabel = ChannelLabels.cy3;
  AIModel selectedAIModel = AIModel.common;
  bool useAI = false;
  TextEditingController selectedChannelName = TextEditingController();
  ThresholdMethod selectedThresholdMethod = ThresholdMethod.manual;
  TextEditingController selectedMinThreshold = TextEditingController();
  TextEditingController selectedMinProbability = TextEditingController()
    ..text = "80";
  TextEditingController selectedMinCircularity = TextEditingController()
    ..text = "80";
  TextEditingController selectedSnapArea = TextEditingController()..text = "0";
  TextEditingController selectedMarginCrop = TextEditingController()
    ..text = "0";
  TextEditingController selectedParticleSizeRange = TextEditingController()
    ..text = "5-999999";

  List<PreprocessingWidget> preprocessingSteps = [];

  final PreprocessingZStack preprocessingZStack = PreprocessingZStack();

  Object toJsonObject();

  (double, double) getMinMaxParticleSize() {
    final min = double.parse(selectedParticleSizeRange.text.split("-")[0]);
    final max = double.parse(selectedParticleSizeRange.text.split("-")[1]);
    return (min, max);
  }

  String getNameAndIndex() {
    return "${selectedChannelName.text} (${chSelector.getSelectedChannelName()})";
  }

  @protected
  Object jsonObjectBuilder() {
    final (minParticle, maxParticle) = getMinMaxParticleSize();
    double thresholdMin = -1;
    try {
      thresholdMin = double.parse(selectedMinThreshold.text) / 100;
    } catch (e) {}

    double probability_min = -1;
    try {
      probability_min = double.parse(selectedMinProbability.text) / 100;
    } catch (e) {}

    double min_circularity = -1;
    try {
      min_circularity = double.parse(selectedMinCircularity.text) / 100;
    } catch (ex) {}

    double snap_area_size = -1;
    try {
      snap_area_size = double.parse(selectedSnapArea.text);
    } catch (ex) {}

    double margin_crop = -1;
    try {
      margin_crop = double.parse(selectedMarginCrop.text);
    } catch (ex) {}

    List<Object> preprocessingStepObjects = [];
    preprocessingStepObjects.add(preprocessingZStack.toJsonObject());
    for (final preprocessingStep in preprocessingSteps) {
      preprocessingStepObjects.add(preprocessingStep.toJsonObject());
    }

    final channelSettings = {
      "info":{
        "index": chSelector.getSelectedChannel(),
        "type": channelType.value,
        "label": selectedChannelLabel.value,
        "name": selectedChannelName.text,
      },
      "preprocessing": preprocessingStepObjects,
      "detection": {
        "mode": true == useAI ? "AI" : "THRESHOLD",
        "threshold": {
          "threshold_algorithm": selectedThresholdMethod.value,
          "threshold_min": thresholdMin,
          "threshold_max": 1,
        },
        "ai": {
          "model_name": selectedAIModel.value,
          "probability_min": probability_min
        },
      },
      "filter": {
        "min_particle_size": minParticle,
        "max_particle_size": maxParticle,
        "min_circularity": min_circularity,
        "snap_area_size": snap_area_size,
        "margin_crop": margin_crop,
      }
    };
    return channelSettings;
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

class CustomDivider extends StatelessWidget {
  CustomDivider(
      {required this.text, this.paddingTop = 10, this.paddingBottom = 10});
  final String text;
  final double paddingTop;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.fromLTRB(10, paddingTop, 10, paddingBottom),
      child: SizedBox(
        height: 15.0,
        width: 230,
        child: Wrap(children: [
          Text(text, style: TextStyle(fontStyle: FontStyle.italic)),
          Container(
            margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
            height: 1.0,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ]),
      ));
}

class RemoveChannelWidget extends StatelessWidget {
  RemoveChannelWidget({required this.widget});

  final Channel widget;
  @override
  Widget build(BuildContext context) => Padding(
      padding:const EdgeInsets.fromLTRB(20, 5, 20, 10),
      child: FilledButton(
        // co:Theme.of(context).colorScheme.onError,

        onPressed: () {
          actChannels.remove(widget);
          widget.parent.setState(() {});
          addChannelButtonStateWidget?.setState(() {});
        },
        child: const Text('Remove'),
        style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error),
      ));
}

class PreviewButton extends StatelessWidget {
  PreviewButton({required this.widget});

  final Channel widget;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
      child: FilledButton(
          // co:Theme.of(context).colorScheme.onError,

          onPressed: () {
            //actChannels.remove(widget);
            //widget.parent.setState(() {});
            //addChannelButtonStateWidget?.setState(() {});
          },
          child: const Text('Preview'),
          style: FilledButton.styleFrom(
              //backgroundColor: Theme.of(context).colorScheme.error),
              )));
}

///
/// Channel index selector
class ChannelSelector extends StatefulWidget {
  ChannelSelector({super.key});

  @override
  State<ChannelSelector> createState() => _ChannelSelectorState();

  Set<ChannelIndex> filters = <ChannelIndex>{};

  int getSelectedChannel() {
    if (filters.length > 0) {
      return filters.first.value;
    } else {
      return 0;
    }
  }

  String getSelectedChannelName() {
    if (filters.length > 0) {
      return filters.first.label;
    } else {
      return "";
    }
  }

  void setSelectedChannel(ChannelIndex ch) {
    filters.clear();
    filters.add(ch);
  }
}

class _ChannelSelectorState extends State<ChannelSelector> {
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
                selected: widget.filters.contains(exercise),
                //selectedColor: Theme.of(context).colorScheme.onSurface,
                showCheckmark: false,
                onSelected: (bool selected) {
                  setState(() {
                    widget.filters.clear(); // Allow only one selection
                    if (selected) {
                      widget.filters.add(exercise);
                    } else {
                      widget.filters.remove(exercise);
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

///
/// Function selector
class PreprocessingstepSelector extends StatefulWidget {
  PreprocessingstepSelector({super.key});

  @override
  State<PreprocessingstepSelector> createState() =>
      _PreprocessingstepSelector();

  Set<PreprocessingSteps> filters = <PreprocessingSteps>{};

  Set<PreprocessingSteps> getSelectedChannel() {
    return filters;
  }

  void setSelectedChannel(PreprocessingSteps ch) {
    filters.clear();
    filters.add(ch);
  }
}

class _PreprocessingstepSelector extends State<PreprocessingstepSelector> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ScrollController controllervertical = ScrollController();

    return Scrollbar(
      thickness: 10,
      //thumbVisibility: true,
      interactive: true,
      controller: controllervertical,
      child: SingleChildScrollView(
        controller: controllervertical,
        child: Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children:
              PreprocessingSteps.values.map((PreprocessingSteps exercise) {
            return Container(
              child: FilterChip(
                label:
                    Wrap(children: [exercise.icon, Text(" " + exercise.label)]),
                selected: widget.filters.contains(exercise),
                //selectedColor: Theme.of(context).colorScheme.onSurface,
                showCheckmark: false,
                onSelected: (bool selected) {
                  setState(() {
                    //widget.filters.clear(); // Allow only one selection
                    if (selected) {
                      widget.filters.add(exercise);
                    } else {
                      widget.filters.remove(exercise);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
