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
}

///
/// Enum values
enum ChannelTypeLabels {
  nucleus(
    'Nucleus (alpha)',
    'NUCLEUS',
  ),
  cell('Cell (NA)', 'CELL'),
  ev('EV (NA)', 'EV'),
  background('Background (NA)', 'BACKGROUND');

  const ChannelTypeLabels(this.label, this.value);
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
  Channel({super.key, required this.scroll, required this.parent});

  final ScrollSyncer scroll;
  final State parent;

  Object toJsonObject();
}

///
/// Check if the number of a textfield is between the given two ranges
class CheckForNonEmptyTextField extends TextInputFormatter {
  final RegExp regex;

  CheckForNonEmptyTextField({required this.regex});

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
