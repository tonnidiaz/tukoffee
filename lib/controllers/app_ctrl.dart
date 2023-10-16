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

  Rxn<String> appVersion = Rxn();

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

  RxString title = "".obs;
  void setTitle(String val) {
    title.value = val;
  }

  RxMap store = {}.obs;
  setStore(Map val) {
    store.value = val;
  }

  RxString slogan = "".obs;
  void setSlogan(String val) {
    slogan.value = val;
  }

  RxString apiURL = "".obs;
  void setApiURL(String val) {
    apiURL.value = val;
  }

  setStoreField(String field, dynamic val) {
    setStore({...store, field: val});
  }

  RxMap owner = {}.obs;
  setOwner(Map val) {
    owner.value = val;
  }

  RxMap socials = {}.obs;
  setSocials(Map val) {
    socials.value = val;
  }

  setOwnerField(String field, dynamic val) {
    setStore({...store, field: val});
  }

  RxMap developer = {}.obs;
  setDeveloper(Map val) {
    developer.value = val;
  }

  setDeveloperField(String field, dynamic val) {
    setDeveloper({...store, field: val});
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

  RxBool autoCheckUpdates = false.obs;
  void setAutoCheckUpdates(bool val) {
    autoCheckUpdates.value = val;
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
