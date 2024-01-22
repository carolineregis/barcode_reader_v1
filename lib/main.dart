// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:boleto_utils/boleto_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScanResult? scanResult;
  String? codigoData;
  late BoletoUtils boletoUtils;
  BoletoValidado? boletoValidado;

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  void initState() {
    super.initState();
    boletoUtils = BoletoUtils();

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  Future<void> _scan(BuildContext context) async {
    final result = await BarcodeScanner.scan(
      options: ScanOptions(
        strings: {
          'cancel': _cancelController.text,
          'flash_on': _flashOnController.text,
          'flash_off': _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      ),
    ).then((barcode) async {
      if (barcode.rawContent.length != 0) {
        boletoValidado = boletoUtils.validarBoleto(barcode.rawContent);

        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => InfosBoleto(boletoValidado)));
      }
    });

    //   setState(() {
    //     scanResult = result;
    //   });
    // } on PlatformException catch (e) {
    //   setState(() {
    //     scanResult = ScanResult(
    //       rawContent: e.code == BarcodeScanner.cameraAccessDenied
    //           ? 'The user did not grant the camera permission!'
    //           : 'Unknown error: $e',
    //     );
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera),
            tooltip: 'Scan',
            onPressed: () async => await _scan(context),
          ),
        ],
      ),
    );
    //   body: ListView(
    //     shrinkWrap: true,
    //     children: <Widget>[
    //       if (scanResult != null)
    //         Column(
    //           children: <Widget>[
    //             Card(
    //               child: Column(
    //                 children: <Widget>[
    //                   ListTile(
    //                     title: const Text('Result Type'),
    //                     subtitle: Text('${boletoValidado}'),
    //                   ),
    //                   ListTile(
    //                     title: const Text('Raw Content'),
    //                     subtitle: Text('${scanResult.rawContent}'),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Card(
    //               child: Column(
    //                 children: <Widget>[
    //                   ListTile(
    //                     title: const Text('Bloquinhos'),
    //                     subtitle: Text(
    //                       scanResult.rawContent.toString().substring(0, 10),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Card(
    //               child: Column(
    //                 children: <Widget>[
    //                   ListTile(
    //                     title: Text('bloquinho2'),
    //                     subtitle: Text(
    //                         scanResult.rawContent.toString().substring(11, 21)),
    //                   )
    //                 ],
    //               ),
    //             ),
    //             Card(
    //               child: Column(
    //                 children: <Widget>[
    //                   ListTile(
    //                     title: Text('bloquinho3'),
    //                     subtitle: Text(
    //                         scanResult.rawContent.toString().substring(22, 32)),
    //                   )
    //                 ],
    //               ),
    //             ),
    //             Card(
    //               child: Column(
    //                 children: <Widget>[
    //                   ListTile(
    //                     title: Text('bloquinho4'),
    //                     subtitle: Text(
    //                         scanResult.rawContent.toString().substring(33, 43)),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       const ListTile(
    //         title: Text('Camera selection'),
    //         dense: true,
    //         enabled: false,
    //       ),
    //       RadioListTile(
    //         onChanged: (v) => setState(() => _selectedCamera = -1),
    //         value: -1,
    //         title: const Text('Default camera'),
    //         groupValue: _selectedCamera,
    //       ),
    //       ...List.generate(
    //         _numberOfCameras,
    //         (i) => RadioListTile(
    //           onChanged: (v) => setState(() => _selectedCamera = i),
    //           value: i,
    //           title: Text('Camera ${i + 1}'),
    //           groupValue: _selectedCamera,
    //         ),
    //       ),
    //       const ListTile(
    //         title: Text('Button Texts'),
    //         dense: true,
    //         enabled: false,
    //       ),
    //       ListTile(
    //         title: TextField(
    //           decoration: const InputDecoration(
    //             floatingLabelBehavior: FloatingLabelBehavior.always,
    //             labelText: 'Flash On',
    //           ),
    //           controller: _flashOnController,
    //         ),
    //       ),
    //       ListTile(
    //         title: TextField(
    //           decoration: const InputDecoration(
    //             floatingLabelBehavior: FloatingLabelBehavior.always,
    //             labelText: 'Flash Off',
    //           ),
    //           controller: _flashOffController,
    //         ),
    //       ),
    //       ListTile(
    //         title: TextField(
    //           decoration: const InputDecoration(
    //             floatingLabelBehavior: FloatingLabelBehavior.always,
    //             labelText: 'Cancel',
    //           ),
    //           controller: _cancelController,
    //         ),
    //       ),
    //       if (Platform.isAndroid) ...[
    //         const ListTile(
    //           title: Text('Android specific options'),
    //           dense: true,
    //           enabled: false,
    //         ),
    //         ListTile(
    //           title: Text(
    //             'Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})',
    //           ),
    //           subtitle: Slider(
    //             min: -1,
    //             value: _aspectTolerance,
    //             onChanged: (value) {
    //               setState(() {
    //                 _aspectTolerance = value;
    //               });
    //             },
    //           ),
    //         ),
    //         CheckboxListTile(
    //           title: const Text('Use autofocus'),
    //           value: _useAutoFocus,
    //           onChanged: (checked) {
    //             setState(() {
    //               _useAutoFocus = checked!;
    //             });
    //           },
    //         ),
    //       ],
    //       const ListTile(
    //         title: Text('Other options'),
    //         dense: true,
    //         enabled: false,
    //       ),
    //       CheckboxListTile(
    //         title: const Text('Start with flash'),
    //         value: _autoEnableFlash,
    //         onChanged: (checked) {
    //           setState(() {
    //             _autoEnableFlash = checked!;
    //           });
    //         },
    //       ),
    //       const ListTile(
    //         title: Text('Barcode formats'),
    //         dense: true,
    //         enabled: false,
    //       ),
    //       ListTile(
    //         trailing: Checkbox(
    //           tristate: true,
    //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //           value: selectedFormats.length == _possibleFormats.length
    //               ? true
    //               : selectedFormats.isEmpty
    //                   ? false
    //                   : null,
    //           onChanged: (checked) {
    //             setState(() {
    //               selectedFormats = [
    //                 if (checked ?? false) ..._possibleFormats,
    //               ];
    //             });
    //           },
    //         ),
    //         dense: true,
    //         enabled: false,
    //         title: const Text('Detect barcode formats'),
    //         subtitle: const Text(
    //           'If all are unselected, all possible '
    //           'platform formats will be used',
    //         ),
    //       ),
    //       ..._possibleFormats.map(
    //         (format) => CheckboxListTile(
    //           value: selectedFormats.contains(format),
    //           onChanged: (i) {
    //             setState(
    //               () => selectedFormats.contains(format)
    //                   ? selectedFormats.remove(format)
    //                   : selectedFormats.add(format),
    //             );
    //           },
    //           title: Text(format.toString()),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class InfosBoleto extends StatelessWidget {
  const InfosBoleto(this.boletoValidado, {Key? key}) : super(key: key);
  final BoletoValidado? boletoValidado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Boleto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(';Sucesso: ${boletoValidado?.sucesso.toString()}\n'),
            SelectableText(';mensagem: ${boletoValidado?.mensagem}\n'),
            SelectableText(
                ';Código de entrada:\n${boletoValidado?.codigoInput}\n'),
            SelectableText(
                ';Tipo de código de entrada: ${boletoValidado?.tipoCodigoInput}\n'),
            SelectableText(';Tipo de boleto: ${boletoValidado?.tipoBoleto}\n'),
            SelectableText(
                ';Código de barras:\n ${boletoValidado?.codigoBarras}\n'),
            SelectableText(
                ';Linha digitável:\n${boletoValidado?.linhaDigitavel}\n'),
            SelectableText(
                ';Código banco emissor: ${boletoValidado?.bancoEmissor?.codigo}\n'),
            SelectableText(';Vencimento: ${boletoValidado?.vencimento}\n'),
            SelectableText(';Valor: ${boletoValidado?.valor}\n')
          ],
        ),
      ),
    );
  }
}
