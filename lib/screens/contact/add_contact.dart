import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/screens/contact/widgets/add_contact_dialog.dart';
import 'package:atsign_location_app/screens/contact/widgets/search_field.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:atsign_location_app/services/validators.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/text_strings.dart';
import 'package:atsign_location_app/view_models/add_contact_provider.dart';
import 'package:flutter/material.dart';

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  AddContactProvider provider;
  final Validators validators = Validators();
  final List<String> contacts = [
    'A1',
    'A2',
    'B1',
    'C4',
    'F6',
    'B5',
    'B8',
    'F9',
    'G1',
    'H7',
    'C6',
  ];
  String searchText;

  @override
  void initState() {
    provider = AddContactProvider();
    provider.getAddContacts();
    contacts.sort();
    searchText = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: TextStrings().addContact,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: 16.toWidth, vertical: 16.toHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContactSearchField(
                TextStrings().addContactSearch,
                (text) => setState(() {
                  searchText = text;
                }),
              ),
              if (searchText != '') ...[
                SizedBox(
                  height: 25.toHeight,
                ),
                Text(
                  TextStrings().contactSearchResults,
                  style: TextStyle(
                    color: AllColors().DARK_GREY,
                    fontSize: 16.toFont,
                  ),
                )
              ],
              SizedBox(
                height: 15.toHeight,
              ),
              ListView.builder(
                itemCount: contacts.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (!contacts[index]
                      .toUpperCase()
                      .contains(searchText.toUpperCase())) {
                    return Container();
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AllColors().LIGHT_GREY,
                          width: 1.toHeight,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        contacts[index],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.toFont,
                        ),
                      ),
                      subtitle: Text(
                        '@kevin',
                        style: TextStyle(
                          color: AllColors().DARK_GREY,
                          fontSize: 14.toFont,
                        ),
                      ),
                      leading: Container(
                          height: 40.toWidth,
                          width: 40.toWidth,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: CustomCircleAvatar(
                            image: AllImages().PERSON1,
                          )),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AddContactDialog(
                                    name: contacts[index],
                                  ));
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
