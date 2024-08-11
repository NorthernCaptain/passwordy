import 'package:flutter/material.dart';
import 'package:passwordy/service/utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/service/log.dart';

class QRViewReader extends StatefulWidget {
  final Function(OTPEntry) onQRScanned;
  const QRViewReader({super.key, required this.onQRScanned});
  @override
  State<StatefulWidget> createState() => _QRViewReaderState();
}

class _QRViewReaderState extends State<QRViewReader> {
  Barcode? result;
  QRViewController? controller;
  bool scanComplete = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildQrView(context),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildControlButton(
            icon: Icons.flash_on,
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null) {
        _processQRResult(result!.code!);
      }
    });
  }

  void _processQRResult(String qrCode) {
    lg?.i("Scanned QR code: $qrCode");
    if (scanComplete) {
      return;
    }
    try {
      OTPEntry entry = OTPEntry.fromUri(Uri.parse(qrCode));
      lg?.i('CHECK Generated TOTP URI: ${entry.toUri().toString()}');
      Navigator.pop(context);
      scanComplete = true;
      widget.onQRScanned(entry);
    } catch (e) {
      snackError(context, 'Invalid OTP secret');
      lg?.e("Invalid QR code: $qrCode", error: e);
      return;
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      snackError(context, 'No camera permission');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
