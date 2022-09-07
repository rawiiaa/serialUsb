import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:sensors/sensors.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:developer';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Timer? timer;
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  List _serialData = [];
  List<double> traceX = [];
  int ecg = 0;
  double test = 0.0;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;


  Future<bool> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }
    _port = await device.create();
    debugPrint('portsssss' + _port.toString());

    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);

    _port!.setPortParameters(
        9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    _port!.inputStream!.listen((Uint8List event) {
      setState(() {
        String s = new String.fromCharCodes(event);
        try {
          test = double.parse(s);
          debugPrint('Value' + test.toString());
        } catch (error) {
          print(error);
        }


      });

      //_port!.close();
    });

    await _port!.write(Uint8List.fromList([0x10, 0x00]));
    setState(() {
      _status = "Connected";
    });
    return true;
  }

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    debugPrint('devicessss' + devices.toString());
    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName!),
          trailing: ElevatedButton(
          
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {
      print(_ports);
    });
  }

  @override
  void initState() {
    super.initState();

    var duration = const Duration(milliseconds: 100);

    Timer.periodic(duration, (timer) {
      print("timer"+test.toString());
      setState(() {
        if (test != 0.0) {
          traceX.add(test);
        }
      });
    });

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });
    _getPorts();
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
    _connectTo(null);
  }

  @override
  Widget build(BuildContext context) {
    // Create A Scope Display
    Oscilloscope scopeOne = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.orange,
      //margin: EdgeInsets.all(5.0),
      strokeWidth: 2.0,
      backgroundColor: Colors.white,
      traceColor: Colors.green,
      yAxisMax: 6450000.0,
      yAxisMin: 6430000.0,
      dataSet: traceX,
    );

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('USB Serial Plugin example app'),
      ),
      body: Column(children: <Widget>[
        Text(
            _ports.length > 0
                ? "Available Serial Ports"
                : "No serial devices available",
            style: Theme.of(context).textTheme.headline6),
        ..._ports,
         traceX != 0.0
        ? Container(
                height: 500,
                width: 1000,
                child: scopeOne,
              ):Container()

      ]),
    ));
  }}


