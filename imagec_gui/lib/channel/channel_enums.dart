import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/scroll_syncer.dart';

State? addChannelButtonStateWidget;

///
/// Enum pipelines
///
enum Functions {
  count('Coloc', 'COLOC'),
  coloc(
    'Intersection',
    'INTERSECTION',
  );

  const Functions(this.label, this.value);
  final String label;
  final String value;

  static Functions stringToEnum(String inString) {
    for (final enumI in Functions.values) {
      if (enumI.value == inString) {
        return enumI;
      }
    }
    return Functions.count;
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


///
/// Z-Stack options labels
///
enum ZstackOptions {
  none('None', 'NONE'),
  maximumIntensity('Max. intensity projection', 'PROJECT_MAX_INTENSITY'),
  multiDimension('3D projection', 'PROJECT_3D');

  const ZstackOptions(this.label, this.value);
  final String label;
  final String value;

  static stringToEnum(String str) {
    for (final label in ZstackOptions.values) {
      if (label.value == str) {
        return label;
      }
    }
    return ZstackOptions.none;
  }
}


///
/// Preprocessing step
///
///
///

const String Z_STACK_LABEL = "Z_STACK";
enum PreprocessingSteps {
  marginCrop('Margin crop', 'MARGIN_CROP', Icon(Icons.crop_outlined)),
  backgroundSubtraction('Background sub.', 'BACKGROUND_SUBTRACTION',
      Icon(Icons.wallpaper_outlined)),
  rollingBall('Rolling ball', 'ROLLING_BALL', Icon(Icons.blur_on_sharp)),

  bluer('Bluer', 'BLUER', Icon(Icons.blur_linear_outlined));

  const PreprocessingSteps(this.label, this.value, this.icon);
  final String label;
  final String value;
  final Icon icon;

  static stringToEnum(String str) {
    for (final label in PreprocessingSteps.values) {
      if (label.value == str) {
        return label;
      }
    }
    return PreprocessingSteps.marginCrop;
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
  ev('Spot (NA)', 'SPOT'),
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
