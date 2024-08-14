import 'package:flutter/material.dart';
import 'package:passwordy/widgets/edit/text_edit.dart';

class UrlEdit extends TextEdit {
  UrlEdit({required super.data, super.nextFocusNode}): super(keyboardType: TextInputType.url);

  @override
  void validate() {
    if(value.isNotEmpty) {
      final uri = Uri.tryParse(valueToStore);
      if(uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
        throw const FormatException("Invalid URL");
      }
    }
  }
}
