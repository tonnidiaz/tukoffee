// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common3.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class TuUpdate {
  final String version;
  final List notes;
  final String? date;
  const TuUpdate({required this.version, this.notes = const [], this.date});
}

class UpdatesView2 extends StatefulWidget {
  final Map<String, dynamic>? update;
  const UpdatesView2({super.key, this.update});

  @override
  State<UpdatesView2> createState() => _UpdatesView2State();
}

class _UpdatesView2State extends State<UpdatesView2> {
  final _appCtrl = MainApp.appCtrl;
  bool _isUpToDate = false;
  bool _isUpdating = false;
  final ReceivePort _port = ReceivePort();

  dynamic _status = "";
  String? _taskId;
  int _progress = 0;
  Map<String, dynamic>? _update;
  _setUpdate(Map<String, dynamic>? val) {
    setState(() {
      _update = val;
    });
  }

  _initFlutterDownloader() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      //This is where you handle the outcome/progress
      String id = data[0];
      int progress = data[2];

      setState(() {
        _progress = progress;
        _status = data[1];
      });

      if (progress == 100) {
        //Finished downloading
        clog("Opening file");
        FlutterDownloader.open(taskId: _taskId!);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  _checkUpdate() async {
    try {
      setState(() {
        _isUpToDate = false;
        _isUpdating = false;
        _update = null;
      });
      clog("$localhost:3000");
      final res = await dio
          .get("$localhost:3000/api/app/updates/check", queryParameters: {
        "uid": "com.tb.tukoffee", //TODO: Real app id
        "v": await getAppVersion()
      });
      clog(res.data);
      if (res.data.runtimeType == String) {
        setState(() {
          _isUpToDate = true;
        });
      }
      _setUpdate(res.data);
      /*   const TuUpdate(version: '0.1.2', notes: [
          "Fix Landscape dialog not showing error",
          "Added rate app feature"
        ]), */
    } catch (e) {
      clog(e);
      errorHandler(context: context, e: e, msg: "Failed to check updates");
      setState(() {
        _isUpToDate = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initFlutterDownloader();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      if (widget.update == null) {
        _checkUpdate();
      } else {
        _setUpdate(widget.update);
      }
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      contentPadding:
          const EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 5),
      content: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          //alignment: Alignment.topCenter,
          constraints: const BoxConstraints(minHeight: 30, maxHeight: 200),
          child: tuColumn(min: true, children: [
            _isUpdating
                ? tuColumn(min: true, children: [
                    Text(_progress < 100
                        ? "Fetching updates..."
                        : "Launching installer..."),
                    mY(4),
                    LinearProgressIndicator(
                      value: _progress / 100,
                    )
                  ])
                : _update == null
                    ? const Text("Checking updates...")
                    : _isUpToDate
                        ? Column(
                            children: [
                              Text(
                                "Version up-to-date",
                                textAlign: TextAlign.center,
                                style: Styles.cardTitle,
                              ),
                            ],
                          )
                        : Expanded(
                            child: tuColumn(children: [
                              Text(
                                "Update available",
                                style: Styles.cardTitle,
                              ),
                              mY(10),
                              tuRow(children: [
                                const Text("Version"),
                                Text(_update!["version"]),
                              ]),
                              mY(10),
                              const Text(
                                "Release notes:",
                                style: TextStyle(fontSize: 17),
                              ),
                              mY(5),
                              Visibility(
                                visible: true,
                                child: Expanded(
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                        itemCount: _update?["notes"].length,
                                        itemBuilder: (context, index) {
                                          var note = _update?["notes"][index];
                                          return Container(
                                            padding: defaultPadding,
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.black12,
                                                        width: 1.7))),
                                            child: Text(
                                              note,
                                              //style: const TextStyle(fontSize: 13),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              )
                            ]),
                          )
          ]),
        ),
      ),
      actions: [
        Visibility(
          visible: _update != null,
          child: IconButton(
            //text: "Check",
            onPressed: () async {
              await _checkUpdate();
            },
            //text: "Check",
            icon: const Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
          ),
        ),
        Visibility(
          visible: _update != null && !_isUpToDate,
          child: TuButton(
            text: "Update now",
            width: 150,
            height: 35,
            onPressed: () async {
              await _downloadUpdate();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _downloadUpdate() async {
    // _checkUpdates();
    try {
      await requestPermissions();
      setState(() {
        _isUpdating = true;
        _progress = 0;
      });
      final dir = await getExternalStorageDirectory();

      final dirPath = '${dir?.path}/Downloads/APKs';
      final pdir = Directory(dirPath);
      if (!pdir.existsSync()) {
        clog("Creating directory");
        pdir.createSync(recursive: true);
      }
      clog(dirPath);
      final fileName =
          "${_appCtrl.store['name']}-${DateTime.now().millisecondsSinceEpoch}-v${_update!['version']}.apk";
      final taskId = await FlutterDownloader.enqueue(
        url: _update!['file'],
        //"https://github.com/tonnidiaz/tunedapps/releases/download/taudmod-v0.1.0/taudmod-v0.1.0.apk",
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: dirPath,
        fileName: fileName,
        saveInPublicStorage: true,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      setState(() {
        _taskId = taskId;
      });
    } catch (e) {
      clog(e);
      setState(() {
        _isUpdating = false;
      });
    }
  }
}
