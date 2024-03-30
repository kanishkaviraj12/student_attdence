import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final TextEditingController _textEditingController = TextEditingController();

  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR & Barcode Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _CornerPainter(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textEditingController,
                readOnly: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Scanned Text',
                  hintText: 'No text found',
                ),
                enableInteractiveSelection: true,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanBarcode,
        tooltip: 'Scan',
        child: const Icon(Icons.camera),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        _textEditingController.text = result?.code ?? 'No text found';
      });
    });
  }

  Future<void> _scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // red color for scan button
        'Cancel', // cancel button text
        true, // show flash icon
        ScanMode.BARCODE, // scan mode
      );
      setState(() {
        _textEditingController.text = barcode;
      });
    } catch (e) {
      setState(() {
        _textEditingController.text = 'Error: $e';
      });
    }
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    canvas.drawLine(const Offset(0, 0), const Offset(20, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 20), paint);

    canvas.drawLine(Offset(size.width - 20, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 20), paint);

    canvas.drawLine(Offset(0, size.height - 20), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(20, size.height), paint);

    canvas.drawLine(Offset(size.width - 20, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - 20), Offset(size.width, size.height), paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
