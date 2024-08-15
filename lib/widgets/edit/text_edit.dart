import 'package:flutter/material.dart';
import 'package:passwordy/widgets/edit/edit_detail_row.dart';

class TextEdit extends EditDetailRow<TextEditState> {
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;
  final bool useObscureText;
  @override
  final FocusNode focusNode = FocusNode();
  final Function()? nextFocusNode;


  TextEdit({required super.data,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
    this.useObscureText = false,
    this.nextFocusNode,
  }): super(key: GlobalKey<TextEditState>());

  @override
  TextEditState createState() => TextEditState();
}



class TextEditState extends EditDetailRowState<TextEdit> {
  late TextEditingController controller;
  bool _obscureText = false;

  @override
  get value => controller.text;
  @override
  get valueToStore => value;

  FocusNode get focusNode => widget.focusNode;

  @override
  void initState() {
    super.initState();
    sort = widget.data.templateDetail.sort;
    controller = TextEditingController(text: widget.data.dataValue?.value ?? "");
    _obscureText = widget.useObscureText;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Widget> suffixButtons() {
    if(!widget.useObscureText) {
      return [];
    }
    return [
      IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    ];
  }


  @override
  List<Widget> buildRowItems(BuildContext context) {
    final buttons = suffixButtons();
    return [
      Expanded(
          child:
          TextField(
            controller: controller,
            focusNode: widget.focusNode,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: widget.data.templateDetail.title,
              border: const OutlineInputBorder(),
              suffixIcon: buttons.isNotEmpty ?
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: buttons,
              ) : null,
            ),
            onSubmitted: (value) => widget.nextFocusNode?.call(),
          )
      ),
    ];
  }
}