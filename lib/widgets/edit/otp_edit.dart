import 'package:flutter/material.dart';
import 'package:passwordy/screens/qr_code_reader.dart';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/widgets/edit/edit_detail_row.dart';

class OTPEdit extends EditDetailRow<OTPEditState> {
  @override
  final FocusNode focusNode = FocusNode();
  final FocusNode secretFocusNode = FocusNode();
  final Function()? nextFocusNode;

  OTPEdit({required super.data, this.nextFocusNode}) : super(key: GlobalKey<OTPEditState>());

  @override
  void validate() {
    final val = valueToStore;
  }

  @override
  OTPEditState createState() => OTPEditState();
}

class OTPEditState extends EditDetailRowState<OTPEdit> {
  late TextEditingController controller;
  late TextEditingController accountController;
  bool _obscureText = true;

  OTPEntry? _otpEntry;

  @override
  get value => controller.text;

  @override
  get valueToStore {
    final text = controller.text.toString().trim();
    if(text.isEmpty) {
      return '';
    }
    final account = accountController.text.toString().trim();
    if(account.isEmpty) {
      widget.focusNode.requestFocus();
      throw const FormatException('Account name is required');
    }
    try {
      _otpEntry ??= OTPEntry(siteName: account, secret: text);
      _otpEntry?.secret = text;
      _otpEntry?.siteName = account;
      _otpEntry?.generateOTP();
    } catch(e) {
      widget.secretFocusNode.requestFocus();
      throw const FormatException('Invalid OTP secret');
    }
    return _otpEntry?.toUri().toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "");
    accountController = TextEditingController(text: "");
    if(widget.data.dataValue?.value != null) {
      _otpEntry = OTPEntry.fromUri(Uri.parse(widget.data.dataValue!.value));
      controller.text = _otpEntry!.secret;
      accountController.text = _otpEntry!.siteName;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    accountController.dispose();
    super.dispose();
  }

  @override
  List<Widget> buildRowItems(BuildContext context) {
    return [
      Expanded(
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: accountController,
              focusNode: widget.focusNode,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Account name",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => widget.secretFocusNode.requestFocus(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              focusNode: widget.secretFocusNode,
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.text,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: widget.data.templateDetail.title,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              onSubmitted: (value) => widget.nextFocusNode?.call(),
            ),
          ],
        ),
      ),
      IconButton(
        iconSize: 64,
        icon: const Icon(Icons.qr_code),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=> QRViewReader(onQRScanned: (entry) {
            setState(() {
              _otpEntry = entry;
              controller.text = entry.secret;
              accountController.text = entry.siteName;
            });
          })));
        },
      ),
    ];
  }
}