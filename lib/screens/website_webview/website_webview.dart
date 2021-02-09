import 'dart:io';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/colors.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebsiteScreen({Key key, this.title, this.url}) : super(key: key);
  @override
  _WebsiteScreenState createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  bool loading;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
            size: 22,
          ),
        ),
        title: Text(widget.title, style: CustomTextStyles().black18),
      ),
      body: Stack(children: [
        WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (test1) {
            this.setState(() {
              loading = false;
            });
          },
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
