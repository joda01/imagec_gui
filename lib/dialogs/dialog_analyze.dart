import 'dart:async';
import 'dart:convert';
import 'dart:js_util';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/channel_common.dart';
import '../channel/channel_ev.dart';
import '../channel/channel_nucleus.dart';
import '../logic/analyzer_settings.dart';
import '../logic/backend_communication.dart';

enum AnalyzeState { STOPPED, STOPPING, STARTING, RUNNING }

class DialogAnalyze extends StatefulWidget {
  @override
  _DialogAnalyze createState() => new _DialogAnalyze();
}

class _DialogAnalyze extends State<DialogAnalyze> {
  double _progressAll = 0;
  double _progressImage = 0;
  AnalyzeState _state = AnalyzeState.STOPPED;

  ///
  /// Channel labels
  final TextEditingController pipelinesController = TextEditingController();
  final List<DropdownMenuEntry<Pipelines>> pipelinesentries =
      <DropdownMenuEntry<Pipelines>>[];

  TextEditingController inputFolder = new TextEditingController();
  Pipelines? selectedPipeline = Pipelines.count;

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
  void getStatusTimer() {
    const duration = Duration(seconds: 1);
    Timer _timer;
    _timer = Timer.periodic(duration, (Timer timer) {
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
    getStatusTimer();

    for (final Pipelines entry in Pipelines.values) {
      pipelinesentries
          .add(DropdownMenuEntry<Pipelines>(value: entry, label: entry.label));
    }

    super.initState();
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
                              controller: TextEditingController()..text = '1',
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
                            initialSelection: Pipelines.count,
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
