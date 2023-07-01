import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/screens/screen_channels.dart';
import '../channel/channel.dart';
import '../channel/channel_enums.dart';
import '../logic/analyzer_settings.dart';
import '../logic/backend_communication.dart';

enum AnalyzeState { STOPPED, STOPPING, STARTING, RUNNING }

TextEditingController inputFolder = new TextEditingController();
TextEditingController cpus = TextEditingController(text: "1");

TextEditingController PostProcessingScriptController = TextEditingController();
PostProcessingScript? selectedPostProcessingScript =
    PostProcessingScript.liner_regression;

TextEditingController pipelinesController = TextEditingController();
Functions? selectedPipeline = Functions.count;

class ScreenAnalysis extends StatefulWidget {
  @override
  _ScreenAnalysis createState() => new _ScreenAnalysis();
}

class _ScreenAnalysis extends State<ScreenAnalysis>
    with AutomaticKeepAliveClientMixin<ScreenAnalysis> {
  double _progressAll = 0;
  double _progressImage = 0;
  AnalyzeState _state = AnalyzeState.STOPPED;
  String activeFolder = "/";
  final ScrollController scrollVert = ScrollController();
  String _progressImageString = "-";
  String _progressAllString = "-";

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ///
  /// Dropdown entries
  final List<DropdownMenuEntry<Functions>> pipelinesentries =
      <DropdownMenuEntry<Functions>>[];

  final List<DropdownMenuEntry<Channel>> dropDownChannels =
      <DropdownMenuEntry<Channel>>[];


  final List<DropdownMenuEntry<PostProcessingScript>>
      PostProcessingScriptEntries = <DropdownMenuEntry<PostProcessingScript>>[];

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

  ///
  /// Get the sctual status
  ///
  Timer? _timer;
  void startTimer() {
    const duration = Duration(seconds: 3);
    _timer = Timer.periodic(duration, (Timer timer) {
      updateStatus();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  ///
  /// Update the analyze status
  ///
  void updateStatus() {
    getAnalyzeStatus().then((value) {
      print("VAL: $value");

      if (value["status"] == "RUNNING") {
        double imagesTotal = value["total"]["total"];
        double imagesTotalFinished = value["total"]["finished"];

        double actImagesTotal = value["actual_image"]["total"];
        double actImagesTotalFinished = value["actual_image"]["finished"];

        double progressAll = 0;
        if (imagesTotal > 0) {
          progressAll = imagesTotalFinished / imagesTotal;
        }
        double progressImage = 0;
        if (actImagesTotal > 0) {
          progressImage = actImagesTotalFinished / actImagesTotal;
        }
        _updateProgress(progressImage, progressAll);
        _updateState(AnalyzeState.RUNNING);

        setState(() {
          _progressAllString = "Images: $imagesTotalFinished / $imagesTotal";
          _progressImageString =
              "Tiles: $actImagesTotalFinished / $actImagesTotal";
        });
      }
      if (value["status"] == "FINISHED") {
        _updateProgress(0, 0);
        _updateState(AnalyzeState.STOPPED);

        setState(() {
          _progressImageString = "";
          _progressAllString = "";
        });
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

  ///
  ///
  ///
  @override
  void initState() {
    startTimer();
    for (final Functions entry in Functions.values) {
      pipelinesentries
          .add(DropdownMenuEntry<Functions>(value: entry, label: entry.label));
    }
updateChannelSelections();

    for (final PostProcessingScript entry in PostProcessingScript.values) {
      PostProcessingScriptEntries.add(DropdownMenuEntry<PostProcessingScript>(
          value: entry, label: entry.label));
    }
    updateStatus();
    super.initState();
  }


  void updateChannelSelections()
  {
    for (final Channel entry in actChannels) {
      dropDownChannels
          .add(DropdownMenuEntry<Channel>(value: entry, label: entry.getNameAndIndex()));
    }
  }


  @override
  void dispose() {
    super.dispose();
    stopTimer();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    Wrap(
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              //width: 350,
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: DropdownMenu<Channel>(
                                    enabled: _state == AnalyzeState.STOPPED
                                        ? true
                                        : false,
                                    //width: 330,
                                   // initialSelection: dropDownChannels,
                                    controller: pipelinesController,
                                    leadingIcon:
                                        const Icon(Icons.functions_outlined),
                                    label: const Text('Function'),
                                    helperText: "Select analyzes function.",
                                    dropdownMenuEntries: dropDownChannels,
                                    onSelected: (value) =>
                                        //selectedPipeline = value,
                                        print("")
                                  ))),
                          
                                                    SizedBox(
                              //width: 350,
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: DropdownMenu<Functions>(
                                    enabled: _state == AnalyzeState.STOPPED
                                        ? true
                                        : false,
                                    //width: 330,
                                    initialSelection: selectedPipeline,
                                    controller: pipelinesController,
                                    leadingIcon:
                                        const Icon(Icons.functions_outlined),
                                    label: const Text('Function'),
                                    helperText: "Select analyzes function.",
                                    dropdownMenuEntries: pipelinesentries,
                                    onSelected: (value) =>
                                        selectedPipeline = value,
                                  ))),
                          
                          
                          
                          
                          
                          SizedBox(
                              //width: 350,
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: DropdownMenu<PostProcessingScript>(
                                    enabled: _state == AnalyzeState.STOPPED
                                        ? true
                                        : false,
                                    //width: 330,
                                    initialSelection:
                                        selectedPostProcessingScript,
                                    controller: PostProcessingScriptController,
                                    leadingIcon: const Icon(
                                        Icons.stacked_bar_chart_outlined),
                                    label: const Text('Analytics'),
                                    helperText: "Add post processing script.",
                                    dropdownMenuEntries:
                                        PostProcessingScriptEntries,
                                    onSelected: (value) =>
                                        selectedPostProcessingScript = value,
                                  ))),
                          SizedBox(
                            width: 250,
                            height: 95,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: TextField(
                                enabled: _state == AnalyzeState.STOPPED
                                    ? true
                                    : false,
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
                                    prefixIcon:
                                        const Icon(Icons.memory_outlined),
                                    border: OutlineInputBorder(),
                                    labelText: 'CPUs',
                                    suffixText: '',
                                    hintText: '[0-65536]',
                                    helperText: 'Number of CPUs to use.'),
                              ),
                            ),
                          ),
                        ]),
                    CustomDivider(
                      text: "",
                      paddingTop: 20,
                      paddingBottom: 20,
                    ),
                    Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: FilledButton(
                            onPressed: _isEnabled()
                                ? () {
                                    if (_state == AnalyzeState.STOPPED) {
                                      _updateState(AnalyzeState.STARTING);
                                      var promise = startAnalyze(
                                          generateAnalyzeSettings(
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
                        )
                      ],
                    ),
                    Center(child: Text(_progressImageString)),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: _progressImage,
                          semanticsLabel: 'progress per image',
                        )),
                    Center(child: Text(_progressAllString)),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                        child: LinearProgressIndicator(
                          minHeight: 15,
                          value: _progressAll,
                          semanticsLabel: 'total progress',
                        )),
                  ],
                ))),
      ),
    );
  }
}

///
/// \brief Open folder dialog
///
///
class OpenFolderDialog extends StatefulWidget {
  OpenFolderDialog(
      {super.key,
      required this.selectedElement,
      required this.isSelectionMode,
      required this.onSelectionChange,
      required this.fileExtensions});

  final bool isSelectionMode;
  String activeFolder = "";
  String selectedElement;
  final List<bool> selectedList = [false, false];
  final List<(String, String)> directoriesEntries = [];
  final Function(String)? onSelectionChange;
  final List<String> fileExtensions;

  Future<void> setListParameters() async {
    final (directories, files, homePath) =
        await listFolders(activeFolder, fileExtensions);
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

    for (final String entry in files) {
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
  State<OpenFolderDialog> createState() => _OpenFolderDialogState();
}

class _OpenFolderDialogState extends State<OpenFolderDialog> {
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

  void _onActiveFolderChanged(String newFolder) {
    setState(() {});
  }

  final ScrollController listViewScrollController = ScrollController();
  final double listItemHeight = 45;

  @override
  void initState() {
    super.initState();

    if (!widget.selectedElement.isEmpty) {
      String firstEntry = widget.selectedElement;
      if (firstEntry.lastIndexOf("/") > 0) {
        firstEntry = firstEntry.substring(0, firstEntry.lastIndexOf("/"));
      } else {
        firstEntry = "/";
      }
      widget.activeFolder = firstEntry;
    }
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
    return Column(
      children: [
        Text(widget.activeFolder),
        Expanded(
          child: Container(
            width: 350,
            child: Scrollbar(
              controller: listViewScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                  controller: listViewScrollController,
                  itemCount: widget.directoriesEntries.length,
                  shrinkWrap: true,
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
                                      for (int n = 0;
                                          n < widget.selectedList.length;
                                          n++)
                                        {
                                          widget.selectedList[n] = false,
                                        },
                                      _toggle(index),
                                      if (true == x)
                                        {
                                          widget.onSelectionChange!(widget
                                              .directoriesEntries[index].$2)
                                        }
                                    },
                                  )
                                : const SizedBox.shrink(),
                            title: Text(widget.directoriesEntries[index].$1)));
                  }),
            ),
          ),
        )
      ],
    );
  }
}
