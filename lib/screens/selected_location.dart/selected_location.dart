import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:map/map.dart';
import 'package:latlng/latlng.dart';

class SelectedLocation extends StatefulWidget {
  @override
  _SelectedLocationState createState() => _SelectedLocationState();
}

class _SelectedLocationState extends State<SelectedLocation> {
  final controller = MapController(
    location: LatLng(35.68, 51.41),
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Map(
              controller: controller,
              builder: (context, x, y, z) {
                return CachedNetworkImage(
                  imageUrl: AllText().URL(x, y, z),
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              child: FloatingIcon(
                bgColor: AllColors().WHITE,
                icon: Icons.arrow_back,
                iconColor: AllColors().Black,
                isTopLeft: true,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                    28.toWidth, 20.toHeight, 28.toHeight, 0),
                height: SizeConfig().screenHeight * 0.4,
                width: SizeConfig().screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AllColors().ORANGE,
                                    ),
                                    Text('Central Park',
                                        style: CustomTextStyles().black16)
                                  ],
                                ),
                              ),
                              InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Text('Cancel',
                                      style: CustomTextStyles().orange16))
                            ],
                          ),
                          SizedBox(height: 10.toHeight),
                          Text(
                              '194, White Pine Lane, Troutville, Virginia, 24175, ',
                              style: CustomTextStyles().greyLabel14),
                          Text('Address Line 2 ',
                              style: CustomTextStyles().greyLabel14),
                          SizedBox(height: 20.toHeight),
                          Text('Label', style: CustomTextStyles().greyLabel14),
                          SizedBox(height: 5.toHeight),
                          CustomInputField(
                            width: 321.toWidth,
                            hintText: 'Save this address as',
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 20.toHeight),
                        child: CustomButton(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                            onTap: null,
                            width: 165.toWidth,
                            height: 48.toHeight,
                            bgColor: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
