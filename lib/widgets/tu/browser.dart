import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/functions.dart';

class MyInAppBrowser extends InAppBrowser {
  final Function(MyInAppBrowser browser, int progress)? onProgress;
  final Function(Uri? uri)? onLoad;

  MyInAppBrowser({this.onProgress, this.onLoad});

  @override
  Future onBrowserCreated() async {
    clog("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    clog("Started $url");
    if (onLoad != null) {
      onLoad!(url);
    }
  }

  @override
  Future onLoadStop(url) async {
    clog("Stopped $url");
    //if (onLoad != null) {
    //  onLoad!(url);
    //}
  }

  @override
  void onLoadError(url, code, message) {
    clog("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    clog("Progress: $progress");
    if (onProgress != null) {
      onProgress!(this, progress);
    }
  }

  @override
  void onExit() {
    clog("Browser closed!");
  }
}
