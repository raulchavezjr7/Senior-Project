import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class UserData extends StatelessWidget {
  final String? id;
  final String dateMonth;
  final String dateDay;
  final String dateYear;
  final String rpm;
  final String power;
  final String speed;
  final String timeOfRide;

  const UserData({
    required this.id,
    required this.dateMonth,
    required this.dateDay,
    required this.dateYear,
    required this.rpm,
    required this.power,
    required this.speed,
    required this.timeOfRide,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Time Elapsed \n $timeOfRide",
        style: const TextStyle(
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
      leading: Text("Date \n$dateMonth/$dateDay/$dateYear",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          )),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * .32,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Text(
                "Average RPM $rpm",
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
                width: double.infinity,
                child: Text(
                  "Average Power $power",
                  textAlign: TextAlign.left,
                )),
            SizedBox(
                width: double.infinity,
                child: Text(
                  "Average Speed $speed",
                  textAlign: TextAlign.left,
                )),
          ],
        ),
      ),
    );
  }
}
