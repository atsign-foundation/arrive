import 'dart:io';

import 'package:archive/archive.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/services/at_error_dialog.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/text_strings.dart';
import 'package:atsign_location_app/view_models/scan_qr_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:atsign_location_app/services/size_config.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanQrScreen extends StatefulWidget {
  ScanQrScreen({Key key}) : super(key: key);

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QrReaderViewController _controller;
  BackendService backendService = BackendService.getInstance();
  ScanQrProvider qrProvider = ScanQrProvider();
  bool loading = false;
  bool cameraPermissionGrated = false;
  bool scanCompleted = false;

  String _incorrectKeyFile =
      'Unable to fetch the keys from chosen file. Please choose correct file';
  String _failedFileProcessing = 'Failed in processing files. Please try again';

  @override
  void initState() {
    askCameraPermission();
    super.initState();
  }

  askCameraPermission() async {
    // var status = await Permission.camera.status;
    // print("camera status => $status");
    // if (status.isUndetermined) {
    //   // We didn't ask for permission yet.
    //   await [
    //     Permission.camera,
    //     Permission.storage,
    //   ].request();
    //   this.setState(() {
    //     cameraPermissionGrated = true;
    //   });
    // } else {
    //   this.setState(() {
    //     cameraPermissionGrated = true;
    //   });
    // }
  }

  showSnackBar(BuildContext context, messageText) {
    final snackBar = SnackBar(content: Text(messageText));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void onScan(String data, List<Offset> offsets, context) async {
    print("here scan completed => $data ");
    _controller.stopCamera();
    this.setState(() {
      scanCompleted = true;
    });
    String authenticateMessage =
        await backendService.authenticate(data, context);

    print("message from authenticate => $authenticateMessage");
    showSnackBar(context, authenticateMessage);
    this.setState(() {
      scanCompleted = false;
    });
    if (authenticateMessage != backendService.AUTH_SUCCESS) {
      await _controller.startCamera((data, offsets) {
        onScan(data, offsets, context);
      });
    }
  }

  // @override
  // void didChangeDependencies() {
  //   BuildContext c = NavService.navKey.currentContext;
  //   if (qrProvider.status['cram'] == Status.Error) {
  //     showDialog(
  //       context: c,
  //       barrierDismissible: true,
  //       builder: (context) => Container(
  //         height: 40,
  //         width: 40,
  //         color: Colors.red,
  //       ),
  //     );
  //   }
  //   super.didChangeDependencies();
  // }
  void _uploadCramKeyFile() async {
    try {
      String cramKey;
      //from
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: false);
      setState(() {
        loading = true;
      });
      for (var file in result.files) {
        if (cramKey == null) {
          String result = await FlutterQrReader.imgScan(File(file.path));
          if (result.contains('@')) {
            cramKey = result;
            break;
          } //read scan QRcode and extract atsign,aeskey
        }
      }

      // cramKey =
      //     "@alice🛠:b26455a907582760ebf35bc4847de549bc41c24b25c8b1c58d5964f7b4f8a43bc55b0e9a601c9a9657d9a8b8bbc32f88b4e38ffaca03c8710ebae1b14ca9f364";
      // to
      if (cramKey == null) {
        // _showAlertDialog(_incorrectKeyFile);
        showSnackBar(context, "File content error");
        setState(() {
          loading = true;
        });
      } else {
        String authenticateMessage =
            await backendService.authenticate(cramKey, context);

        showSnackBar(context, authenticateMessage);
        setState(() {
          loading = false;
        });
      }
      // await _processAESKey(atsign, aesKey, fileContents);
    } on Error catch (error) {
      setState(() {
        loading = false;
      });
    } on Exception catch (ex) {
      setState(() {
        loading = false;
      });
    }
  }

  void _uploadKeyFile() async {
    try {
      var fileContents, aesKey, atsign;
      // FilePickerResult result = await FilePicker.platform
      //     .pickFiles(type: FileType.any, allowMultiple: true);
      // setState(() {
      //   loading = true;
      // });
      // for (var pickedFile in result.files) {
      //   var path = pickedFile.path;
      //   File selectedFile = File(path);
      //   var length = selectedFile.lengthSync();
      //   if (selectedFile.lengthSync() < 10) {
      //     _showAlertDialog(_incorrectKeyFile);
      //     return;
      //   }
      //   if (pickedFile.extension == 'zip') {

      // File selectedFile =
      //     File('/Users/nitesh/Downloads/baila82brilliant-atKeys.zip');
      File selectedFile =
          File('/Users/nitesh/Downloads/mixedmartialartsexcess-atKeys.zip');

      var bytes = selectedFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (var file in archive) {
        print(file.name);
        if (file.name.contains('atKeys')) {
          print('inside atKeys');
          fileContents = String.fromCharCodes(file.content);
        } else if (aesKey == null &&
            atsign == null &&
            file.name.contains('_private_key.png')) {
          print(' not inside atKeys');

          var bytes = file.content as List<int>;
          var path = (await path_provider.getTemporaryDirectory()).path;
          var file1 = await File('$path' + 'test').create();
          file1.writeAsBytesSync(bytes);
          String result = await FlutterQrReader.imgScan(file1);
          // String result =
          //     ‘@baila82brilliant:ap61xrp0ykQfs5v+H/2MGL7ffet+rpNASrO2/2dhIP0=’;
          print('result - $result');
          List<String> params = result.split(':');
          atsign = params[0];
          aesKey = params[1];
          await File(path + 'test').delete();
          //read scan QRcode and extract atsign,aeskey

        }
      }
      // }
      //    else if (pickedFile.name.contains('atKeys')) {
      //     fileContents = File(path).readAsStringSync();
      //   } else if (aesKey == null &&
      //       atsign == null &&
      //       pickedFile.name.contains('_private_key.png')) {
      //     String result = await FlutterQrReader.imgScan(File(path));
      //     List<String> params = result.split(':');
      //     atsign = params[0];
      //     aesKey = params[1];
      //     //read scan QRcode and extract atsign,aeskey
      //   }
      //}
      if (fileContents == null || (aesKey == null && atsign == null)) {
        _showAlertDialog(_incorrectKeyFile);
      }
      await _processAESKey(atsign, aesKey, fileContents);
    } on Error catch (error) {
      setState(() {
        loading = false;
      });
      _showAlertDialog(_failedFileProcessing);
    } on Exception catch (ex) {
      setState(() {
        loading = false;
      });
      _showAlertDialog(_failedFileProcessing);
    }
  }

  _showAlertDialog(var errorMessage) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AtErrorDialog.getAlertDialog(errorMessage, context);
        });
  }

  _processAESKey(String atsign, String aesKey, String contents) async {
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != null || contents != '');
    await backendService
        .authenticateWithAESKey(atsign, jsonData: contents, decryptKey: aesKey)
        .then((response) async {
      await backendService.startMonitor();
      if (response) {
        await Navigator.of(context).pushNamed(Routes.HOME);
      }
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print("Error in authenticateWithAESKey => ${err}");
      throw Exception(err.toString());
      // _showAlertDialog(err);
      // setState(() {
      //   loading = false;
      // });
      // _logger.severe('Scanning QR code throws $err Error');
    });
  }

  @override
  void dispose() {
    // if (_controller != null) {
    //   _controller.stopCamera();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: CustomAppBar(
        title: TextStrings().scanQrTitle,
        centerTitle: true,
        leadingWidget: Icon(Icons.arrow_right),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: 25.toHeight, horizontal: 24.toHeight),
          child: Stack(
            children: [
              Column(
                children: [
                  Text(
                    TextStrings().scanQrMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.toFont,
                      color: AllColors().GREY,
                    ),
                  ),
                  SizedBox(
                    height: 25.toHeight,
                  ),
                  Builder(
                    builder: (context) => Container(
                      alignment: Alignment.center,
                      width: 300.toWidth,
                      height: 350.toHeight,
                      color: Colors.black,
                      child: !cameraPermissionGrated
                          ? SizedBox()
                          : Stack(
                              children: [
                                QrReaderView(
                                  width: 300.toWidth,
                                  height: 350.toHeight,
                                  callback: (container) {
                                    this._controller = container;
                                    _controller.startCamera((data, offsets) {
                                      onScan(data, offsets, context);
                                    });
                                  },
                                ),
                                scanCompleted
                                    ? Center(
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AllColors().ORANGE)),
                                      )
                                    : SizedBox()
                              ],
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 25.toHeight,
                  ),
                  Center(child: Text('OR')),
                  SizedBox(
                    height: 25.toHeight,
                  ),
                  CustomButton(
                    bgColor: AllColors().WHITE,
                    width: 230.toWidth,
                    height: 50.toHeight * deviceTextFactor,
                    child: Text(
                      TextStrings().upload,
                      style: CustomTextStyles().black14,
                    ),
                    onTap: _uploadCramKeyFile,
                  ),
                  SizedBox(
                    height: 25.toHeight,
                  ),
                  CustomButton(
                    bgColor: AllColors().WHITE,
                    width: 230.toWidth,
                    height: 50.toHeight * deviceTextFactor,
                    child: Text(
                      TextStrings().uploadKey,
                      style: CustomTextStyles().black14,
                    ),
                    onTap: _uploadKeyFile,
                  ),
                  SizedBox(
                    height: 25.toHeight,
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (BuildContext context) => WebsiteScreen(
                  //             url: MixedConstants.WEBSITE_URL,
                  //             title: TextStrings().websiteTitle),
                  //       ),
                  //     );
                  //   },
                  //   child: Text(
                  //     TextStrings().scanQrFooter,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       fontSize: 16.toFont,
                  //       color: ColorConstants.redText,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              loading
                  ? SizedBox(
                      height: SizeConfig().screenHeight,
                      width: SizeConfig().screenWidth,
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AllColors().ORANGE)),
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
