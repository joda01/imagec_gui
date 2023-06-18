// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../channel/channel_common.dart';
import '../channel/channel_ev.dart';
import '../channel/channel_nucleus.dart';
import '../dialogs/dialog_analyze.dart';

DialogAnalyze dialogAnalyze = DialogAnalyze();
const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class ScreenAnalyze extends StatelessWidget {
  const ScreenAnalyze({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    Widget title() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text("Welcome", style: textTheme.displayLarge!),
      );
    }

    Widget footer() => RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              const TextSpan(
                  text:
                      'Copyright 2023 J.D | many thanks to Melanie Schuerz and Anna Mueller | '),
              TextSpan(
                text: 'imagec.org',
                style: const TextStyle(decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final url = Uri.parse(
                      'https://www.imagec.org',
                    );
                  },
              ),
              const TextSpan(text: ''),
            ],
          ),
        );

    Widget expander() {
      return Expanded(
          child: Container(alignment: Alignment.bottomCenter, child: footer()));
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return ChannelRow();
    });
  }
}

class ChannelRow extends StatefulWidget {
  const ChannelRow({super.key});

  @override
  State<ChannelRow> createState() => _ChannelRow();
}

class _ChannelRow extends State<ChannelRow>
    with AutomaticKeepAliveClientMixin<ChannelRow> {
  final ScrollController controllerHorizontal = ScrollController();

  @override
  void initState() {
    super.initState();
    actChannels.add(new AddChannelButton(
      scroll: globalCardControllervertical,
      parent: this,
    ));
  }

  void _updateFolderPath(String path) {
    setState(() {
      inputFolder.text = path;
    });
  }

  void _onSelectionChange(String newFolder) {
    newSelectedFolder = newFolder;
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
            selectedElement: newSelectedFolder),
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
    return Expanded(
      child: Column(
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
      ),
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
  void openDialog(BuildContext context) {
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
                    actChannels.insert(
                        idx,
                        ChannelSettingEV(
                          key: UniqueKey(),
                          scroll: globalCardControllervertical,
                          parent: widget.parent,
                        ));
                    break;
                  case ChannelTypeLabels.background:
                    break;
                  case ChannelTypeLabels.nucleus:
                    actChannels.insert(
                        idx,
                        ChannelSettingNucleus(
                          key: UniqueKey(),
                          scroll: globalCardControllervertical,
                          parent: widget.parent,
                        ));
                    break;
                  case ChannelTypeLabels.cell:
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
                            openDialog(context);
                          },
                          tooltip: "Add channel",
                          child: const Icon(Icons.add),
                        ),
                      )),
                  Visibility(
                      visible: actChannels.length <= 1,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Click the + button to add a channel.",
                              style: textTheme.bodyLarge))),

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
