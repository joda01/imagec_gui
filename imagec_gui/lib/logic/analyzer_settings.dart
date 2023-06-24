import 'dart:collection';
import 'dart:convert';
import 'dart:html' as html;

import '../channel/channel_enums.dart';
import '../screens/screen_analyze.dart';
import '../screens/screen_channels.dart';
import '../screens/screen_home.dart';

///
/// Generate analyze settings
///
String generateAnalyzeSettings(String pipeline, String inputFolder) {
  final mainSettings = {
    "input_folder": inputFolder,
    "pipeline": pipeline,
    "channels": [],
    "min_coloc_factor": 10,
    "pixel_in_micrometer": 1,
    "with_control_images": true,
    "with_detailed_report": true
  };

  // Iterate over all channels
  for (var ch in actChannels) {
    var obj = ch.toJsonObject() as LinkedHashMap<dynamic, dynamic>;
    if (obj.containsKey("index")) {
      var channels = mainSettings['channels'] as List<dynamic>;
      channels.add(obj);
    }
  }

  final body = jsonEncode(mainSettings);
  return body;
}

///
/// Load analyze settings
///
void loadFromAnalyzeSettings(dynamic settings) {
  channelRow.loadChannelSettings(settings);
  selectedPipeline = Functions.stringToEnum(settings["pipeline"] as String);
}

///
/// Store settings to local file storage
///
Future<void> storeSettingsToLocalFile() async {
  final jsonString =
      generateAnalyzeSettings(selectedPipeline!.value, inputFolder.text);
  html.window.localStorage["IMAGEC_SETTINGS"] = jsonString;
}


///
/// Load settings from local file storage
///
Future<void> loadSettingsFromLocalFile() async {
  final jsonString = html.window.localStorage["IMAGEC_SETTINGS"];
  if (jsonString != null) {
    final storedSettings = json.decode(jsonString);
    loadFromAnalyzeSettings(storedSettings);
  }
}


///
/// Start new project
///
void startNewProject()  {
  channelRow.clearAllChannels();
}