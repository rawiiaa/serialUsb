import 'dart:async';
import 'dart:math' as math;

/// Package imports
import 'package:flutter/material.dart';
import 'package:serial_usb/main.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

/// Local imports

class Chart extends StatefulWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

/// Renders the realtime line chart sample.
class _ChartState extends State<Chart> {

  _LiveLineChartState() {
    timer =
        Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
  }

  @override



  Timer? timer;
  List<_ChartData>? chartData;
  late int count;
  ChartSeriesController? _chartSeriesController;

  @override
  void dispose() {
    timer?.cancel();
    chartData!.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  @override
  void initState() {
    count = 19;
    chartData = <_ChartData>[
      _ChartData(0, 42),
      _ChartData(1, 47),
      _ChartData(2, 33),
      _ChartData(3, 49),
      _ChartData(4, 54),
      _ChartData(5, 41),
      _ChartData(6, 58),
      _ChartData(7, 51),
      _ChartData(8, 98),
      _ChartData(9, 41),
      _ChartData(10, 53),
      _ChartData(11, 72),
      _ChartData(12, 86),
      _ChartData(13, 52),
      _ChartData(14, 94),
      _ChartData(15, 92),
      _ChartData(16, 86),
      _ChartData(17, 72),
      _ChartData(18, 94),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            toolbarHeight: 80,
            elevation: 0.0,

            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios_sharp, color: Colors.black,
                size: 24.0,),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyApp())),
            ),

            title: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 7.0,
                  ),
                  Text(
                    'ECG tracing reports',
                    style: TextStyle(color: Colors.black, fontSize: 21.0),
                  ),

                ],
              ),
            ),
            centerTitle: true,

            backgroundColor: Colors.white),
   body:Column(
     children:[
       Container(
         child:_buildLiveLineChart()
       )
     ]
   ));
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
      series: <LineSeries<_ChartData, int>>[
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
      ],
    );
  }

  ///Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    chartData!.add(_ChartData(count, _getRandomInt(10, 100)));
    if (chartData!.length == 20) {
      chartData!.removeAt(0);
      _chartSeriesController?.updateDataSource(addedDataIndexes: <int>
      [chartData!.length - 1],
          removedDataIndexes: <int>[0]);
    }

  }
  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}

/// Private calss for storing the chart series data points.
class _ChartData {
  _ChartData(this.country, this.sales);
  final int country;
  final num sales;
}


