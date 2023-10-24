import "package:get/get.dart";

class ProgressCtrl extends GetxController {
  Rxn<double> progress = Rxn();
  void setProgress(double? val) {
    progress.value = val;
  }
}
