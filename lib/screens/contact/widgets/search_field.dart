import 'package:atsign_location_app/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ContactSearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  ContactSearchField(this.hintText, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.toFont),
      child: TextField(
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.toFont,
            color: AllColors().DARK_GREY,
          ),
          filled: true,
          fillColor: AllColors().INPUT_GREY_BACKGROUND,
          contentPadding: EdgeInsets.symmetric(vertical: 15.toHeight),
          prefixIcon: Icon(
            Icons.search,
            color: AllColors().GREY_LABEL,
            size: 20.toFont,
          ),
        ),
      ),
    );
  }
}
