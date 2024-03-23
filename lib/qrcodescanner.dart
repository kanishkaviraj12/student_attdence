// // ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QRViewExample extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _QRViewExampleState();
// }

// class _QRViewExampleState extends State<QRViewExample> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   final TextEditingController _textEditingController = TextEditingController();

//   Barcode? result;
//   QRViewController? controller;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Scanner'),
//       ),
//       body: Column(
//         children: <Widget>[

//           Expanded(
//             flex: 5,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [

//                 QRView(
//                   key: qrKey,
//                   onQRViewCreated: _onQRViewCreated,
//                 ),

//                 //red box created code
//                 // Container(
//                 //   width: 200,
//                 //   height: 200,
//                 //   decoration: BoxDecoration(
//                 //     border: Border.all(
//                 //       color: Colors.red,
//                 //       width: 4,
//                 //     ),
//                 //   ),
//                 // ),

//                 CustomPaint(
//                   size: Size(200, 200), // Size of your red box
//                   painter: _CornerPainter(),
//                 ),

//               ],
//             ),
//           ),

//           Expanded(
//             flex: 1,
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: _textEditingController,
//                 readOnly: true,
//                 maxLines: null,
//                 expands: true,
//                 textAlignVertical: TextAlignVertical.center,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Scanned Text',
//                   hintText: 'No text found',
//                 ),
//                 enableInteractiveSelection: true,
//               ),
//             ),
//           ),

//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData;
//         _textEditingController.text = result?.code ?? 'No text found';
//       });
//     });
//   }
// }

// //qr code box painting
// class _CornerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.white // Color of the corner lines
//       ..strokeWidth = 4; // Width of the corner lines

//     canvas.drawLine(Offset(0, 0), Offset(20, 0), paint); // Top left corner
//     canvas.drawLine(Offset(0, 0), Offset(0, 20), paint);

//     canvas.drawLine(Offset(size.width - 20, 0), Offset(size.width, 0), paint); // Top right corner
//     canvas.drawLine(Offset(size.width, 0), Offset(size.width, 20), paint);

//     canvas.drawLine(Offset(0, size.height - 20), Offset(0, size.height), paint); // Bottom left corner
//     canvas.drawLine(Offset(0, size.height), Offset(20, size.height), paint);

//     canvas.drawLine(Offset(size.width - 20, size.height), Offset(size.width, size.height), paint); // Bottom right corner
//     canvas.drawLine(Offset(size.width, size.height - 20), Offset(size.width, size.height), paint);
//   }
  
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }