import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:at_utils/at_logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:archive/archive_io.dart';
import 'package:atsign_location_app/services/size_config.dart';

class PrivateKeyQRCodeGenScreen extends StatefulWidget {
  PrivateKeyQRCodeGenScreen({Key key}) : super(key: key);

  @override
  _PrivateKeyQRCodeGenScreenState createState() =>
      _PrivateKeyQRCodeGenScreenState();
}

class _PrivateKeyQRCodeGenScreenState extends State<PrivateKeyQRCodeGenScreen> {
  var _logger = AtSignLogger('AtPrivateKeyQRCodeGeneration');
  String atsign;
  var aesKey;

  @override
  void initState() {
    super.initState();
    // _generateAESKey();
    atsign = BackendService.getInstance().currentAtsign;
  }

  GlobalKey globalKey = new GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _loading = false;
  Uint8List _pngBytes;
  var fileLocation;

  /// captures the widget and saves it as png file.
  void _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();

      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      _pngBytes = byteData.buffer.asUint8List();
      var directory;
      if (fileLocation == null) {
        directory = await path_provider.getApplicationDocumentsDirectory();
        fileLocation = directory.path.toString() + '/';
        await Permission.storage.request();
      }
      String path = fileLocation;
      var _imagename = atsign + '_private_key';
      final emptyFile = await File('$path$_imagename.png').create();
      await emptyFile.writeAsBytes(_pngBytes);
      var encoder = ZipFileEncoder();
      encoder.create('$path' + 'atKeys.zip');
      encoder.addFile(emptyFile);
      var _encryptKeys = atsign + '_encrypt_keys';
      encoder.addFile(File('$path$_encryptKeys.atKeys'));
      encoder.close();
      final RenderBox box = context.findRenderObject();
      await Share.shareFiles([encoder.zip_path],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (atsign == null) {
      return Text('An @sign is required.');
    }
    if (aesKey == null) {
      _generateAESKey();
      return Scaffold();
    } else
      return Opacity(
        opacity: _loading ? 0.2 : 1,
        child: AbsorbPointer(
          absorbing: _loading,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            key: _scaffoldKey,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: AppBar(
                automaticallyImplyLeading: false,
                brightness: Brightness.dark,
                title: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    TextStrings().saveKeyTitle,
                    style: CustomTextStyles().darkGrey14,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30))),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    TextStrings().importantTitle,
                    style: CustomTextStyles().darkGrey14,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    TextStrings().saveKeyDescription,
                    style: CustomTextStyles().darkGrey14,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: QrImage(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          data: atsign + ':' + aesKey,
                          size: 300,
                          // onError:
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    width: 230.toWidth,
                    child: Text(
                      TextStrings().buttonSave,
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    bgColor: Theme.of(context).primaryColor,
                    onTap: () {
                      _captureAndSavePng();
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomButton(
                    width: 230.toWidth,
                    child: Text(
                      TextStrings().buttonContinue,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    bgColor: Theme.of(context).scaffoldBackgroundColor,
                    onTap: () async {
                      await Navigator.pushNamed(context, Routes.HOME);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  _generateAESKey() async {
    var aesEncryptedKeys =
        await BackendService.getInstance().getEncryptedKeys(atsign);
    var directory;
    String path;
    directory = await path_provider.getApplicationDocumentsDirectory();
    path = directory.path.toString() + '/';
    await Permission.storage.request();
    fileLocation = path;
    var _encryptKeys = atsign + '_encrypt_keys';
    final emptyFile = await File('$path$_encryptKeys.atKeys').create();
    var keyString = jsonEncode(aesEncryptedKeys);
    emptyFile.writeAsStringSync(keyString);
    _logger.info('Saved encrypted keys to file');
    aesKey = await BackendService.getInstance().getAESKey(atsign);
    _logger.info('aeskey is $aesKey');
    setState(() {});
  }
}
