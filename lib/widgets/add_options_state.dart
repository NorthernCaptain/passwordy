// Abstract class that defines the common method
import 'package:flutter/material.dart';
import 'package:passwordy/service/utils.dart';

abstract class AddOptionsShowable {
  void showAddOptions(BuildContext context);
}

// Mixin to add the key functionality to our widgets
mixin KeyedAddOptionsState<T extends StatefulWidget> on State<T> implements AddOptionsShowable {
  @override
  void showAddOptions(BuildContext context);
}

abstract class AddOptionsWidget extends StatefulWidget {
  AddOptionsWidget({Key? key})
      : super(key: GlobalKey<KeyedAddOptionsState>());

  void showAddOptions(BuildContext context) {
    key?.asOrNull<GlobalKey<KeyedAddOptionsState>>()?.currentState?.showAddOptions(context);
  }
}
