import 'dart:async';
import 'dart:convert' show utf8;
import 'package:bike_power_meter/models/goal_helper.dart';
import 'package:bike_power_meter/models/historical_stats.dart';
import 'package:bike_power_meter/models/stop_watch.dart';
import 'package:bike_power_meter/providers/ride_data.dart';
import 'package:bike_power_meter/providers/user_specific_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/stop_watch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class RideScreen extends StatefulWidget {
  static const routeName = "/ride-screen";
  final BluetoothDevice device;
  const RideScreen({Key? key, required this.device}) : super(key: key);

  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final String serviceUiid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String characteristicsUiid = "0000ffe1-0000-1000-8000-00805f9b34fb";
  late bool isReady;
  late Stream<List<int>> stream;
  late final stopWatch = StopTimer();
  late final Timer runTimer;
  final historicalStats = HistoricalStats();
  final goals = SetGoals();
  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    stopWatch.timerstart();
    runTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    runTimer.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  connectToDevice() async {
    if (widget.device == null) {
      poP();
      return;
    }

    Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        poP();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      poP();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      poP();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUiid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicsUiid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            setState(() async {
              isReady = true;
            });
          }
        }
      }
    }

    if (!isReady) {
      poP();
    }
  }

  poP() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  double speed = 000;

  getSpeed() async {
    Geolocator.getPositionStream(
            forceAndroidLocationManager: true,
            intervalDuration: const Duration(seconds: 1),
            distanceFilter: 2,
            desiredAccuracy: LocationAccuracy.bestForNavigation)
        .listen((position) {
      //var speedInMps = position.speed.toStringAsPrecision(2);
      speed = position.speed;
    });
  }

  String speedValue() {
    getSpeed();
    if (speed.toStringAsPrecision(1) == null) {
      return "99999";
    } else {
      historicalStats.setAverageSpeed(speed);
      return speed.toStringAsPrecision(2);
    }
  }

  String rpmValue = "";
  String oldRpm = "0";
  String oldPower = "0";

  setRmpValue(String value) {
    rpmValue = value;
  }

  double heightParameter = 0;
  double widthParameter = 0;
  late FloatingActionButtonLocation actionButtonLocation;

  rpmGoalColorSet(value) {
    var rpm = value;
    while (rpm != "") {
      if (double.parse(rpm) < goals.getRpmGoal()) {
        return Colors.red;
      } else {
        return Colors.black;
      }
    }
    return Colors.green;
  }

  powerGoalColorSet(value) {
    var power = value;
    while (power != "") {
      if (double.parse(power) < goals.getPowerGoal()) {
        return Colors.red;
      } else {
        return Colors.black;
      }
    }
    return Colors.green;
  }

  speedGoalColorSet(value) {
    var speed = value;
    while (speed != "") {
      if (double.parse(speed) < goals.getSpeedGoal()) {
        return Colors.red;
      } else {
        return Colors.black;
      }
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<RideData>(context, listen: false).fetchAndSetUserData();
    goals.setPowerGoal((Provider.of<RideData>(context).power));
    goals.setRpmGoal(Provider.of<RideData>(context).rpm);
    goals.setSpeedGoal(Provider.of<RideData>(context).speed);

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      heightParameter = .5;
      widthParameter = .2;
      actionButtonLocation = FloatingActionButtonLocation.centerFloat;
    } else {
      heightParameter = .17;
      widthParameter = .5;
      actionButtonLocation = FloatingActionButtonLocation.startFloat;
    }
    var children2 = <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: MediaQuery.of(context).size.height * heightParameter,
        width: MediaQuery.of(context).size.width * widthParameter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.timer,
              size: 40,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              stopWatch.formatTime(stopWatch.timerRead()),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      ),
      StreamBuilder<List<int>>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.active) {
            var currentValue = _dataParser(snapshot.data!);
            var indexOfCurrentValue = currentValue.toString().indexOf(",");
            String powerValue = currentValue.isNotEmpty
                ? currentValue.toString().substring(0, indexOfCurrentValue)
                : "0";
            String rpmValue = currentValue.isNotEmpty
                ? currentValue.toString().substring(
                    indexOfCurrentValue + 1, currentValue.lastIndexOf("/"))
                : "0";
            if (double.parse(powerValue) <= 0) {
              powerValue = oldPower;
            } else {
              oldPower = powerValue;
            }
            if (double.parse(rpmValue) <= 0) {
              rpmValue = oldRpm;
            } else {
              oldRpm = rpmValue;
            }
            if (((double.parse(powerValue) / 1000) - 40) * 100 > 0) {
              powerValue = ((((double.parse(powerValue) / 1000) - 40) * 100)
                  .toStringAsFixed(2));
            }

            if ((double.parse(rpmValue) - 1920) > 0) {
              rpmValue = (double.parse(rpmValue) - 1920).toStringAsFixed(2);
            }
            historicalStats.setAveragePower(double.parse(powerValue));
            historicalStats.setAverageCadance(double.parse(rpmValue));
            setRmpValue(rpmValue);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: MediaQuery.of(context).size.height * heightParameter,
              width: MediaQuery.of(context).size.width * widthParameter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    CupertinoIcons.bolt_fill,
                    // Icons.battery_charging_full,
                    size: 40,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    powerValue,
                    style: TextStyle(color: powerGoalColorSet(powerValue)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            );
          } else {
            return const Text('Error try again');
          }
        },
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: MediaQuery.of(context).size.height * heightParameter,
        width: MediaQuery.of(context).size.width * widthParameter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.speed,
              size: 40,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              speedValue(),
              style: TextStyle(color: speedGoalColorSet(speedValue())),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: MediaQuery.of(context).size.height * heightParameter,
        width: MediaQuery.of(context).size.width * widthParameter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(CupertinoIcons.metronome),
            const SizedBox(
              height: 15,
            ),
            Text(
              rpmValue,
              style: TextStyle(color: rpmGoalColorSet(rpmValue)),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      ),
    ];
    var scaffoldPortrait = Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children2,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(
          Icons.stop,
          color: Colors.black,
        ),
        onPressed: () {
          historicalStats
              .setTimeElapse(stopWatch.formatTime(stopWatch.timerRead()));
          historicalStats
              .setDate(DateFormat.yMd().format(DateTime.now()).toString());
          stopWatch.timerStop;
          final userRideData = UserSpecificData(
              id: null,
              dateMonth: historicalStats.date
                  .toString()
                  .substring(0, historicalStats.date.toString().indexOf("/")),
              dateDay: historicalStats.date.toString().substring(
                  historicalStats.date.toString().indexOf("/") + 1,
                  historicalStats.date.toString().lastIndexOf("/")),
              dateYear: historicalStats.date.toString().substring(
                  historicalStats.date.toString().lastIndexOf("/") + 1),
              rpm: historicalStats.averageCadance.toStringAsFixed(2),
              power: historicalStats.averagePower.toStringAsFixed(2),
              speed: historicalStats.averageSpeed.toStringAsFixed(2),
              timeOfRide: historicalStats.timeElapsed);
          Provider.of<RideData>(context, listen: false).adddata(userRideData);
          disconnectFromDevice();
          Navigator.of(context).pop();
        },
      ),
      floatingActionButtonLocation: actionButtonLocation,
    );
    var scaffoldLandsacpe = Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children2,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(
          Icons.stop,
          color: Colors.black,
        ),
        onPressed: () {
          historicalStats
              .setTimeElapse(stopWatch.formatTime(stopWatch.timerRead()));
          historicalStats
              .setDate(DateFormat.yMd().format(DateTime.now()).toString());
          stopWatch.timerStop;
          final userRideData = UserSpecificData(
              id: null,
              dateMonth: historicalStats.date
                  .toString()
                  .substring(0, historicalStats.date.toString().indexOf("/")),
              dateDay: historicalStats.date.toString().substring(
                  historicalStats.date.toString().indexOf("/") + 1,
                  historicalStats.date.toString().lastIndexOf("/")),
              dateYear: historicalStats.date.toString().substring(
                  historicalStats.date.toString().lastIndexOf("/") + 1),
              rpm: historicalStats.averageCadance.toStringAsFixed(2),
              power: historicalStats.averagePower.toStringAsFixed(2),
              speed: historicalStats.averageSpeed.toStringAsFixed(2),
              timeOfRide: historicalStats.timeElapsed);
          Provider.of<RideData>(context, listen: false).adddata(userRideData);
          disconnectFromDevice();
          Navigator.of(context).pop();
        },
      ),
      floatingActionButtonLocation: actionButtonLocation,
    );
    return Container(
      child: !isReady
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : MediaQuery.of(context).orientation == Orientation.landscape
              ? scaffoldLandsacpe
              : scaffoldPortrait,
    );
  }
}
