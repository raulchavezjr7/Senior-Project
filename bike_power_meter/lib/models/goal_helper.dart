import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class SetGoals with ChangeNotifier {
  static double rpmGoal = 0;
  static double powerGoal = 0;
  static double speedGoal = 0;

  double getRpmGoal() {
    return rpmGoal;
  }

  double getPowerGoal() {
    return powerGoal;
  }

  double getSpeedGoal() {
    return speedGoal;
  }

  void setRpmGoal(double value) {
    rpmGoal = value;
  }

  void setPowerGoal(double value) {
    powerGoal = value;
  }

  void setSpeedGoal(double value) {
    speedGoal = value;
  }

  Future<void> setGoalInServer(String? token, String? userId) async {
    final url = Uri.parse(
        'https://bike-power-meter-default-rtdb.firebaseio.com/setGoal/$userId.json?auth=$token');
    const double oldRpm = 0;
    const double oldPower = 0;
    const double oldSpeed = 0;
    try {
      final response = await http.put(
        url,
        body: json.encode({
          'rpmGoal': rpmGoal.toString(),
          'powerGoal': powerGoal.toString(),
          'speedGoal': speedGoal.toString(),
        }),
      );
      if (response.statusCode >= 400) {
        setRpmGoal(oldRpm);
        setSpeedGoal(oldSpeed);
        setPowerGoal(oldPower);
      }
    } catch (error) {
      setRpmGoal(oldRpm);
      setSpeedGoal(oldSpeed);
      setPowerGoal(oldPower);
    }
  }
}
