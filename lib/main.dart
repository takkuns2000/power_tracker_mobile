import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'viewmodels/realtime_viewmodel.dart';
import 'viewmodels/measurement_viewmodel.dart';
import 'viewmodels/records_viewmodel.dart';
import 'viewmodels/garage_viewmodel.dart';
import 'services/database_service.dart';
import 'services/gps_service.dart';
import 'services/purchase_service.dart';
import 'repositories/vehicle_repository.dart';
import 'viewmodels/gps_viewmodel.dart';
import 'views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbService = DatabaseService();
  await dbService.initialize();
  runApp(HorsepowerTrackerApp(dbService: dbService));
}

class HorsepowerTrackerApp extends StatelessWidget {
  const HorsepowerTrackerApp({super.key, required this.dbService});

  final DatabaseService dbService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: dbService),
        ChangeNotifierProvider(create: (_) => PurchaseService()),
        Provider(
          create: (ctx) => VehicleRepository(ctx.read<DatabaseService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GarageViewModel(
            ctx.read<VehicleRepository>(),
            ctx.read<PurchaseService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => GpsService()..initialize()),
        ChangeNotifierProvider(
          create: (ctx) => GpsViewModel(ctx.read<GpsService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => RealtimeViewModel(ctx.read<GpsService>()),
        ),
        ChangeNotifierProvider(create: (_) => MeasurementViewModel()),
        ChangeNotifierProvider(create: (_) => RecordsViewModel()),
      ],
      child: MaterialApp(
        title: 'HorsepowerTracker',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('ja')],
        home: const MainScreen(),
      ),
    );
  }
}
