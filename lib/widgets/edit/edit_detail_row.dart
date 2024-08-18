

import 'package:flutter/material.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';
import 'package:passwordy/service/enums.dart';
import 'package:passwordy/widgets/edit/email_edit.dart';
import 'package:passwordy/widgets/edit/otp_edit.dart';
import 'package:passwordy/widgets/edit/password_edit.dart';
import 'package:passwordy/widgets/edit/phone_edit.dart';
import 'package:passwordy/widgets/edit/text_edit.dart';
import 'package:passwordy/widgets/edit/url_edit.dart';

abstract class ValueGetter {
  String get value;
  String get valueToStore;
  void updateSort(int newSort);
}

abstract class ValueGetterData extends ValueGetter {
  DataWithTemplate get data;
  bool get isValueChanged;
  void validate();
}

abstract class ValueGetterState<T extends StatefulWidget> extends State<T> implements ValueGetter {
}

abstract class BaseEditDetailRow<T extends ValueGetterState> extends StatefulWidget implements ValueGetterData {
  FocusNode? get focusNode;
  const BaseEditDetailRow({required super.key});
  static BaseEditDetailRow create({required DataWithTemplate data, Function()? nextFocus}) {
    switch (data.templateDetail.fieldType) {
      case FieldType.note:
        return TextEdit(data: data,
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
        );
      case FieldType.text:
        return TextEdit(data: data,
          textCapitalization: TextCapitalization.none,
          nextFocusNode: nextFocus,);
      case FieldType.email:
        return EmailEdit(data: data, nextFocusNode: nextFocus,);
      case FieldType.url:
        return UrlEdit(data: data, nextFocusNode: nextFocus,);
      case FieldType.password:
        return PasswordEdit(data: data, nextFocusNode: nextFocus,);
      case FieldType.phone:
        return PhoneEdit(data: data, nextFocusNode: nextFocus,);
      case FieldType.number:
        return TextEdit(data: data,
          keyboardType: TextInputType.number,
          nextFocusNode: nextFocus,);
      case FieldType.pinCode:
        return TextEdit(data: data,
          keyboardType: TextInputType.number,
          nextFocusNode: nextFocus,
          useObscureText: true,);
      case FieldType.token:
        return OTPEdit(data: data, nextFocusNode: nextFocus,);
      default:
        return TextEdit(data: data, nextFocusNode: nextFocus,);
    }
  }
}

abstract class EditDetailRow<T extends ValueGetterState> extends BaseEditDetailRow<T> {
  @override
  FocusNode? get focusNode => null;
  @override
  final DataWithTemplate data;
  @override
  bool get isValueChanged => (data.dataValue?.value ?? "") != valueToStore;

  @override
  String get value => (key! as GlobalKey<T>).currentState!.value;
  @override
  String get valueToStore => (key! as GlobalKey<T>).currentState!.valueToStore.trim();
  @override
  void updateSort(int newSort) {
    (key! as GlobalKey<T>).currentState!.updateSort(newSort);
  }
  @override
  void validate() {}

  const EditDetailRow({required super.key, required this.data});
}

abstract class EditDetailRowState<T extends EditDetailRow> extends ValueGetterState<T> {
  late int sort;

  @override
  void initState() {
    super.initState();
    sort = widget.data.templateDetail.sort;
  }

  @override
  void updateSort(int newSort) {
    setState(() {
      sort = newSort;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: buildItem(context),
    );
  }

  List<Widget> buildRowItems(BuildContext context);

  Widget buildItem(BuildContext context) {
    return
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.drag_indicator,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 2),
          ...buildRowItems(context),
        ],
      );
  }
}
