// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_util';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/channel_common.dart';
import '../channel/channel_ev.dart';
import '../channel/channel_nucleus.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
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

  @override
  State<AddChannelButton> createState() => _AddChannelButton();
}

class _AddChannelButton extends State<AddChannelButton>
    with TickerProviderStateMixin {
  late AnimationController progressAll;
  late AnimationController progressImage;

  @override
  void initState() {
    addChannelButtonStateWidget = this;

    progressAll = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    progressAll.repeat();

    progressImage = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    progressImage.repeat();

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

    ChannelTypeLabels? selectedChannelType = ChannelTypeLabels.ev;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add new Channel:'),
        content: DropdownMenu<ChannelTypeLabels>(
          width: 230,
          initialSelection: ChannelTypeLabels.ev,
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

  final ScrollController scrollVert = ScrollController();

  ///
  /// \brief Open analysis dialog
  ///
  void startAnalyzeDialog(BuildContext context) {
    ///
    /// Channel labels
    final TextEditingController pipelinesController = TextEditingController();
    final List<DropdownMenuEntry<Pipelines>> pipelinesentries =
        <DropdownMenuEntry<Pipelines>>[];
    for (final Pipelines entry in Pipelines.values) {
      pipelinesentries
          .add(DropdownMenuEntry<Pipelines>(value: entry, label: entry.label));
    }

    Pipelines? selectedPipeline = Pipelines.count;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Scaffold(
                body: Scrollbar(
                    thickness: 10,
                    //thumbVisibility: true,
                    interactive: true,
                    controller: scrollVert,
                    child: SingleChildScrollView(
                        controller: scrollVert,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextField(
                                  obscureText: false,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.folder_open_outlined),
                                      border: OutlineInputBorder(),
                                      labelText: 'Input folder',
                                      suffixText: '',
                                      hintText: '/home/user/images/',
                                      helperText:
                                          'Folder where your images are stored in.'),
                                )),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: SizedBox(
                                  child: TextField(
                                    controller: TextEditingController()
                                      ..text = '1',
                                    obscureText: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                      RangeTextInputFormatter(
                                          min: 1, max: 65536)
                                    ],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                        prefixIcon:
                                            const Icon(Icons.memory_outlined),
                                        border: OutlineInputBorder(),
                                        labelText: 'CPUs',
                                        suffixText: '',
                                        hintText: '[0-65536]',
                                        helperText: 'Number of CPUs to use.'),
                                  ),
                                )),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: DropdownMenu<Pipelines>(
                                  initialSelection: Pipelines.count,
                                  controller: pipelinesController,
                                  leadingIcon:
                                      const Icon(Icons.functions_outlined),
                                  label: const Text('Pipeline'),
                                  dropdownMenuEntries: pipelinesentries,
                                  onSelected: (value) =>
                                      selectedPipeline = value,
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: FilledButton(
                                onPressed: () {
                                 //startAnalyze();
                                },
                                style: FilledButton.styleFrom(
                                    //  backgroundColor: Theme.of(context).colorScheme.error),
                                    backgroundColor: Colors.green),
                                child: const Text('Start'),
                              ),
                            ),
                            CustomDivider(),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 2),
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  value: progressAll.value,
                                  semanticsLabel: 'Linear progress indicator',
                                )),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 2, 20, 10),
                                child: LinearProgressIndicator(
                                  minHeight: 15,
                                  value: progressImage.value,
                                  semanticsLabel: 'Linear progress indicator',
                                )),
                          ],
                        ))),
            appBar: AppBar(
              title: const Text('Analyze'),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
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
