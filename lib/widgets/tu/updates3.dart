import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/common4.dart';
import 'package:lebzcafe/widgets/dialogs/loading_dialog.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:path_provider/path_provider.dart';

class UpdatesView3 extends StatefulWidget {
  final Map<String, dynamic>? update;
  const UpdatesView3({super.key, required this.update});

  @override
  State<UpdatesView3> createState() => UpdatesView3State();
}

class UpdatesView3State extends State<UpdatesView3> {
  final _appCtrl = MainApp.appCtrl;
  final _ctrl = MainApp.progressCtrl;
  final ReceivePort _port = ReceivePort();

  String? _taskId;

  _initFlutterDownloader() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      //This is where you handle the outcome/progress
      int progress = data[2];
      clog(progress);
      _ctrl.setProgress(progress / 100);
      if (progress == 100) {
        //Finished downloading
        gpop(); //HIDE DOWNLOADER PROGRESS SHEET
        clog("Opening file");
        FlutterDownloader.open(taskId: _taskId!);
        // HIDE MAIN SHEET
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> _downloadUpdate() async {
    // _checkUpdates()
    //

    try {
      final hasPermission = await requestStoragePermission();
      clog("Has perm: $hasPermission");
      if (hasPermission == null || !hasPermission) {
        if (!context.mounted) return;
        showToast('Need to have storage permissions', isErr: true)
            .show(context);
        return;
      }

      _ctrl.setProgress(0);
      showProgressSheet(msg: "Downloading updates...", dismissable: true);

      final dir = await getExternalStorageDirectory();

      final dirPath = '${dir?.path}/Downloads/APKs';
      final pdir = Directory(dirPath);
      if (!pdir.existsSync()) {
        clog("Creating directory");
        pdir.createSync(recursive: true);
      }
      clog(dirPath);
      final fileName =
          "${_appCtrl.store['name']}-${DateTime.now().millisecondsSinceEpoch}-v${widget.update!['version']}.apk";

      final taskId = await FlutterDownloader.enqueue(
        url: widget.update!['file'],
        //"https://github.com/tonnidiaz/tunedapps/releases/download/taudmod-v0.1.0/taudmod-v0.1.0.apk",
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: dirPath,
        fileName: fileName,
        saveInPublicStorage: true,
        showNotification:
            false, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      setState(() {
        _taskId = taskId;
      });
    } catch (e) {
      clog(e);
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) _initFlutterDownloader();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {});
  }

  @override
  void dispose() {
    if (FlutterDownloader.initialized) {
      FlutterDownloader.cancelAll();
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding2,
      color: cardBGLight,
      child: widget.update == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                h4(
                  "Your version is up-to-date ✓",
                ),
              ],
            )
          : SingleChildScrollView(
              child: tuColumn(min: true, children: [
                h3('Updates available'),
                mY(8),
                tuTableRow(
                    Text("Version:"), Text("${widget.update!['version']}")),
                mY(10),
                Text(
                  "Release notes",
                  style: Styles.h4(),
                ),
                Padding(
                  padding: defaultPadding,
                  child: tuColumn(children: [
                    ...widget.update!['notes']
                        .map((e) => bulletItem(e))
                        .toList()
                  ]),
                ),
                TuButton(
                  bgColor: TuColors.success,
                  width: double.infinity,
                  text: "UPDATE NOW",
                  onPressed: () async {
                    //  gpop();
                    _downloadUpdate();
                  },
                )
              ]),
            ),
    );
  }
}
