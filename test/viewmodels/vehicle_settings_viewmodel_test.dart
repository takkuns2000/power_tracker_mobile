import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/repositories/vehicle_repository.dart';
import 'package:horsepower_tracker_mobile/services/purchase_service.dart';
import 'package:horsepower_tracker_mobile/viewmodels/vehicle_settings_viewmodel.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockPurchaseService extends Mock implements PurchaseService {}

final _baseVehicle = Vehicle(
  id: 1,
  name: 'テスト車両',
  weightKg: 1200,
  drivetrain: Drivetrain.fwd,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(_baseVehicle);
  });

  late MockVehicleRepository repo;
  late MockPurchaseService purchaseService;

  setUp(() {
    repo = MockVehicleRepository();
    purchaseService = MockPurchaseService();
    when(() => purchaseService.isPro).thenReturn(false);
  });

  VehicleSettingsViewModel build({Vehicle? vehicle}) {
    return VehicleSettingsViewModel(
      repository: repo,
      purchaseService: purchaseService,
      vehicle: vehicle,
    );
  }

  group('バリデーション', () {
    test('名前が空の場合 saveError がセットされ insert() は呼ばれない', () async {
      final vm = build();
      vm.weightController.text = '1200';
      vm.selectDrivetrain(Drivetrain.fwd);

      await vm.save();
      expect(vm.saveError, isNotNull);
      verifyNever(() => repo.insert(any()));
      vm.dispose();
    });

    test('重量が空の場合 saveError がセットされ insert() は呼ばれない', () async {
      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.selectDrivetrain(Drivetrain.fwd);

      await vm.save();
      expect(vm.saveError, isNotNull);
      verifyNever(() => repo.insert(any()));
      vm.dispose();
    });

    test('重量が数値以外の場合 saveError がセットされ insert() は呼ばれない', () async {
      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.weightController.text = 'abc';
      vm.selectDrivetrain(Drivetrain.fwd);

      await vm.save();
      expect(vm.saveError, isNotNull);
      verifyNever(() => repo.insert(any()));
      vm.dispose();
    });

    test('駆動方式が未選択の場合 saveError がセットされ insert() は呼ばれない', () async {
      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.weightController.text = '1200';

      await vm.save();
      expect(vm.saveError, isNotNull);
      verifyNever(() => repo.insert(any()));
      vm.dispose();
    });

    test('saveError は clearSaveError() でリセットされる', () async {
      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.weightController.text = '1200';

      await vm.save();
      expect(vm.saveError, isNotNull);
      vm.clearSaveError();
      expect(vm.saveError, isNull);
      vm.dispose();
    });
  });

  group('新規保存', () {
    test('必須項目が揃っている場合 insert() を呼び saveSuccess が true になる', () async {
      when(() => repo.insert(any())).thenAnswer((_) async => _baseVehicle);
      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.weightController.text = '1200';
      vm.selectDrivetrain(Drivetrain.fwd);

      await vm.save();
      expect(vm.saveError, isNull);
      verify(() => repo.insert(any())).called(1);
      vm.dispose();
    });

    test('Pro ユーザーはタイヤサイズが保存される', () async {
      when(() => purchaseService.isPro).thenReturn(true);
      when(() => repo.insert(any())).thenAnswer((_) async => _baseVehicle);

      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.weightController.text = '1200';
      vm.selectDrivetrain(Drivetrain.rwd);
      vm.tireWidthController.text = '225';
      vm.tireAspectController.text = '45';
      vm.tireRimController.text = '18';
      vm.finalGearController.text = '3.9';

      await vm.save();
      expect(vm.saveError, isNull);
      final captured =
          verify(() => repo.insert(captureAny())).captured.first as Vehicle;
      expect(captured.tireSize?.widthMm, 225);
      expect(captured.finalGearRatio?.ratio, 3.9);
      vm.dispose();
    });

    test('非 Pro ユーザーはタイヤサイズが保存されない', () async {
      when(() => repo.insert(any())).thenAnswer((_) async => _baseVehicle);

      final vm = build();
      vm.nameController.text = 'テスト車両';
      vm.weightController.text = '1200';
      vm.selectDrivetrain(Drivetrain.fwd);
      vm.tireWidthController.text = '225';
      vm.tireAspectController.text = '45';
      vm.tireRimController.text = '18';

      await vm.save();
      final captured =
          verify(() => repo.insert(captureAny())).captured.first as Vehicle;
      expect(captured.tireSize, null);
      vm.dispose();
    });
  });

  group('編集保存', () {
    test('既存 vehicle がある場合 update() を呼び saveError が null になる', () async {
      when(() => repo.update(any())).thenAnswer((_) async {});
      final vm = build(vehicle: _baseVehicle);
      vm.nameController.text = '更新後車両';
      vm.weightController.text = '1300';
      vm.selectDrivetrain(Drivetrain.rwd);

      await vm.save();
      expect(vm.saveError, isNull);
      verify(() => repo.update(any())).called(1);
      verifyNever(() => repo.insert(any()));
      vm.dispose();
    });

    test('DB例外が発生した場合 saveError がセットされる', () async {
      when(() => repo.update(any())).thenThrow(Exception('DB error'));
      final vm = build(vehicle: _baseVehicle);
      vm.nameController.text = '更新後車両';
      vm.weightController.text = '1300';
      vm.selectDrivetrain(Drivetrain.rwd);

      await vm.save();
      expect(vm.saveError, isNotNull);
      vm.dispose();
    });
  });

  group('selectDrivetrain()', () {
    test('drivetrain が更新される', () {
      final vm = build();
      vm.selectDrivetrain(Drivetrain.awd);
      expect(vm.drivetrain, Drivetrain.awd);
      vm.dispose();
    });

    test('null を渡すと drivetrain が null になる', () {
      final vm = build();
      vm.selectDrivetrain(Drivetrain.rwd);
      vm.selectDrivetrain(null);
      expect(vm.drivetrain, null);
      vm.dispose();
    });
  });

  group('isEditing', () {
    test('vehicle=null のとき false', () {
      final vm = build();
      expect(vm.isEditing, false);
      vm.dispose();
    });

    test('vehicle あり のとき true', () {
      final vm = build(vehicle: _baseVehicle);
      expect(vm.isEditing, true);
      vm.dispose();
    });
  });

  group('isPro', () {
    test('PurchaseService が false のとき false を返す', () {
      final vm = build();
      expect(vm.isPro, false);
      vm.dispose();
    });

    test('PurchaseService が true のとき true を返す', () {
      when(() => purchaseService.isPro).thenReturn(true);
      final vm = build();
      expect(vm.isPro, true);
      vm.dispose();
    });
  });
}
