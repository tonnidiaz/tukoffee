import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:path_provider/path_provider.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  final _appCtrl = MainApp.appCtrl;
  final ReceivePort _port = ReceivePort();

  dynamic _status = "";
  String? _taskId;
  int _progress = 0;
  int? _updates;
  _setUpdates(int? val) {
    setState(() {
      _updates = val;
    });
  }

  _checkUpdates() async {
    _setUpdates(null);
    await Future.delayed(Duration(seconds: 3));
    _setUpdates(4);
  }

  _init() async {
    _checkUpdates();
  }

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      //This is where you handle the outcome/progress
      String id = data[0];
      //DownloadTaskStatus status =  Download//DownloadTaskStatus(data[1]);
      int progress = data[2];

      setState(() {
        _progress = progress;
        _status = data[1];
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
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
    return PageWrapper(
      appBar: childAppbar(showCart: false, title: "Updates"),
      onRefresh: () async {
        await _checkUpdates();
      },
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(42, 42, 42, 1),
        onPressed: () async {
          // _checkUpdates();
          try {
            final dir = await getExternalStorageDirectory();

            final dirPath = '${dir?.path}/Downloads/APKs';
            final pdir = Directory(dirPath);
            if (!pdir.existsSync()) {
              clog("Creating directory");
              pdir.createSync(recursive: true);
            }
            clog(dirPath);
            final taskId = await FlutterDownloader.enqueue(
              url:
                  "https://github.com/tonnidiaz/tunedapps/releases/download/taudmod-v0.1.0/taudmod-v0.1.0.apk",
              headers: {}, // optional: header send with url (auth token etc)
              savedDir: dirPath,
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
          }
        },
        child: const Icon(Icons.refresh),
      ),
      child: Container(
        padding: defaultPadding2,
        width: double.infinity,
        height: screenSize(context).height -
            appBarH -
            statusBarH(context: context) -
            70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            false //_updates != null
                ? Column(
                    children: [
                      TuCard(
                          padding: 14,
                          child: Column(
                            children: [
                              tuTableRow(Text("Your version: "), Text("1.0.0")),
                              mY(5),
                              tuTableRow(
                                  Text("Latest version: "), Text("3.0.0")),
                              mY(5),
                              TuCard(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Release notes:",
                                    style: Styles.title(),
                                  ),
                                  mY(10),
                                  ...List.generate(
                                      4,
                                      (index) => iconText("Fixed issue $index",
                                          Icons.radio_button_unchecked,
                                          iconSize: 10,
                                          my: 2.5,
                                          alignment: MainAxisAlignment.start))
                                ],
                              )),
                              mY(5),
                              TextButton(
                                child: Text(
                                  "Update now",
                                  style: Styles.title(),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          )),
                    ],
                  )
                : Column(
                    children: [
                      Text("ID: $_taskId"),
                      Text("Progress: $_progress%"),
                      Text("Status: $_status"),
                      TuButton(
                        text: "Open file",
                        onPressed: () async {
                          try {
                            final r =
                                await FlutterDownloader.open(taskId: _taskId!);

                            clog(r);
                          } catch (e) {
                            clog("Failed to open file");
                            clog(e);
                          }
                        },
                      ),
                      Text(
                        "Checking updates",
                        style: Styles.title(),
                        textAlign: TextAlign.center,
                      ),
                      mY(5),
                      const LinearProgressIndicator(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
