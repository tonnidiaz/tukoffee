import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/functions.dart';
import "package:via_logger/logger.dart";

class MyInAppBrowser extends InAppBrowser {
  final Function(MyInAppBrowser browser, int progress)? onProgress;
  final Function(Uri? uri)? onLoad;

  MyInAppBrowser({this.onProgress, this.onLoad});

  @override
  Future onBrowserCreated() async {
    Logger.info("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    Logger.info("Started $url");
    if (onLoad != null) {
      onLoad!(url);
    }
  }

  @override
  Future onLoadStop(url) async {
    Logger.info("Stopped $url");
    //if (onLoad != null) {
    //  onLoad!(url);
    //}
  }

  @override
  void onLoadError(url, code, message) {
    Logger.info("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    Logger.info("Progress: $progress");
    if (onProgress != null) {
      onProgress!(this, progress);
    }
  }

  @override
  void onExit() {
    Logger.info("Browser closed!");
  }
}
