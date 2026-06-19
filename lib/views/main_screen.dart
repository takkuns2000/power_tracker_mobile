import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../viewmodels/navigation_viewmodel.dart';
import 'realtime/realtime_view.dart';
import 'measurement/measurement_preparation_view.dart';
import 'records/records_view.dart';
import 'garage/garage_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _tabs = [
    RealtimeView(),
    MeasurementPreparationView(),
    RecordsView(),
    GarageView(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavigationViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: vm.currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: vm.currentIndex,
        onDestinationSelected: context.read<NavigationViewModel>().setIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.bolt_outlined),
            selectedIcon: const Icon(Icons.bolt),
            label: l10n.navLive,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.navTrack,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.directions_car_outlined),
            selectedIcon: const Icon(Icons.directions_car),
            label: l10n.navVehicles,
          ),
        ],
      ),
    );
  }
}
