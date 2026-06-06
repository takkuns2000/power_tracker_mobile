import 'package:flutter/material.dart';

class RecordsViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _records = [];

  List<Map<String, dynamic>> get records => List.unmodifiable(_records);
}
