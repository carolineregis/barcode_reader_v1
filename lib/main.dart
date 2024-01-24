import 'package:barcode_scan2/barcode_scan2.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:boleto_utils/boleto_utils.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late BoletoUtils boletoUtils;
  BoletoValidado? boletoValidado;
  StreamSubscription? streamBarcode;

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 2;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList();

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  void initState() {
    super.initState();
    boletoUtils = BoletoUtils();
  }

  Future<void> startBarcodeScanStream(BuildContext context) async {
    BarcodeScanner.scan(
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
    ).then(
      (barcode) async {
        if (barcode.rawContent != null) {
          boletoValidado = boletoUtils.validarBoleto(
              '34191.75124 34567.871230 41234.560005 1 96050000026035'); //MOCADO
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InfosBoleto(boletoValidado),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoletoUtils'),
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async => await startBarcodeScanStream(context),
              child: const Text('Start barcode scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfosBoleto extends StatelessWidget {
  const InfosBoleto(
    this.boletoValidado, {
    Key? key,
  }) : super(key: key);

  final BoletoValidado? boletoValidado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirme os dados'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("valor"),
                    SelectableText('${boletoValidado?.valor}\n'),
                  ],
                ),
              ],
            ),
            Text('Código do boleto'),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(10)),
              child: SelectableText(
                '${boletoValidado?.codigoBarras}\n',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            // Text('Sucesso'),
            // Container(
            //   padding: EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //       color: Colors.pink[50],
            //       borderRadius: BorderRadius.circular(10)),
            //   child: SelectableText(
            //     '${boletoValidado?.sucesso}\n',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // SelectableText('mensagem: ${boletoValidado?.mensagem}\n'),
            // SelectableText(
            //     'Tipo de código de entrada: ${boletoValidado?.tipoCodigoInput}\n'),
            // SelectableText('Tipo de boleto: ${boletoValidado?.tipoBoleto}\n'),
            // SelectableText('Código input:\n ${boletoValidado?.codigoInput}\n'),
            // SelectableText(
            //     'Linha digitável:\n${boletoValidado?.linhaDigitavel}\n'),
            SelectableText(
                'Banco emissor: ${boletoValidado?.bancoEmissor?.banco}\n'),
            SelectableText('Vencimento: ${boletoValidado?.vencimento}\n'),
          ],
        ),
      ),
    );
  }
}
