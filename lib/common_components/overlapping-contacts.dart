import 'dart:typed_data';

/// This is a custom widget to display the selected contacts
/// in a row with overlapping profile pictures
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/common_components/contact_list_tile.dart';
import 'package:at_location_flutter/common_components/contacts_initial.dart';
import 'package:at_location_flutter/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

// ignore: must_be_immutable
class OverlappingContacts extends StatefulWidget {
  List<AtContact?> selectedList;
  Function(int)? onRemove;
  bool isMultipleUser;
  OverlappingContacts(this.selectedList,
      {Key? key, this.onRemove, this.isMultipleUser = true})
      : super(key: key);
  @override
  _OverlappingContactsState createState() => _OverlappingContactsState();
}

class _OverlappingContactsState extends State<OverlappingContacts> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.isMultipleUser
            ? setState(() {
                isExpanded = !isExpanded;
              })
            // ignore: unnecessary_statements
            : null;
      },
      child: Container(
        height: (isExpanded) ? 300.toHeight : 60.toHeight,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xffF7F7FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Stack(
              children: List<Positioned>.generate(
                (widget.selectedList.length > 3)
                    ? 3
                    : widget.selectedList.length,
                (index) {
                  Uint8List? image;
                  if (widget.selectedList[index]!.tags != null &&
                      widget.selectedList[index]!.tags!['image'] != null) {
                    List<int> intList =
                        widget.selectedList[index]!.tags!['image'].cast<int>();
                    image = Uint8List.fromList(intList);
                  }
                  return Positioned(
                    left: 5 + double.parse((index * 25).toString()),
                    top: 5.toHeight,
                    child: Container(
                      height: 28.toHeight,
                      width: 28.toHeight,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: (widget.selectedList[index]!.tags != null &&
                              widget.selectedList[index]!.tags!['image'] != null)
                          ? CustomCircleAvatar(
                              byteImage: image,
                              nonAsset: true,
                            )
                          : ContactInitial(
                              initials: widget.selectedList[index]!.atSign,
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 10.toHeight,
              left: 40 +
                  double.parse((widget.selectedList.length * 25).toString()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (widget.selectedList.isEmpty)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 160.toWidth,
                              child: Row(
                                children: [
                                  Container(
                                    width: 60.toWidth,
                                    child: Text(
                                      '${widget.selectedList[0]!.atSign}',
                                      style: TextStyle(fontSize: 12.toFont),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      widget.selectedList.length - 1 == 0
                                          ? ''
                                          : widget.selectedList.length - 1 == 1
                                              ? '${widget.selectedList.length - 1} '+ TextStrings.other
                                              : TextStrings.and +' ${widget.selectedList.length - 1} '+ TextStrings.others,
                                      style: TextStyle(fontSize: 12.toFont),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10.toWidth,
                      ),
                    ],
                  )
                ],
              ),
            ),
            widget.isMultipleUser
                ? Positioned(
                    top: 10.toHeight,
                    right: 0,
                    child: Container(
                      width: 20.toWidth,
                      child: Icon(
                        (isExpanded)
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 15.toFont,
                      ),
                    ),
                  )
                : Positioned(
                    top: 10.toHeight,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        widget.onRemove!(0);
                      },
                      child: Container(
                          width: 20.toWidth,
                          child: Icon(
                            Icons.close,
                            color: Color(0xffA8A8A8),
                          )),
                    ),
                  ),
            (isExpanded)
                ? Positioned(
                    top: 50.toHeight,
                    child: Container(
                      height: 200.toHeight,
                      width: SizeConfig().screenWidth - 60.toWidth,
                      child: ListView.builder(
                        itemCount: widget.selectedList.length,
                        itemBuilder: (context, index) {
                          Uint8List? image;
                          if (widget.selectedList[index]!.tags != null &&
                              widget.selectedList[index]!.tags!['image'] !=
                                  null) {
                            List<int> intList = widget
                                .selectedList[index]!.tags!['image']
                                .cast<int>();
                            image = Uint8List.fromList(intList);
                          }
                          return ContactListTile(
                            onlyRemoveMethod: true,
                            onTileTap: () {},
                            isSelected: widget.selectedList
                                .contains(widget.selectedList[index]),
                            onRemove: () {
                              if (widget.onRemove != null) {
                                widget.onRemove!(index);
                              } else {
                                EventService().removeSelectedContact(index);
                                EventService().update();
                              }
                            },
                            name: widget.selectedList[index]!.tags != null &&
                                    widget.selectedList[index]!.tags!['name'] !=
                                        null
                                ? widget.selectedList[index]!.tags!['name']
                                : widget.selectedList[index]!.atSign!
                                    .substring(1),
                            atSign: widget.selectedList[index]!.atSign,
                            image: (widget.selectedList[index]!.tags != null &&
                                    widget.selectedList[index]!.tags!['image'] !=
                                        null)
                                ? CustomCircleAvatar(
                                    byteImage: image,
                                    nonAsset: true,
                                  )
                                : ContactInitial(
                                    initials: widget.selectedList[index]!.atSign,
                                  ),
                          );
                        },
                      ),
                    ),
                  )
                : Positioned(
                    top: 20.toHeight,
                    child: Container(),
                  )
          ],
        ),
      ),
    );
  }
}
