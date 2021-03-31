import 'package:atsign_location_app/common_components/custom_popup_route.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._();

  static LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  show({String text}) {
    if (!_showing) {
      _showing = true;
      NavService.navKey.currentState
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print("building loader");
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: (text != null) ? 5 : 0,
                      ),
                      (text != null)
                          ? Text(
                              text,
                              style: TextStyle(
                                  color: AllColors().MILD_GREY,
                                  fontSize: 20.toFont,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none),
                            )
                          : SizedBox()
                    ],
                  ),
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
