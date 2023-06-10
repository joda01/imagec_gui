import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:js_util';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/channel_common.dart';
import '../channel/channel_ev.dart';
import '../channel/channel_nucleus.dart';
import '../logic/analyzer_settings.dart';
import '../logic/backend_communication.dart';
import 'dart:html' as html;

enum AnalyzeState { STOPPED, STOPPING, STARTING, RUNNING }

TextEditingController inputFolder = new TextEditingController();
TextEditingController cpus = TextEditingController(text: "1");
TextEditingController pipelinesController = TextEditingController();
Pipelines? selectedPipeline = Pipelines.count;

  String selectedFolder = "";
  String newSelectedFolder = "";

class DialogAnalyze extends StatefulWidget {
  @override
  _DialogAnalyze createState() => new _DialogAnalyze();
}

class _DialogAnalyze extends State<DialogAnalyze>
    with AutomaticKeepAliveClientMixin<DialogAnalyze> {
  double _progressAll = 0;
  double _progressImage = 0;
  AnalyzeState _state = AnalyzeState.STOPPED;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ///
  /// Channel labels
  final List<DropdownMenuEntry<Pipelines>> pipelinesentries =
      <DropdownMenuEntry<Pipelines>>[];

  void _updateProgress(double perImage, double total) {
    setState(() {
      _progressImage = perImage;
      _progressAll = total;
    });
  }

  void _updateState(AnalyzeState state) {
    if (_state != state) {
      setState(() {
        _state = state;
      });
    }
  }

  void _updateFolderPath(String path) {
    setState(() {
      inputFolder.text = path;
    });
  }

  ///
  /// Get the sctual status
  ///
  Timer? _timer;
  void startTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer timer) {
      updateStatus();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void updateStatus() {
    getAnalyzeStatus().then((value) {
      print("VAL: $value");

      if (value["status"] == "RUNNING") {
        double imagesTotal = value["total"]["total"];
        double imagesTotalFinished = value["total"]["finished"];

        double actImagesTotal = value["actual_image"]["total"];
        double actImagesTotalFinished = value["actual_image"]["finished"];
        double progressAll = imagesTotalFinished / imagesTotal;
        double progressImage = actImagesTotalFinished / actImagesTotal;

        _updateProgress(progressImage, progressAll);
        _updateState(AnalyzeState.RUNNING);
      }
      if (value["status"] == "FINISHED") {
        _updateProgress(0, 0);
        _updateState(AnalyzeState.STOPPED);
      }
    });
  }

  ///
  ///
  ///
  Color _getButtonColor() {
    if (_state == AnalyzeState.STOPPED) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  ///
  ///
  ///
  Text _getButtonText() {
    if (_state == AnalyzeState.STOPPED) {
      return Text("Start");
    } else if (_state == AnalyzeState.STOPPING) {
      return Text("Stopping");
    } else {
      return Text("Stop");
    }
  }

  ///
  ///
  ///
  bool _isEnabled() {
    if (_state == AnalyzeState.STOPPING) {
      return false;
    } else {
      return true;
    }
  }

  final ScrollController scrollVert = ScrollController();

  @override
  void initState() {
    startTimer();
    for (final Pipelines entry in Pipelines.values) {
      pipelinesentries
          .add(DropdownMenuEntry<Pipelines>(value: entry, label: entry.label));
    }
    updateStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    stopTimer();
  }



  void onSelectionChange(String newFolder) {
    newSelectedFolder = newFolder;
  }

  void showOpenFolderDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select directory'),
        content: SizedBox(
            width: 300,
            height: 300,
            child: ListBuilder(
                isSelectionMode: true,
                onSelectionChange: onSelectionChange,
                selectedElement: newSelectedFolder)),
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
    return Dialog.fullscreen(
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
                            controller: inputFolder,
                            onTap: showOpenFolderDialog,
                            decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.folder_open_outlined),
                                border: OutlineInputBorder(),
                                labelText: 'Input folder',
                                suffixText: '',
                                hintText: '/home/user/images/',
                                helperText:
                                    'Folder where your images are stored in.'),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: SizedBox(
                            child: TextField(
                              controller: cpus,
                              obscureText: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                                RangeTextInputFormatter(min: 1, max: 65536)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.memory_outlined),
                                  border: OutlineInputBorder(),
                                  labelText: 'CPUs',
                                  suffixText: '',
                                  hintText: '[0-65536]',
                                  helperText: 'Number of CPUs to use.'),
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: DropdownMenu<Pipelines>(
                            initialSelection: selectedPipeline,
                            controller: pipelinesController,
                            leadingIcon: const Icon(Icons.functions_outlined),
                            label: const Text('Pipeline'),
                            dropdownMenuEntries: pipelinesentries,
                            onSelected: (value) => selectedPipeline = value,
                          )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: FilledButton(
                          onPressed: _isEnabled()
                              ? () {
                                  if (_state == AnalyzeState.STOPPED) {
                                    _updateState(AnalyzeState.STARTING);
                                    var promise = startAnalyze(
                                        generateAnalyzeSettings(
                                            selectedPipeline!.value,
                                            inputFolder.text));
                                  } else {
                                    _updateState(AnalyzeState.STOPPING);
                                    var promise = stopAnalyze();
                                  }
                                }
                              : null,
                          style: FilledButton.styleFrom(
                              //  backgroundColor: Theme.of(context).colorScheme.error),
                              backgroundColor: _getButtonColor()),
                          child: _getButtonText(),
                        ),
                      ),
                      CustomDivider(),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: _progressImage,
                            semanticsLabel: 'Linear progress indicator',
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                          child: LinearProgressIndicator(
                            minHeight: 15,
                            value: _progressAll,
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
    );
  }
}

class ListBuilder extends StatefulWidget {
  ListBuilder({
    super.key,
    required this.selectedElement,
    required this.isSelectionMode,
    required this.onSelectionChange,
  });

  final bool isSelectionMode;
  String activeFolder = "";
  String selectedElement;
  final List<bool> selectedList = [false, false];
  final List<(String, String)> directoriesEntries = [];
  final Function(String)? onSelectionChange;

  Future<void> setListParameters() async {
    final (directories, homePath) = await listFolders(activeFolder);

    directoriesEntries.clear();
    selectedList.clear();

    if (activeFolder.isEmpty) {
      activeFolder = homePath;
    }

    String firstEntry = activeFolder;
    if (firstEntry.lastIndexOf("/") > 0) {
      firstEntry = firstEntry.substring(0, firstEntry.lastIndexOf("/"));
      // firstEntry = firstEntry.substring(0, firstEntry.lastIndexOf("/"));
    } else {
      // We reached the root path
      firstEntry = "/";
    }

    directoriesEntries.add(("..", firstEntry));
    selectedList.add(false);

    for (final String entry in directories) {
      String folderName = entry;
      folderName = entry.substring(entry.lastIndexOf("/") + 1);
      
      // Do not add hidden folder to the list
      if (!folderName.startsWith(".")) {
        directoriesEntries.add((folderName, entry));
        selectedList.add(false);
      }
    }
  }

  @override
  State<ListBuilder> createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
  void _toggle(int index) {
    if (widget.isSelectionMode) {
      setState(() {
        widget.selectedList[index] = !widget.selectedList[index];
      });
    }
  }

  void updateList() {
    final f = widget.setListParameters();
    f.then((value) {
      setState(() {});
    });
  }

  final ScrollController listViewScrollController = ScrollController();
  final double listItemHeight = 45;

  @override
  void initState() {
    super.initState();

    String firstEntry = widget.selectedElement;
    if (firstEntry.lastIndexOf("/") > 0) {
      firstEntry = firstEntry.substring(0, firstEntry.lastIndexOf("/"));
    } else {
      firstEntry = "/";
    }

    widget.activeFolder = firstEntry;
    final f = widget.setListParameters();
    f.then((value) {
      for (int n = 0; n < widget.directoriesEntries.length; n++) {
        if (widget.directoriesEntries[n].$2 == widget.selectedElement) {
          widget.selectedList[n] = true;
          listViewScrollController.jumpTo(n * listItemHeight);
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: listViewScrollController,
        itemCount: widget.directoriesEntries.length,
        itemBuilder: (_, int index) {
          return SizedBox(
              height: listItemHeight,
              child: ListTile(
                  onTap: () => {
                        _toggle(index),
                        widget.activeFolder =
                            widget.directoriesEntries[index].$2,
                        updateList()
                      },
                  onLongPress: () {
                    if (!widget.isSelectionMode) {
                      setState(() {
                        widget.selectedList[index] = true;
                      });
                      widget.onSelectionChange!(
                          widget.directoriesEntries[index].$2);
                    }
                  },
                  trailing: widget.isSelectionMode && index > 0
                      ? Checkbox(
                          value: widget.selectedList[index],
                          onChanged: (bool? x) => {
                            for (int n = 0; n < widget.selectedList.length; n++)
                              {
                                widget.selectedList[n] = false,
                              },
                            _toggle(index),
                            if (true == x)
                              {
                                widget.onSelectionChange!(
                                    widget.directoriesEntries[index].$2)
                              }
                          },
                        )
                      : const SizedBox.shrink(),
                  title: Text(widget.directoriesEntries[index].$1)));
        });
  }
}
