import 'package:flutter/material.dart';
import 'package:passwordy/widgets/edit/text_edit.dart';

class PhoneEdit extends TextEdit {
  PhoneEdit({required super.data, super.nextFocusNode})
      : super(keyboardType: TextInputType.phone);

  @override
  void validate() {
    final value = valueToStore;
    if (value.isNotEmpty
        && !RegExp(r'(^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$)')
            .hasMatch(value)) {
      throw const FormatException("Invalid phone number");
    }
  }
}
