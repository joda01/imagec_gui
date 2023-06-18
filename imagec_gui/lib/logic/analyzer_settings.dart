import 'dart:collection';
import 'dart:convert';

import '../channel/channel_common.dart';

/*
{
    "pipeline": "NUCLEUS_COUNT",
    "channels": [
        {
            "index": [
                1,
                2
            ],
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
        },
        {
            "index": [
                1,
                2
            ],
            "type": "EV",
            "threshold_algorithm": "LI",
            "label": "CY7",
            "threshold_min": 65536,
            "threshold_max": 123,
            "min_particle_size": 0.25,
            "max_particle_size": 0.23,
            "min_circularity": 0.2,
            "snap_area_size": 2,
            "margin_crop": 1,
            "zprojection": "MAX"
        },
        {
            "index": [
                1,
                2
            ],
            "type": "NUCLEUS",
            "threshold_algorithm": "LI",
            "label": "CY7",
            "threshold_min": 65536,
            "threshold_max": 123,
            "min_particle_size": 0.25,
            "max_particle_size": 0.23,
            "min_circularity": 0.2,
            "snap_area_size": 2,
            "margin_crop": 1,
            "zprojection": "MAX"
        }
    ],
    "min_coloc_factor": 15.5,
    "pixel_in_micrometer": 0.001,
    "with_control_images": true,
    "with_detailed_report": true
}
*/

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

void loadFromAnalyzeSettings() {}
