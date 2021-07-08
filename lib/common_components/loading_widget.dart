import 'package:atsign_location_app/common_components/custom_popup_route.dart';
import 'package:atsign_location_app/common_components/triple_dot_loading.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._();

  static final LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  // ignore: always_declare_return_types
  show({String text}) {
    if (!_showing) {
      _showing = true;
      NavService.navKey.currentState
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print('building loader');
                return Center(
                  child: (text != null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                text,
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: AllColors().MILD_GREY,
                                    fontSize: 20.toFont,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            TypingIndicator(
                              showIndicator: true,
                              flashingCircleBrightColor: AllColors().LIGHT_GREY,
                              flashingCircleDarkColor: AllColors().DARK_GREY,
                            ),
                          ],
                        )
                      : CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  // ignore: always_declare_return_types
  hide() {
    print('hide called');
    if (_showing) {
      NavService.navKey.currentState.pop();
      _showing = false;
    }
  }
}
