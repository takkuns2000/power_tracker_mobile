import 'package:flutter/material.dart';
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

    return Scaffold(
      body: IndexedStack(
        index: vm.currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: vm.currentIndex,
        onDestinationSelected: context.read<NavigationViewModel>().setIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'LIVE',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'TRACK',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'HISTORY',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'VEHICLES',
          ),
        ],
      ),
    );
  }
}
