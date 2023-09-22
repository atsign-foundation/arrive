import 'dart:io';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:at_common_flutter/services/size_config.dart';

class WebsiteScreen extends StatefulWidget {
  final String? title;
  final String? url;

  const WebsiteScreen({Key? key, this.title, this.url}) : super(key: key);
  @override
  _WebsiteScreenState createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  late WebViewController webViewController;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  late bool loading;
  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              loading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url ?? ''));

    super.initState();
    loading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AllColors().WHITE,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: AllColors().Black,
            size: 25.toHeight,
          ),
        ),
        title: Text(widget.title!, style: CustomTextStyles().black18),
      ),
      body: Stack(children: [
        WebViewWidget(
          controller: webViewController,
          gestureRecognizers: gestureRecognizers,
        ),
        loading
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                  AllColors().ORANGE,
                )),
              )
            : SizedBox()
      ]),
    );
  }
}
