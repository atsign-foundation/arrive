import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/location_tile.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/screens/selected_location.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/at_location_flutter.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_modal.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/my_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  onSubmitted: (String str) =>
                      SearchLocationService().getAddressLatLng(str),
                  value: (val) {},
                ),
              ),
              SizedBox(width: 10.toWidth),
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text('Cancel', style: CustomTextStyles().orange16)),
            ],
          ),
          SizedBox(height: 20.toHeight),
          Divider(),
          SizedBox(height: 18.toHeight),
          InkWell(
              onTap: () async {
                LatLng point = await MyLocation().myLocation();
                onLocationSelect(context, point);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Location',
                      style: CustomTextStyles().greyLabel14),
                  SizedBox(height: 5.toHeight),
                  Text('Using GPS', style: CustomTextStyles().greyLabel12),
                ],
              )),
          SizedBox(height: 20.toHeight),
          Divider(),
          SizedBox(height: 20.toHeight),
          Text('Search Results', style: CustomTextStyles().lightGreyLabel12),
          SizedBox(height: 20.toHeight),
          StreamBuilder(
            stream: SearchLocationService().atLocationStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<LocationModal>> snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? Text('Search for a Location')
                  : snapshot.hasData
                      ? snapshot.data.length == 0
                          ? Text('No such location found')
                          : Expanded(
                              child: ListView.separated(
                                itemCount: snapshot.data.length,
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
                                    onTap: () => onLocationSelect(
                                      context,
                                      LatLng(
                                          double.parse(
                                              snapshot.data[index].lat),
                                          double.parse(
                                              snapshot.data[index].long)),
                                      displayName:
                                          snapshot.data[index].displayName,
                                    ),
                                    child: LocationTile(
                                      icon: Icons.location_on,
                                      title: snapshot.data[index].city,
                                      subTitle:
                                          snapshot.data[index].displayName,
                                    ),
                                  );
                                },
                              ),
                            )
                      : snapshot.hasError
                          ? Text('Something Went wrong')
                          : SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

void onLocationSelect(BuildContext context, LatLng point,
    {String displayName}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SelectedLocation(displayName ?? 'Your location', point)));
}