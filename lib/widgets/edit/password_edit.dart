import 'package:flutter/material.dart';
import 'package:passwordy/screens/create_password.dart';
import 'package:passwordy/widgets/edit/text_edit.dart';

class PasswordEdit extends TextEdit {
  PasswordEdit({required super.data, super.nextFocusNode}) : super(useObscureText: true);

  @override
  PasswordEditState createState() => PasswordEditState();
}

class PasswordEditState extends TextEditState {
  @override
  List<Widget> suffixButtons() {
    return [ ...super.suffixButtons(),
      IconButton(
        icon: const Icon(Icons.password),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreatePasswordScreen(useSaveButton: true,),
            ),
          ).then((value) {
            if (value != null && value["password"] != null) {
              setState(() {
                controller.text = value["password"];
              });
            }
          },
          );
        }
      ),
    ];
  }
}