import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Channel> actChannels = [];
State? addChannelButtonStateWidget;
final ScrollSyncer globalCardControllervertical = ScrollSyncer();

///
/// Enum pipelines
enum Pipelines {
  count('Count', 'COUNT'),
  coloc(
    'Coloc',
    'COLOC',
  ),
  inCellColoc('In cell coloc', 'COLOC_IN_CELL');

  const Pipelines(this.label, this.value);
  final String label;
  final String value;

    static Pipelines stringToEnum(String inString) {
    for (final enumI in Pipelines.values) {
      if (enumI.value == inString) {
        return enumI;
      }
    }
    return Pipelines.count;
  }
}

///
/// Export gadgets
enum PostProcessingScript {
  liner_regression(
      'Linear regression (R)', 'POST_PROCESSING_SCRIPT_LINER_REGRESSION'),
  histogram('Histogram (Python)', 'POST_PROCESSING_SCRIPT_HISTOGRAM'),
  graphical_view(
    'Graphical comparison (Python)',
    'POST_PROCESSING_SCRIPT_GRAPHICAL_COMPARISON',
  );

  const PostProcessingScript(this.label, this.value);
  final String label;
  final String value;
}

enum ChannelLabels {
  none('none', 'NONE'),
  cy3('CY3', 'CY3'),
  cy5('CY5', 'CY5'),
  cy7('CY7', 'CY7'),
  dapi('DAPI', 'DAPI'),
  gfp(
    'GFP',
    'GFP',
  );

  const ChannelLabels(this.label, this.value);
  final String label;
  final String value;

  static stringToEnum(String str) {
    for (final label in ChannelLabels.values) {
      if (label.value == str) {
        return label;
      }
    }
    return ChannelLabels.none;
  }
}

enum AIModel {
  common('Common v1', 'AI_MODEL_COMMON_V1');

  const AIModel(this.label, this.value);
  final String label;
  final String value;

  static stringToEnum(String str) {
    for (final label in AIModel.values) {
      if (label.value == str) {
        return label;
      }
    }
    return AIModel.common;
  }
}

///
/// Enum values
enum ChannelTypeLabels {
  nucleus(
    'Nucleus (alpha)',
    'NUCLEUS',
  ),
  cell('Cell (alpha)', 'CELL'),
  ev('EV (NA)', 'EV'),
  background('Background (NA)', 'BACKGROUND'),
  tetraspeck_bead('Tetraspeck Bead (NA)', 'TETRASPECK_BEAD');

  const ChannelTypeLabels(this.label, this.value);
  final String label;
  final String value;

  static ChannelTypeLabels stringToEnum(String inString) {
    for (final enumI in ChannelTypeLabels.values) {
      if (enumI.value == inString) {
        return enumI;
      }
    }
    return ChannelTypeLabels.nucleus;
  }
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

  static ThresholdMethod stringToEnum(String inString) {
    for (final enumI in ThresholdMethod.values) {
      if (enumI.value == inString) {
        return enumI;
      }
    }
    return ThresholdMethod.manual;
  }
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

  static ChannelIndex toIndex(int i) {
    for (final channel in ChannelIndex.values) {
      if (channel.value == i) {
        return channel;
      }
    }
    return ChannelIndex.ch01;
  }
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

abstract class Channel extends StatefulWidget {
  Channel(
      {super.key,
      required this.scroll,
      required this.parent,
      required this.channelType});

  final ScrollSyncer scroll;
  final State parent;
  final ChannelTypeLabels channelType;


  // Taken settings
  final ChannelSelector chSelector = ChannelSelector();
  ChannelLabels selectedChannelLabel = ChannelLabels.cy3;
  AIModel selectedAIModel = AIModel.common;
  bool useAI = false;
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

  Object toJsonObject();

  (double,double) getMinMaxParticleSize(){
    final min = double.parse(selectedParticleSizeRange.text.split("-")[0]);
    final max = double.parse(selectedParticleSizeRange.text.split("-")[1]);
    return (min,max);
  }


  @protected
  Object jsonObjectBuilder() {

    final (minParticle, maxParticle) = getMinMaxParticleSize();
    final channelSettings = {
      "index": chSelector.getSelectedChannel(),
      "type": channelType.value,
      "label": selectedChannelLabel.value,
      "detection_mode": true == useAI ? "AI" : "THRESHOLD",
      "thresholds": {
        "threshold_algorithm": selectedThresholdMethod.value,
        "threshold_min":double.parse(selectedMinThreshold.text)/100,
        "threshold_max": 1,
      },
      "ai_settings": {
        "model_name": selectedAIModel.value,
        "probability_min": double.parse(selectedMinProbability.text)/100
      },
      "min_particle_size": minParticle,
      "max_particle_size": maxParticle,
      "min_circularity": double.parse(selectedMinCircularity.text)/100,
      "snap_area_size": double.parse(selectedSnapArea.text),
      "margin_crop": double.parse(selectedMarginCrop.text),
      "zprojection": "MAX",
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
  CustomDivider({this.padding = 10});
  final double padding;
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.all(padding),
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

class RemoveChannelWidget extends StatelessWidget {
  RemoveChannelWidget({required this.widget});

  final Channel widget;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
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
