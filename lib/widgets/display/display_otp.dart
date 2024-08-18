import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/otp_tile.dart';

class DisplayOTP extends StatelessWidget {
  final OTPEntry entry;
  final DataWithTemplate data;

  DisplayOTP({super.key, required this.data}) : entry = OTPEntry.fromUri(Uri.parse(data.dataValue!.value));

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: entry.generateOTP()));
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
            labelText: data.templateDetail.title,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            fillColor: Theme
                .of(context)
                .cardColor,
            filled: true,
            enabled: false,
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                _copyToClipboard(context);
              },
            ),
          ),
          child: OTPTile(entry: entry)
        ),
        )
    );
  }
}