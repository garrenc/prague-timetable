import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:timetable/providers/stops/stops_provider.dart';
import 'package:timetable/widgets/empty_container.dart';
import 'package:timetable/widgets/error_widget.dart';
import 'departures_screen.dart';

class StopsScreen extends ConsumerStatefulWidget {
  const StopsScreen({super.key});

  @override
  ConsumerState<StopsScreen> createState() => _StopsScreenState();
}

class _StopsScreenState extends ConsumerState<StopsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopsAsync = ref.watch(stopsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zastávky MHD'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                ref.read(stopsNotifierProvider.notifier).searchStops(value);
              },
              decoration: InputDecoration(
                hintText: 'Hledat zastávku...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(stopsNotifierProvider.notifier).searchStops('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: stopsAsync.when(
              data: (stops) {
                if (_searchController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus_outlined, size: 80, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 24),
                        Text('Zadejte název zastávky', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text('pro zobrazení jízdních řádů', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text('MHD Praha', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                if (stops.isEmpty) {
                  return EmptyContainer(icon: Icons.search_off, title: 'Žádné zastávky neodpovídají vyhledávání');
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    itemCount: stops.length,
                    itemBuilder: (context, index) {
                      final stop = stops[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.onPrimary)),
                                title: Text(stop.name, style: Theme.of(context).textTheme.titleMedium),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DeparturesScreen(stop: stop)));
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: Text('Načítání...')),
              error:
                  (error, stackTrace) => ErrorStateWidget(
                    message: 'Chyba při načítání zastávek',
                    details: error.toString(),
                    onRetry: () {
                      ref.read(stopsNotifierProvider.notifier).searchStops(_searchController.text);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
