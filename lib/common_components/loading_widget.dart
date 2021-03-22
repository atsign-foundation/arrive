import 'package:atsign_location_app/common_components/custom_popup_route.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._();

  static LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  show() {
    if (!_showing) {
      _showing = true;
      NavService.navKey.currentState
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print("building loader");
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  hide() {
    print("hide called");
    if (_showing) {
      NavService.navKey.currentState.pop();
      _showing = false;
    }
  }
}
