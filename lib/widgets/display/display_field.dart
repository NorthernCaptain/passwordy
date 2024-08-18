import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwordy/service/utils.dart';

class DisplayField extends StatefulWidget {
  final String label;
  final String value;
  final bool isObscurable;

  const DisplayField({
    super.key,
    required this.label,
    required this.value,
    this.isObscurable = false,
  });

  @override
  _DisplayFieldState createState() => _DisplayFieldState();
}

class _DisplayFieldState extends State<DisplayField> {
  bool _obscureText = true;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.value));
    snackInfo(context, 'Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _copyToClipboard(context),
        child:
        Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child:
        InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            fillColor: Theme
                .of(context)
                .cardColor,
            filled: true,
            enabled: false,
            suffixIcon: widget.isObscurable
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
          ),
          child: Text(
            widget.isObscurable && _obscureText
                ? '•' * widget.value.length
                : widget.value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        )
    );
  }
}