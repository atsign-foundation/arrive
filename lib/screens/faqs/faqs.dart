import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/faq_data.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class FaqsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: 'FAQ',
        action: PopButton(label: 'Close'),
      ),
      body: Container(
        margin:
            EdgeInsets.symmetric(horizontal: 16.toWidth, vertical: 16.toHeight),
        child: ListView.separated(
          itemCount: FAQData.data.length,
          separatorBuilder: (context, index) => SizedBox(
            height: 10.toHeight,
          ),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(10.toFont),
            child: Container(
              color: AllColors().WHITE,
              child: Theme(
                data: ThemeData(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    FAQData.data[index]["question"],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.toFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        16.toWidth,
                        0,
                        16.toWidth,
                        14.toHeight,
                      ),
                      child: Text(
                        FAQData.data[index]["answer"],
                        style: TextStyle(
                          color: AllColors().GREY_LABEL,
                          fontSize: 12.toFont,
                          height: 1.7,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
