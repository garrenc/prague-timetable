import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetable/models/stop.dart';
import 'package:timetable/providers/departures/departures_provider.dart';
import 'package:timetable/screens/vehicle_map_screen.dart';
import 'package:timetable/widgets/empty_container.dart';
import 'package:timetable/widgets/error_widget.dart';

class DeparturesScreen extends ConsumerStatefulWidget {
  final Stop stop;
  const DeparturesScreen({super.key, required this.stop});

  @override
  ConsumerState<DeparturesScreen> createState() => _DeparturesScreenState();
}

class _DeparturesScreenState extends ConsumerState<DeparturesScreen> {
  Future<void> _onRefresh() async {
    final provider = departuresNotifierProvider(widget.stop.ids, stationName: widget.stop.name);
    ref.read(provider.notifier).loadDepartures();
  }

  @override
  Widget build(BuildContext context) {
    final provider = departuresNotifierProvider(widget.stop.ids, stationName: widget.stop.name);

    final departuresAsync = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.stop.name), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: departuresAsync.when(
          data: (platformDepartures) {
            if (platformDepartures.isEmpty) {
              return ListView(
                // Make it scrollable so pull-to-refresh still works
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.25), EmptyContainer(icon: Icons.schedule, title: 'Žádné odjezdy nejsou naplánovány')],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16),
              itemCount: platformDepartures.length,
              itemBuilder: (context, platformIndex) {
                final platformGroup = platformDepartures[platformIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8.0)),
                        child: Row(
                          children: [
                            Icon(Icons.train, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.stop.name} ${platformGroup.platform}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Departures for this platform
                    ...platformGroup.departures.map<Widget>((departure) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: departure.route.color, child: Icon(departure.route.transportType.icon, color: Theme.of(context).colorScheme.onPrimary)),
                          title: Row(
                            children: [
                              Text(departure.route.linkName, style: _bodyMediumStyle?.copyWith(color: departure.route.color)),
                              const SizedBox(width: 12),
                              if (departure.direction != null) Expanded(child: Text(' ${departure.direction}', style: _bodyMediumStyle)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(departure.formattedTimeScheduled, style: _bodyMediumStyle),
                                  if (departure.difference > 0) Text('+${departure.difference} min', style: _bodyMediumStyle?.copyWith(color: _getTimeColor(departure.difference))),
                                ],
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VehicleMapScreen(vehicleId: departure.vehicleId ?? '', routeName: departure.route.linkName, headsign: departure.direction ?? ''),
                                    ),
                                  );
                                },
                                child: const SizedBox(width: 24, height: 24, child: Icon(Icons.map_outlined, size: 20)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
          loading: () {
            return Center(child: Text('Načítání...'));
          },
          error: (error, stackTrace) {
            // Scrollable error so refresh works
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                ErrorStateWidget(
                  message: 'Chyba při načítání odjezdů',
                  details: error.toString(),
                  onRetry: () async {
                    await _onRefresh(); // pull the provider again
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  TextStyle? get _bodyMediumStyle => Theme.of(context).textTheme.bodyMedium;

  Color _getTimeColor(int time) {
    if (time <= 5) return Colors.green;
    if (time <= 15) return Colors.orange;
    return Colors.red;
  }
}
