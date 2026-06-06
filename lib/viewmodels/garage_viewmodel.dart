import 'package:flutter/material.dart';

class GarageViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _vehicles = [];

  List<Map<String, dynamic>> get vehicles => List.unmodifiable(_vehicles);
}
