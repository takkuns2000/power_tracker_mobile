import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/viewmodels/vehicle_selection_viewmodel.dart';

Vehicle _v({int? id = 1, double weightKg = 1000}) => Vehicle(
      id: id,
      name: 'テスト',
      weightKg: weightKg,
      drivetrain: Drivetrain.rwd,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

void main() {
  group('VehicleSelectionViewModel.reloadSelectedVehicle', () {
    test('リストに更新済み車両がある場合、重量が反映される', () {
      final vm = VehicleSelectionViewModel();
      vm.select(_v(id: 1, weightKg: 1200));

      vm.reloadSelectedVehicle([_v(id: 1, weightKg: 1500)]);

      expect(vm.vehicle?.weightKg, 1500);
    });

    test('重量が変わっていない場合、notifyListeners は呼ばれない（同値）', () {
      final vm = VehicleSelectionViewModel();
      vm.select(_v(id: 1, weightKg: 1200));

      var notified = false;
      vm.addListener(() => notified = true);

      vm.reloadSelectedVehicle([_v(id: 1, weightKg: 1200)]);

      expect(notified, false);
    });

    test('リストに該当車両が無い場合（削除済み）、vehicle が null になる', () {
      final vm = VehicleSelectionViewModel();
      vm.select(_v(id: 1));

      vm.reloadSelectedVehicle([_v(id: 2)]);

      expect(vm.vehicle, isNull);
    });

    test('未選択の場合は何もしない', () {
      final vm = VehicleSelectionViewModel();

      var notified = false;
      vm.addListener(() => notified = true);
      vm.reloadSelectedVehicle([_v(id: 1)]);

      expect(notified, false);
      expect(vm.vehicle, isNull);
    });
  });
}
