import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/scroll_syncer.dart';

State? addChannelButtonStateWidget;

///
/// Enum pipelines
///
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
///
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

///
/// Channel labels
///
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

enum PreprocessingSteps {
  none('none', 'NONE'),
  cy3('CY3', 'MARGIN_CROP'),
  cy5('CY5', 'ROLLING_BALL'),
  cy7('CY7', 'MAXIMUM_INTENSITY_PROJECTION'),
  dapi('DAPI', 'DECONVOLUTION'),
  gfp(
    'GFP',
    'GFP',
  );

  const PreprocessingSteps(this.label, this.value);
  final String label;
  final String value;

  static stringToEnum(String str) {
    for (final label in PreprocessingSteps.values) {
      if (label.value == str) {
        return label;
      }
    }
    return PreprocessingSteps.none;
  }
}

///
/// AI Models
///
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
/// Channel Types
///
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

///
/// Threshold methods
///
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

///
/// Channel index
///
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
