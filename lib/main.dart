import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'viewmodels/realtime_viewmodel.dart';
import 'viewmodels/measurement_viewmodel.dart';
import 'viewmodels/records_viewmodel.dart';
import 'viewmodels/garage_viewmodel.dart';
import 'services/gps_service.dart';
import 'viewmodels/gps_viewmodel.dart';
import 'views/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HorsepowerTrackerApp());
}

class HorsepowerTrackerApp extends StatelessWidget {
  const HorsepowerTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => GpsService()..initialize()),
        ChangeNotifierProvider(
          create: (ctx) => GpsViewModel(ctx.read<GpsService>()),
        ),
        ChangeNotifierProvider(create: (_) => RealtimeViewModel()),
        ChangeNotifierProvider(create: (_) => MeasurementViewModel()),
        ChangeNotifierProvider(create: (_) => RecordsViewModel()),
        ChangeNotifierProvider(create: (_) => GarageViewModel()),
      ],
      child: MaterialApp(
        title: 'HorsepowerTracker',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const MainScreen(),
      ),
    );
  }
}
