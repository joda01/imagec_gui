// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/screens/screen_home.dart';
import '../channel/channel_common.dart';
import '../channel/channel_explicite.dart';
import '../dialogs/dialog_analyze.dart';
import '../logic/analyzer_settings.dart';
import '../logic/backend_communication.dart';

DialogAnalyze dialogAnalyze = DialogAnalyze();
ChannelRow channelRow = ChannelRow();
const Widget divider = SizedBox(height: 10);

// Folder selection
String newSelectedFolder = "";

// File opener
String newSelectedJsonSettingsFile = "";

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class ScreenAnalyze extends StatelessWidget {
  const ScreenAnalyze({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return channelRow;
    });
  }
}

class ChannelRow extends StatefulWidget {
  ChannelRow({super.key});

  _ChannelRow rowStateful = _ChannelRow();
  @override
  State<ChannelRow> createState() => rowStateful;

  void loadChannelSettings(dynamic settings) {
    rowStateful.loadChannelSettings(settings);
  }

  void clearAllChannels() {
    rowStateful.clearAllChannels();
  }
}

class _ChannelRow extends State<ChannelRow>
    with AutomaticKeepAliveClientMixin<ChannelRow> {
  final ScrollController controllerHorizontal = ScrollController();

  void addChannelButton() {
    actChannels.add(AddChannelButton(
        scroll: globalCardControllervertical,
        parent: this,
        channelType: ChannelTypeLabels.nucleus));
  }

  @override
  void initState() {
    super.initState();
    if (actChannels.isEmpty) {
      addChannelButton();
    }
  }

  void _updateFolderPath(String path) {
    setState(() {
      inputFolder.text = path;
    });
  }

  void _onSelectionChange(String newFolder) {
    newSelectedFolder = newFolder;
  }

  void clearAllChannels() {
    actChannels.clear();
    try {
      setState(() {
        newSelectedFolder = "";
        inputFolder.text = "";
      });
    } catch (e) {}
    addChannelButton();
  }

  ///
  /// Load channel settings from json file
  ///
  void loadChannelSettings(dynamic settings) {
    // If empty add open buttons
    actChannels.clear();

    //print(settings);
    final channels = settings["channels"] as List<dynamic>;
    for (final dynamic channel in channels) {
      int idx = actChannels.length;

      var channelType = ChannelTypeLabels.nucleus;
      switch (channel["type"] as String) {
        case "EV":
          channelType = ChannelTypeLabels.ev;
          break;
        case "BACKGROUND":
          channelType = ChannelTypeLabels.background;
          break;
        case "NUCLEUS":
          channelType = ChannelTypeLabels.nucleus;
          break;
        case "CELL":
          channelType = ChannelTypeLabels.cell;
          break;

        default:
          break;
      }
      var chSet = ChannelSettingExplicite(
        key: UniqueKey(),
        scroll: globalCardControllervertical,
        parent: this,
        channelType: channelType,
      );

      chSet.loadChannelSettings(channel);
      actChannels.insert(idx, chSet);
    }

    newSelectedFolder = settings["input_folder"] as String;
    inputFolder.text = newSelectedFolder;

    try {
      setState(() {});
    } catch (e) {}

    addChannelButton();
  }

  ///
  /// Show open folder dialog
  ///
  void showOpenFolderDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select directory'),
        content: OpenFolderDialog(
            isSelectionMode: true,
            onSelectionChange: _onSelectionChange,
            selectedElement: newSelectedFolder,
            fileExtensions: []),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text('Okay'),
            onPressed: () {
              _updateFolderPath(newSelectedFolder!);
              addChannelButtonStateWidget?.setState(() {});
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Scrollbar(
            thickness: 10,
            thumbVisibility: true,
            interactive: true,
            controller: controllerHorizontal,
            child: SingleChildScrollView(
                controller: controllerHorizontal,
                scrollDirection: Axis.horizontal,
                child: Row(
                    //    mainAxisAlignment: MainAxisAlignment.,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: actChannels)),
          ),
        ),
        SizedBox(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
              child: TextField(
                obscureText: false,
                controller: inputFolder,
                onTap: showOpenFolderDialog,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.folder_open_outlined),
                    border: OutlineInputBorder(),
                    labelText: 'Folder where your images are stored in.',
                    suffixText: '',
                    hintText: '/home/user/images/'),
              )),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

///
/// \class AddChannelButton
/// \brief Menu at the left hand side
///
///
class AddChannelButton extends Channel {
  AddChannelButton({
    super.key,
    required super.scroll,
    required super.parent,
    required super.channelType,
  });

  final _AddChannelButton settings = new _AddChannelButton();

  @override
  State<AddChannelButton> createState() => settings;

  @override
  Object toJsonObject() {
    return settings.toJsonObject();
  }
}

class _AddChannelButton extends State<AddChannelButton>
    with TickerProviderStateMixin {
  Object toJsonObject() {
    final channelSettings = {};
    return channelSettings;
  }

  @override
  void initState() {
    addChannelButtonStateWidget = this;

    super.initState();
  }

  ///
  /// \brief Open add channel dialog
  ///
  void openAddChannelDialog(BuildContext context) {
    ///
    /// Channel labels
    final TextEditingController channelTypesController =
        TextEditingController();
    final List<DropdownMenuEntry<ChannelTypeLabels>> channelTypesEntries =
        <DropdownMenuEntry<ChannelTypeLabels>>[];
    for (final ChannelTypeLabels entry in ChannelTypeLabels.values) {
      channelTypesEntries.add(DropdownMenuEntry<ChannelTypeLabels>(
          value: entry, label: entry.label));
    }

    ChannelTypeLabels? selectedChannelType = ChannelTypeLabels.nucleus;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add new Channel:'),
        content: DropdownMenu<ChannelTypeLabels>(
          width: 230,
          initialSelection: ChannelTypeLabels.nucleus,
          controller: channelTypesController,
          leadingIcon: const Icon(Icons.layers_outlined),
          label: const Text('Channel type'),
          dropdownMenuEntries: channelTypesEntries,
          onSelected: (value) => selectedChannelType = value,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text('Okay'),
            onPressed: () {
              int idx = actChannels.length - 1;
              widget.parent.setState(() {
                switch (selectedChannelType) {
                  case ChannelTypeLabels.ev:
                    break;
                  case ChannelTypeLabels.background:
                    break;
                  case ChannelTypeLabels.nucleus:
                    actChannels.insert(
                        idx,
                        ChannelSettingExplicite(
                          key: UniqueKey(),
                          scroll: globalCardControllervertical,
                          parent: widget.parent,
                          channelType: ChannelTypeLabels.nucleus,
                        ));
                    break;
                  case ChannelTypeLabels.cell:
                    actChannels.insert(
                        idx,
                        ChannelSettingExplicite(
                          key: UniqueKey(),
                          scroll: globalCardControllervertical,
                          parent: widget.parent,
                          channelType: ChannelTypeLabels.cell,
                        ));
                    break;

                  default:
                    break;
                }
                addChannelButtonStateWidget?.setState(() {});
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  ///
  /// \brief Open analysis dialog
  ///
  void startAnalyzeDialog(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (_) {
          return dialogAnalyze;
        });
  }

  void _onFileSelectionChanged(String newSettingsFile) {
    newSelectedJsonSettingsFile = newSettingsFile;
  }

  void _updateSelectedJsonSettingsFile(String path) async {
    final newJsonFilePath = path;
    try {
      final settings = await getSettingsConfig(newJsonFilePath);
      loadFromAnalyzeSettings(settings);
    } catch (e) {}

    setState(() {});
  }

  void showOpenFileDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select json file'),
        content: OpenFolderDialog(
          isSelectionMode: true,
          onSelectionChange: _onFileSelectionChanged,
          selectedElement: newSelectedJsonSettingsFile,
          fileExtensions: [".json"],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text('Okay'),
            onPressed: () {
              _updateSelectedJsonSettingsFile(newSelectedJsonSettingsFile!);
              addChannelButtonStateWidget?.setState(() {});
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Theme.of(context).colorScheme.background,
                child: SizedBox(
                    child: Center(
                        child: Column(children: [
                  //
                  // Add channel button
                  //
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 60,
                        child: FloatingActionButton(
                          onPressed: () {
                            openAddChannelDialog(context);
                          },
                          tooltip: "Add channel",
                          child: const Icon(Icons.add),
                        ),
                      )),

                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 60,
                        child: FloatingActionButton(
                          onPressed: () {
                            showOpenFileDialog();
                          },
                          tooltip: "Open settings",
                          child: const Icon(Icons.folder_open_outlined),
                        ),
                      )),
                  Visibility(
                      visible: actChannels.length <= 1,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                              "Click the + button to add a channel\nor the folder to open existing settings.",
                              style: textTheme.bodyLarge))),
                  Visibility(
                      visible: actChannels.length > 1,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 60,
                            child: FloatingActionButton(
                              onPressed: () {
                                storeSettingsToLocalFile();
                              },
                              tooltip: "Save settings",
                              child: const Icon(Icons.save_as_outlined),
                            ),
                          ))),
                  //
                  // Start analyzes button
                  //
                  Visibility(
                      visible: actChannels.length > 1,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 60,
                            child: FloatingActionButton(
                              onPressed: () {
                                startAnalyzeDialog(context);
                              },
                              tooltip: "Start analyze",
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.play_arrow),
                            ),
                          )))
                ]))))));
  }
}
