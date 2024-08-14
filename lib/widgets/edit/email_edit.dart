import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:passwordy/widgets/edit/text_edit.dart';

class EmailEdit extends TextEdit {
  EmailEdit({required super.data, super.nextFocusNode}): super(keyboardType: TextInputType.emailAddress);

  @override
  void validate() {
    final email = valueToStore;
    if(email.isNotEmpty) {
      if(!EmailValidator.validate(email)) {
        throw const FormatException("Invalid email");
      }
    }
  }
}
