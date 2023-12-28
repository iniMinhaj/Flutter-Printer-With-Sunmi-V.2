import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:widgets_to_image/widgets_to_image.dart';

import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sunmi Printer',
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
        home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool printBinded = false;
  int paperSize = 0;
  String serialNumber = "";
  String printerVersion = "";
  @override
  void initState() {
    super.initState();

    _bindingPrinter().then((bool? isBind) async {
      SunmiPrinter.paperSize().then((int size) {
        setState(() {
          paperSize = size;
        });
      });

      SunmiPrinter.printerVersion().then((String version) {
        setState(() {
          printerVersion = version;
        });
      });

      SunmiPrinter.serialNumber().then((String serial) {
        setState(() {
          serialNumber = serial;
        });
      });

      setState(() {
        printBinded = isBind!;
      });
    });
  }

  /// must binding ur printer at first init in app
  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunmi printer Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WidgetsToImage(
              controller: controller,
              child: InkWell(
                  onTap: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                      print("Bytes = $bytes");
                    });
                    await SunmiPrinter.startTransactionPrint(true);
                    await SunmiPrinter.printImage(bytes!);
                    await SunmiPrinter.exitTransactionPrint(true);
                  },
                  child: cardWidget()),
            ),
          ],
        ),
      ),
    );
  }
}

Widget cardWidget() {
  return Container(
    height: 100,
    width: 100,
    color: Colors.green,
    child: const Center(child: Text("Hi I am a Widget")),
  );
}
