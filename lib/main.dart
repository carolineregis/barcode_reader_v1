import 'package:barcode_scan2/barcode_scan2.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:boleto_utils/boleto_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
          // Código de barras mocado para testes
          // boletoValidado = boletoUtils.validarBoleto(
          //     '34191.75124 34567.871230 41234.560005 1 96050000026035');
          boletoValidado = boletoUtils.validarBoleto(barcode.rawContent);
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
        automaticallyImplyLeading: false,
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async => await startBarcodeScanStream(context),
              child: const Text('Escanear boleto'),
            ),
          ],
        ),
      ),
    );
  }
}

class PagamentoConcluido extends StatelessWidget {
  const PagamentoConcluido({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/complete.png'),
              width: 150,
            ),
            Text("Pagamento concluído!")
          ],
        ),
      ),
    );
  }
}

class BoletoVencido extends StatelessWidget {
  const BoletoVencido({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/error.png'),
              width: 150,
            ),
            Text("Boleto vencido!")
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
    final utcDate = boletoValidado?.vencimento?.toUtc();
    var formatedExpiringDate;
    var goToPage;

    if (utcDate != null) {
      formatedExpiringDate = DateFormat('dd/MM/yyyy').format(utcDate);
    }

    final today = DateTime.now().toUtc();
    final isExpired = utcDate?.day.compareTo(today.day);

    if (isExpired != null) {
      goToPage = isExpired == 0 || isExpired > 0
          ? PagamentoConcluido()
          : BoletoVencido();
    }

    if (isExpired == null) {
      goToPage = Home();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirme os dados de pagamento'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    // height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.pink.shade200, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Valor",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromRGBO(0, 0, 0, 0.357),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: SelectableText(
                                'R\$ ${boletoValidado?.valor ?? 'Sem dados'}\n',
                                style: GoogleFonts.inconsolata(
                                    fontSize: 30,
                                    decorationColor: Colors.purple[900],
                                    decoration: TextDecoration.underline,
                                    color:
                                        const Color.fromARGB(255, 107, 67, 156),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                      child: const Text(
                        'Banco emissor',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 111, 114, 114),
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 0),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        '${boletoValidado?.bancoEmissor?.banco ?? 'Sem dados'}\n',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                      child: const Text(
                        'Vencimento',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 111, 114, 114),
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 0),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        '${formatedExpiringDate ?? 'Sem dados'}\n',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 6, right: 6, top: 16, bottom: 8),
                      child: const Text(
                        'Código do boleto',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 111, 114, 114),
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 0),
                      height: 40,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        '${boletoValidado?.codigoBarras ?? 'Sem dados'}\n',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
            ),
            if (boletoValidado?.codigoBarras != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(176, 233, 221, 255)),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (
                              context,
                            ) =>
                                goToPage,
                          ),
                        );
                      },
                      child: const Text('Confirmar Pagamento'),
                    ),
                  )
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  // direction: Axis.vertical,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(176, 233, 221, 255)),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color.fromARGB(255, 181, 0, 0)),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
