import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/location_tile.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.8,
          padding: EdgeInsets.fromLTRB(28.toWidth, 20.toHeight, 17.toWidth, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomInputField(
                      hintText: 'Search an area, street name…',
                    ),
                  ),
                  SizedBox(width: 10.toWidth),
                  InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(AllText().CANCEL,
                          style: CustomTextStyles().orange16)),
                ],
              ),
              SizedBox(height: 20.toHeight),
              Divider(),
              SizedBox(height: 18.toHeight),
              Text('Current Location', style: CustomTextStyles().greyLabel14),
              SizedBox(height: 5.toHeight),
              Text('Using GPS', style: CustomTextStyles().greyLabel12),
              SizedBox(height: 20.toHeight),
              Divider(),
              SizedBox(height: 20.toHeight),
              Text('Search Results',
                  style: CustomTextStyles().lightGreyLabel12),
              SizedBox(height: 20.toHeight),
              Expanded(
                child: ListView.separated(
                  itemCount: 3,
                  separatorBuilder: (context, index) {
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Divider(),
                      ],
                    );
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => onLocationSelect(context),
                      child: LocationTile(
                        icon: Icons.location_on,
                        title: 'Central Park',
                        subTitle:
                            '194, White Pine Lane, Troutville, Virginia, 24175 ',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void onLocationSelect(BuildContext context) {
  SetupRoutes.push(context, Routes.SELECTED_LOCATION);
}
