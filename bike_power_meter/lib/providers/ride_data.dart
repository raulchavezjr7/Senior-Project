import 'package:bike_power_meter/providers/user_specific_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RideData with ChangeNotifier {
  List<UserSpecificData> histData = [];
  final String authToken;
  final String userId;

  RideData(this.authToken, this.userId, this.histData);
  double power = 0;
  double rpm = 0;
  double speed = 0;

  List<UserSpecificData> get prevData {
    return [...histData];
  }

  Future<void> fetchAndSetUserData([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="riderId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://bike-power-meter-default-rtdb.firebaseio.com/rideData.json?auth=$authToken$filterString');
    try {
      final reposnse = await http.get(url);
      final extractedDate = json.decode(reposnse.body) as Map<String, dynamic>;
      if (extractedDate == null) {
        return;
      }
      url = Uri.parse(
          'https://bike-power-meter-default-rtdb.firebaseio.com/setGoal/$userId.json?auth=$authToken');
      final setGoals = await http.get(url);
      final goalData = json.decode(setGoals.body);
      power = double.parse(goalData['powerGoal']);
      rpm = double.parse(goalData['rpmGoal']);
      speed = double.parse(goalData['speedGoal']);
      final List<UserSpecificData> loadedHistoricalData = [];
      extractedDate.forEach((riderId, historicalData) {
        loadedHistoricalData.add(
          UserSpecificData(
            id: riderId,
            dateMonth: historicalData['dateMonth'],
            dateDay: historicalData['dateDay'],
            dateYear: historicalData['dateYear'],
            rpm: historicalData['rpm'],
            power: historicalData['power'],
            speed: historicalData['speed'],
            timeOfRide: historicalData['timeOfRide'],
          ),
        );
      });
      histData = loadedHistoricalData;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> adddata(UserSpecificData data) async {
    final url = Uri.parse(
        'https://bike-power-meter-default-rtdb.firebaseio.com/rideData.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'dateMonth': data.dateMonth,
          'dateDay': data.dateDay,
          'dateYear': data.dateYear,
          'rpm': data.rpm,
          'power': data.power,
          'speed': data.speed,
          'timeOfRide': data.timeOfRide,
          'riderId': userId,
        }),
      );

      final newdata = UserSpecificData(
        id: json.decode(response.body)['name'],
        dateMonth: data.dateMonth,
        dateDay: data.dateDay,
        dateYear: data.dateYear,
        rpm: data.rpm,
        power: data.power,
        speed: data.speed,
        timeOfRide: data.timeOfRide,
      );
      histData.add(newdata);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

//   Future<void> deletedata(String id) async {
//     final url = Uri.parse(
//         'https://bike-power-meter-default-rtdb.firebaseio.com/rideData/$id.json?auth=$authToken');
//     final exisitingdataIndex = histData.indexWhere((prod) => prod.id == id);
//     UserSpecificData? exsitingdata = histData[exisitingdataIndex];
//     histData.removeAt(exisitingdataIndex);
//     notifyListeners();
//     final response = await http.delete(url);
//     if (response.statusCode >= 400) {
//       histData.insert(exisitingdataIndex, exsitingdata);
//       notifyListeners();
//       throw HttpException('Could not delete data');
//     }
//     exsitingdata = null;
//   }
}
