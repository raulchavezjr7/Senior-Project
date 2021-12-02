import 'package:flutter/cupertino.dart';

class UserSpecificData with ChangeNotifier {
  final String? id;
  final String dateMonth;
  final String dateDay;
  final String dateYear;
  final String rpm;
  final String power;
  final String speed;
  final String timeOfRide;

  UserSpecificData({
    required this.id,
    required this.dateMonth,
    required this.dateDay,
    required this.dateYear,
    required this.rpm,
    required this.power,
    required this.speed,
    required this.timeOfRide,
  });
}
