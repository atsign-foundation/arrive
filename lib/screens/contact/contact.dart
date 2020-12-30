import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/common_components/error_dialog.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/common_components/provider_handler.dart';
import 'package:atsign_location_app/screens/contact/widgets/search_field.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/text_strings.dart';
import 'package:atsign_location_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  ContactProvider provider;
  String searchText;
  @override
  void initState() {
    provider = ContactProvider();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.getContacts();
    });
    print("called herre => $provider");
    searchText = '';
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: TextStrings().sidebarContact,
        action: InkWell(
            // onTap: (String atSignName) {
            //   providerCallback<ContactProvider>(context,
            //       task: (provider) => provider.addContact(atSign: atSignName),
            //       taskName: (provider) => provider.Contacts,
            //       onSuccess: (provider) {},
            //       onError: (err) =>
            //           ErrorDialog().show(err.toString(), context: context));
            // },
            child: Icon(
          Icons.add,
        )),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: 16.toWidth, vertical: 16.toHeight),
          child: Column(
            children: [
              ContactSearchField(
                TextStrings().searchContact,
                (text) => setState(() {
                  searchText = text;
                }),
              ),
              SizedBox(
                height: 15.toHeight,
              ),
              ProviderHandler<ContactProvider>(
                  functionName: 'contacts',
                  showError: true,
                  load: (provider) => provider.getContacts(),
                  errorBuilder: (provider) => Center(
                        child: Text('Some error occured'),
                      ),
                  successBuilder: (provider) {
                    return (provider.contactList.isEmpty)
                        ? Center(
                            child: Text('No Contact found'),
                          )
                        : ListView.builder(
                            itemCount: 27,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, alphabetIndex) {
                              List<String> _filteredList = [];
                              provider.contactList.forEach((c) {
                                if (c.atSign[1]
                                    .toUpperCase()
                                    .contains(searchText.toUpperCase())) {
                                  _filteredList.add(c.atSign);
                                }
                              });
                              List<String> contactsForAlphabet = [];
                              String currentChar =
                                  String.fromCharCode(alphabetIndex + 65)
                                      .toUpperCase();
                              if (alphabetIndex == 26) {
                                currentChar = 'Others';
                                _filteredList.forEach((c) {
                                  if (int.tryParse(c[1]) != null) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                              } else {
                                _filteredList.forEach((c) {
                                  if (c[1].toUpperCase() == currentChar) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                              }
                              if (contactsForAlphabet.isEmpty) {
                                return Container();
                              }

                              return Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currentChar,
                                          style: TextStyle(
                                            color: AllColors().BLUE,
                                            fontSize: 16.toFont,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.toWidth),
                                        Expanded(
                                          child: Divider(
                                            color: AllColors().LIGHT_GREY,
                                            height: 1.toHeight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListView.separated(
                                        itemCount: contactsForAlphabet.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        separatorBuilder: (context, _) =>
                                            Divider(
                                              color: AllColors().LIGHT_GREY,
                                              height: 1.toHeight,
                                            ),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Slidable(
                                              actionPane:
                                                  SlidableDrawerActionPane(),
                                              actionExtentRatio: 0.25,
                                              secondaryActions: <Widget>[
                                                IconSlideAction(
                                                  caption: 'Block',
                                                  color: AllColors()
                                                      .INPUT_GREY_BACKGROUND,
                                                  icon: Icons.block,
                                                  onTap: () {
                                                    print('Block');
                                                    provider.blockUnblockContact(
                                                        atSign:
                                                            contactsForAlphabet[
                                                                index],
                                                        blockAction: true);
                                                  },
                                                ),
                                                IconSlideAction(
                                                  caption: 'Delete',
                                                  color: Colors.red,
                                                  icon: Icons.delete,
                                                  onTap: () {
                                                    provider.deleteAtsignContact(
                                                        atSign:
                                                            contactsForAlphabet[
                                                                index]);
                                                  },
                                                ),
                                              ],
                                              child: Container(
                                                child: ListTile(
                                                  title: Text(
                                                    contactsForAlphabet[index]
                                                        .substring(1),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14.toFont,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    contactsForAlphabet[index],
                                                    style: TextStyle(
                                                      color: AllColors()
                                                          .LIGHT_GREY,
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
                                                        image:
                                                            AllImages().PERSON2,
                                                      )),
                                                  trailing: IconButton(
                                                    onPressed: () {
                                                      provider
                                                              .contactList[index]
                                                              .atSign =
                                                          contactsForAlphabet[
                                                                  index]
                                                              .substring(1);
                                                      provider.selectedAtsign =
                                                          provider
                                                              .contactList[
                                                                  index]
                                                              .atSign;

                                                      Navigator.of(context)
                                                          .pushNamed(
                                                        Routes.HOME,
                                                      );
                                                    },
                                                    icon: Icon(Icons.send),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                              );
                            },
                          );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
