import 'package:bike_power_meter/models/goal_helper.dart';
import 'package:bike_power_meter/providers/auth.dart';
import 'package:bike_power_meter/providers/ride_data.dart';
import 'package:bike_power_meter/screens/btl_connect_screen.dart';
import 'package:bike_power_meter/screens/google_map_screen.dart';
import 'package:bike_power_meter/screens/historical_stat.screen.dart';
import 'package:bike_power_meter/screens/auth_screen.dart';
import 'package:bike_power_meter/screens/new_user_screen.dart';
import 'package:bike_power_meter/screens/set_goal_screen.dart';
import 'package:bike_power_meter/screens/user_main_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, RideData>(
          create: (_) => RideData("", "", []),
          update: (ctx, auth, previousData) => RideData(
            auth.token,
            auth.userId,
            previousData == null ? [] : previousData.histData,
          ),
        ),
        ChangeNotifierProvider(create: (ctx) => SetGoals()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Bike Power Meter',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? const UserMainMenu()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const CircularProgressIndicator()
                          : const AuthScreen(),
                ),
          routes: {
            UserMainMenu.routeName: (ctx) => const UserMainMenu(),
            NewUserScreen.routeName: (ctx) => const NewUserScreen(),
            HistoricalStatScreen.routeName: (ctx) =>
                const HistoricalStatScreen(),
            BTScreen.routeName: (ctx) => const BTScreen(),
            SetGoalScreen.routeName: (ctx) => const SetGoalScreen(),
            GoogleMapRouteScreen.routeName: (ctx) =>
                const GoogleMapRouteScreen(),
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (ctx) => const AuthScreen(),
            );
          },
        ),
      ),
    );
  }
}
