import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:passwordy/service/totp.dart';

class QRViewReader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewReaderState();
}

class _QRViewReaderState extends State<QRViewReader> {
  Barcode? result;
  QRViewController? controller;
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
              icon: Icon(Icons.close, color: Colors.white),
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
      padding: EdgeInsets.symmetric(horizontal: 16),
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
    try {
      Uri uri = Uri.parse(qrCode);
      if (uri.scheme == 'otpauth' && uri.host == 'totp') {
        String siteName = uri.queryParameters['issuer'] ?? 'Unknown';
        String secret = uri.queryParameters['secret'] ?? '';

        if (secret.isNotEmpty) {
          TOTPEntry totp = TOTPEntry(siteName: siteName, secret: secret);
          try {
            totp.generateTOTP();
          } catch (e) {
            _showInvalidQRCodeSnackBar('Invalid TOTP secret');
            return;
          }
          Navigator.pop(context, {'siteName': siteName, 'secret': secret});
        } else {
          _showInvalidQRCodeSnackBar('Invalid TOTP secret');
        }
      } else {
        _showInvalidQRCodeSnackBar('Invalid QR code format');
      }
    } catch (e) {
      _showInvalidQRCodeSnackBar('Unable to parse QR code');
    }
  }

  void _showInvalidQRCodeSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No camera permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
