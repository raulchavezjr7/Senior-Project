import 'package:bike_power_meter/providers/auth.dart';
import 'package:bike_power_meter/screens/btl_connect_screen.dart';
import 'package:bike_power_meter/screens/google_map_screen.dart';
import 'package:bike_power_meter/screens/historical_stat.screen.dart';
import 'package:bike_power_meter/screens/set_goal_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserMainMenu extends StatelessWidget {
  static const routeName = '/user=main-menu';
  const UserMainMenu({Key? key}) : super(key: key);

  Widget card(String title, String screen, context, orentation) {
    double widthParameter = 0;
    double heightParameter = 0;
    if (orentation == Orientation.landscape) {
      widthParameter = .45;
      heightParameter = .33;
    } else {
      widthParameter = .445;
      heightParameter = .40;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(screen);
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * widthParameter,
        height: MediaQuery.of(context).size.height * heightParameter,
        child: Card(
          color: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          margin: const EdgeInsets.all(5),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var orentation = MediaQuery.of(context).orientation;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Main Menu!'),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  //Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Auth>(context, listen: false).logout();
                },
                icon: const Icon(Icons.logout)),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  card('Start Ride', BTScreen.routeName, context, orentation),
                  card('Google Map Route', GoogleMapRouteScreen.routeName,
                      context, orentation)
                ],
              ),
              Column(
                children: <Widget>[
                  card('Historical Stats', HistoricalStatScreen.routeName,
                      context, orentation),
                  card('Set Goal', SetGoalScreen.routeName, context, orentation)
                ],
              )
            ],
          ),
        ));
  }
}
