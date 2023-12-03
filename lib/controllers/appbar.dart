import "package:flutter/material.dart";
import "package:get/get.dart";

class AppBarCtrl extends GetxController {
  RxList<dynamic> selected = <dynamic>[].obs;
  setSelected(List<dynamic> val) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selected.value = val;
    });
  }

  RxList<PopupMenuItem> selectedActions = <PopupMenuItem>[].obs;
  setSelectedActions(List<PopupMenuItem> val) {
    selectedActions.value = val;
  }
}
