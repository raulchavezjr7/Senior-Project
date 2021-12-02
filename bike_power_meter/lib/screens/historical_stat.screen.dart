import 'package:bike_power_meter/providers/ride_data.dart';
import 'package:bike_power_meter/widgets/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoricalStatScreen extends StatelessWidget {
  static const routeName = '/historical-stat-screen';

  const HistoricalStatScreen({Key? key}) : super(key: key);
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<RideData>(context, listen: false)
        .fetchAndSetUserData(true);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<RideData>(context, listen: false).fetchAndSetUserData(true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Historical Stats'),
      ),
      body: FutureBuilder(
        future: Provider.of<RideData>(context, listen: false)
            .fetchAndSetUserData(true),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<RideData>(
                      builder: (ctx, data, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserData(
                                id: data.histData[i].id,
                                dateMonth: data.histData[i].dateMonth,
                                dateDay: data.histData[i].dateDay,
                                dateYear: data.histData[i].dateYear,
                                rpm: data.histData[i].rpm,
                                power: data.histData[i].power,
                                speed: data.histData[i].speed,
                                timeOfRide: data.histData[i].timeOfRide,
                              ),
                              const Divider(),
                            ],
                          ),
                          itemCount: data.prevData.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
