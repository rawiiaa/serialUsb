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
  List<_ChartData>? chartData;
  List<_ChartTest>? chartTest;

  late int count;
  ChartSeriesController? _chartSeriesController;
  ChartSeries? _chartSeries;

  @override

  @override

  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  List _serialData = [];
  List _serialusb= [];
  List<double> traceX =[];
  List<double> essai =[200.30,150.0,800.2,100.5];
  int i = 0;
  int ecg = 0;
  List<double> traceSine = [];
  List<double> traceCosine = [];
  double radians = 0.0;
  Timer? _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine



  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  TextEditingController _textController = TextEditingController();

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
    debugPrint('portsssss'+_port.toString());

    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);

    _port!.setPortParameters(9600, UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    _port!.inputStream!.listen((Uint8List event) {
      setState(() {
        String s = new String.fromCharCodes(event);
        try {
        ecg = int.parse(s);

           double test = double.parse(ecg.toString());
           double tt = test /10000000;
           _serialData.add(Text(test.toString()));
           traceX.add(test);
           debugPrint('ECGG'+traceX.toString());
           debugPrint('Value'+test.toString());
         }catch (error) {
          print(error);
        }


        /*_serialusb.add(ecg);
        debugPrint('ECG'+ecg.toString());
          chartData?.add(_ChartData(i++,ecg));*/




      });

      _port!.close();
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
    debugPrint('devicessss'+devices.toString());
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
    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });


  }

  @override
  void dispose() {
    timer?.cancel();
    chartData!.clear();
    _chartSeriesController = null;
    _chartSeries = null;

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
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 6500000.0,
      yAxisMin: 6100000.0,
      dataSet: traceX,
    );
    debugPrint('Chart'+traceX.toString());

    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('USB Serial Plugin example app'),
          ),
          body:
                  Column(children: <Widget>[

                      Material(
                          color: Colors.transparent,
                          child: Ink(
                              decoration: BoxDecoration(
                                color:Color.fromRGBO(64, 184, 233, 1),
                                borderRadius: BorderRadius.circular(70),
                              ),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  Chart()),
                                    );
                                  },
                                  child: Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      height: 40,
                                      padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 9,
                                          left: 5,
                                          right: 5),

                                      child: Text(
                                        'Chart',
                                        textAlign: TextAlign.center,

                                      ))))),
                      Text(_ports.length > 0 ? "Available Serial Ports" : "No serial devices available", style: Theme.of(context).textTheme.headline6),
                      ..._ports,
                      Text('info: ${_port.toString()}\n'),
                         _serialData.isNotEmpty
                         ?Container(
                           height: 500,
                           width: 400,
                             child: scopeOne,
                         )
                             :Container()

                    ]),
        ));
  }
  /*SfCartesianChart _buildLiveLineChart() {

   return SfCartesianChart(

     series:
     _serialData.isNotEmpty

     ?<LineSeries<_ChartData, int>>[

        LineSeries<_ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            // Assigning the controller to the _chartSeriesController.
            _chartSeriesController = controller;
          },
          // Binding the chartData to the dataSource of the line series.
          dataSource: chartData!,
          xValueMapper: (_ChartData sales, _) => sales.country,
          yValueMapper: (_ChartData sales, _) => sales.sales,
        )


      ]:<LineSeries<_ChartTest, int>>[

       LineSeries<_ChartTest, int>(
         onRendererCreated: (ChartSeriesController controller) {
           // Assigning the controller to the _chartSeriesController.
           _chartSeriesController = controller;
         },
         // Binding the chartData to the dataSource of the line series.
         dataSource: chartTest!,
         xValueMapper: (_ChartTest sales, _) => sales.test1,
         yValueMapper: (_ChartTest sales, _) => sales.test2,
       )


     ]
     ,
    )
    ;
  }*/


}
class _ChartData {
  _ChartData(this.country, this.sales);
  final int country;
  final num sales;
}
class _ChartTest {
  _ChartTest(this.test1, this.test2);
  final int test1;
  final num test2;
}
