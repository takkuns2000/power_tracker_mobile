import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/repositories/vehicle_repository.dart';
import 'package:horsepower_tracker_mobile/services/purchase_service.dart';
import 'package:horsepower_tracker_mobile/viewmodels/garage_viewmodel.dart';
import 'package:horsepower_tracker_mobile/viewmodels/vehicle_settings_viewmodel.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockPurchaseService extends Mock implements PurchaseService {}

final _vehicles = [
  Vehicle(
    id: 1,
    name: '車両A',
    weightKg: 1200,
    drivetrain: Drivetrain.fwd,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  ),
  Vehicle(
    id: 2,
    name: '車両B',
    weightKg: 1400,
    drivetrain: Drivetrain.rwd,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  ),
];

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  late MockVehicleRepository repo;
  late MockPurchaseService purchaseService;

  setUp(() {
    repo = MockVehicleRepository();
    purchaseService = MockPurchaseService();
    when(() => purchaseService.isPro).thenReturn(false);
    when(() => repo.getAll()).thenAnswer((_) async => _vehicles);
  });

  group('初期化', () {
    test('コンストラクタで loadVehicles() が呼ばれ vehicles が設定される', () async {
      final vm = GarageViewModel(repo, purchaseService);
      await Future.microtask(() {});

      verify(() => repo.getAll()).called(1);
      expect(vm.vehicles, _vehicles);
    });
  });

  group('loadVehicles()', () {
    test('isLoading が true → false と遷移し vehicles が更新される', () async {
      final vm = GarageViewModel(repo, purchaseService);
      final loadingStates = <bool>[];
      vm.addListener(() => loadingStates.add(vm.isLoading));

      await vm.loadVehicles();

      expect(loadingStates, containsAllInOrder([true, false]));
      expect(vm.vehicles, _vehicles);
    });

    test('vehicles は外部から変更できない（unmodifiable）', () async {
      final vm = GarageViewModel(repo, purchaseService);
      await Future.microtask(() {});

      expect(() => vm.vehicles.add(_vehicles[0]), throwsUnsupportedError);
    });
  });

  group('deleteVehicle()', () {
    test('delete() を呼んだ後 loadVehicles() が再実行される', () async {
      when(() => repo.delete(1)).thenAnswer((_) async {});
      final vm = GarageViewModel(repo, purchaseService);
      await Future.microtask(() {});

      await vm.deleteVehicle(1);

      verify(() => repo.delete(1)).called(1);
      verify(() => repo.getAll()).called(2); // 初期化 + delete後
    });
  });

  group('isPro', () {
    test('PurchaseService が false のとき false を返す', () {
      final vm = GarageViewModel(repo, purchaseService);
      expect(vm.isPro, false);
    });

    test('PurchaseService が true のとき true を返す', () {
      when(() => purchaseService.isPro).thenReturn(true);
      final vm = GarageViewModel(repo, purchaseService);
      expect(vm.isPro, true);
    });
  });

  group('createSettingsViewModel()', () {
    test('VehicleSettingsViewModel を返す', () async {
      final vm = GarageViewModel(repo, purchaseService);
      await Future.microtask(() {});

      final settingsVm = vm.createSettingsViewModel();
      expect(settingsVm, isA<VehicleSettingsViewModel>());
      expect(settingsVm.isEditing, false);
      settingsVm.dispose();
    });

    test('vehicle を渡すと isEditing が true になる', () async {
      final vm = GarageViewModel(repo, purchaseService);
      await Future.microtask(() {});

      final settingsVm = vm.createSettingsViewModel(vehicle: _vehicles[0]);
      expect(settingsVm.isEditing, true);
      settingsVm.dispose();
    });
  });
}
