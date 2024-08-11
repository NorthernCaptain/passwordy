import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/service/utils.dart';

class OTPTile extends StatefulWidget {
  final OTPEntry entry;

  const OTPTile({super.key, required this.entry});

  @override
  _OTPTileState createState() => _OTPTileState();
}

class _OTPTileState extends State<OTPTile> {
  late Timer _timer;
  String _currentCode = '';

  @override
  void initState() {
    super.initState();
    _updateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCode());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCode() {
    setState(() {
      _currentCode = widget.entry.generateOTP();
    });
  }

  String formatCode(String code) {
    switch(code.length) {
      case 6:
        return '${code.substring(0, 3)} ${code.substring(3)}';
      case 8:
        return '${code.substring(0, 2)} ${code.substring(2, 4)} ${code.substring(4)}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(widget.entry.siteName[0]),
      ),
      title: Text(widget.entry.siteName),
      subtitle: Text(
        formatCode(_currentCode),
        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      ),
      trailing: widget.entry.isTotp()
          ? _buildTOTPProgress(widget.entry)
          : _buildHOTPButton(),
      onTap: () => _copyToClipboard(context),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _currentCode));
    snackInfo(context, 'Copied to clipboard: $_currentCode');
  }

  Widget _buildTOTPProgress(OTPEntry entry) {
    int remainingSeconds = entry.secondsRemaining();
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: remainingSeconds / entry.period,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Text(
            '$remainingSeconds',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHOTPButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          setState(() {
            widget.entry.incrementCounter();
            _updateCode();
          });
        },
        child: const Icon(Icons.refresh, size: 20),
      ),
    );
  }
}
