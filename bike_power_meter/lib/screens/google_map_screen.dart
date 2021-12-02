import 'package:flutter/material.dart';

class GoogleMapRouteScreen extends StatelessWidget {
  static const routeName = "/google-map-screen";
  const GoogleMapRouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Last Map Route"),
        ),
        body: const Text(
          "Coming Soon",
          textAlign: TextAlign.center,
        ));
  }
}
