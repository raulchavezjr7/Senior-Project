import 'package:bike_power_meter/models/goal_helper.dart';
import 'package:bike_power_meter/providers/auth.dart';
import 'package:bike_power_meter/providers/ride_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetGoalScreen extends StatefulWidget {
  static const routeName = "/Set-Goal";
  const SetGoalScreen({Key? key}) : super(key: key);

  @override
  _SetGoalScreenState createState() => _SetGoalScreenState();
}

final goals = SetGoals();
final rpmController = TextEditingController();
final powerController = TextEditingController();
final speedController = TextEditingController();

class _SetGoalScreenState extends State<SetGoalScreen> {
  bool submitData() {
    if (rpmController.text.isNotEmpty) {
      goals.setRpmGoal(double.parse(rpmController.text));
    } else {
      goals.setRpmGoal(0);
    }
    if (powerController.text.isNotEmpty) {
      goals.setPowerGoal(double.parse(powerController.text));
    } else {
      goals.setPowerGoal(0);
    }

    if (speedController.text.isNotEmpty) {
      goals.setSpeedGoal(double.parse(speedController.text));
    } else {
      goals.setSpeedGoal(0);
    }
    if (rpmController.text.isEmpty &&
        powerController.text.isEmpty &&
        speedController.text.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Set Goal"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  "Goals are set to 0 by default",
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  "Once a goal is set, the value in the ride screen will turn red went goals are below the set value",
                  textAlign: TextAlign.center,
                ),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Power'),
                keyboardType: TextInputType.number,
                controller: powerController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Speed'),
                keyboardType: TextInputType.number,
                controller: speedController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'RPM'),
                keyboardType: TextInputType.number,
                controller: rpmController,
              ),
              ElevatedButton(
                onPressed: () {
                  var value = submitData();
                  if (value) {
                    Provider.of<RideData>(context, listen: false)
                        .fetchAndSetUserData();
                    goals.setGoalInServer(authData.token, authData.userId);
                    Navigator.of(context).pop();
                  } else {}
                },
                child: const Text("Set Goal"),
              )
            ],
          ),
        ));
  }
}
