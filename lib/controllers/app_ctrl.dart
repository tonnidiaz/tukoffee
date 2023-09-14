import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppCtrl extends GetxController {
  RxBool darkMode = false.obs;
  void setDarkMode(bool val) {
    darkMode.value = val;
  }

  RxBool serverDown = false.obs;
  void setserverDown(bool val) {
    serverDown.value = val;
  }

  RxMap<String, dynamic> location = <String, dynamic>{}.obs;
  setLocation(Map<String, dynamic> val) {
    location.value = val;
  }

  RxBool ready = false.obs;
  void setReady(bool val) {
    ready.value = val;
  }

  RxBool hasUpdates = false.obs;
  void sethasUpdates(bool val) {
    hasUpdates.value = val;
  }

  RxString deviceID = "".obs;
  void setDeviceID(String val) {
    deviceID.value = val;
  }

  RxString appVersion = "1.0.0".obs;
  void setappVersion(String val) {
    appVersion.value = val;
  }

  RxString developerLink = "https://thabiso.vercel.app".obs;
  void setDeveloperLink(String val) {
    developerLink.value = val;
  }

  RxString storeLink = "".obs;
  void setStoreLink(String val) {
    storeLink.value = val;
  }

  RxString title = "".obs;
  void setTitle(String val) {
    title.value = val;
  }

  RxString ownerName = "".obs;
  void setownerName(String val) {
    ownerName.value = val;
  }

  RxString storeName = "".obs;
  void setstoreName(String val) {
    storeName.value = val;
  }

  RxString storeSite = "".obs;
  void setstoreSite(String val) {
    storeSite.value = val;
  }

  RxString developerSite = "".obs;
  void setdeveloperSite(String val) {
    developerSite.value = val;
  }

  RxString ownerPhone = "".obs;
  void setownerPhone(String val) {
    ownerPhone.value = val;
  }

  RxString storePhone = "".obs;
  void setStorePhone(String val) {
    storePhone.value = val;
  }

  RxMap<String, dynamic> storeAddress = <String, dynamic>{}.obs;
  setStoreAddress(Map<String, dynamic> val) {
    storeAddress.value = val;
  }

  RxMap<String, dynamic> storeImage = <String, dynamic>{}.obs;
  setStoreImage(Map<String, dynamic> val) {
    storeImage.value = val;
  }

  RxBool isAdmin = false.obs;
  var user = <dynamic, dynamic>{}.obs;
  void setUser(Map<dynamic, dynamic> val) {
    user.value = val;
    var perms = val['permissions'];
    bool isAdmin = perms == 1 || perms == 2;
    this.isAdmin.value = isAdmin;
  }

  RxBool isLoading = false.obs;
  void setIsLoading(bool val) {
    isLoading.value = val;
    backEnabled.value = !val;
  }

  RxBool backEnabled = true.obs;
  void setBackEnabled(bool val) {
    backEnabled.value = val;
    isLoading.value = !val;
  }

  RxList<Widget> navItems = <Widget>[].obs;
  void setNavItems(List<Widget> val) {
    navItems.value = val;
  }

  RxList<PopupMenuItem> actions = <PopupMenuItem>[].obs;
  void setActions(List<PopupMenuItem> val) {
    actions.value = val;
  }
}
