import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigationController extends GetxController
    with WidgetsBindingObserver {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // Add observer to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    // Remove observer when controller is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App resumed
        break;
      default:
        break;
    }
  }
}
