import 'dart:math';

class OrderData {
  final String id;
  final String currentStatus;
  final String address;
  final DateTime createdAt;
  final Map<String, DateTime?> statusDates;

  OrderData({
    required this.id,
    required this.currentStatus,
    required this.address,
    required this.createdAt,
    required this.statusDates,
  });
}

class DeliveryStep {
  final String status;
  final String date;
  final bool isCompleted;

  DeliveryStep({
    required this.status,
    required this.date,
    required this.isCompleted,
  });
}

extension StringCasing on String {
  String capitalize() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}

OrderData mapToOrderData(Map<String, dynamic> map) {
  final createdAt = DateTime.tryParse(map['moment'] ?? '') ?? DateTime.now();
  final status = (map['status'] ?? 'ожидание').toLowerCase();
  final id = map['id'] ?? '';
  final address = map['shipmentAddress'] ?? '';

  final List<String> statusOrder = [
    "ожидание",
    "в обработке",
    "собран",
    "отправлен",
    "подтверждение",
    "получен",
  ];

  final currentStatusIndex = statusOrder.indexOf(status);
  final estimatedDelivery = createdAt.add(Duration(days: 5 + Random().nextInt(3)));
  final int totalSteps = currentStatusIndex + 1;

  final Map<String, DateTime?> statusDates = {};
  DateTime lastDate = createdAt;

  for (int i = 0; i < statusOrder.length; i++) {
    final step = statusOrder[i];
    if (i <= currentStatusIndex) {
      final remainingSteps = totalSteps - i;
      final maxDays = estimatedDelivery.difference(lastDate).inDays ~/ remainingSteps;
      final increment = maxDays > 0 ? Random().nextInt(maxDays + 1) : 0;
      final newDate = lastDate.add(Duration(days: increment));
      statusDates[step] = newDate;
      lastDate = newDate;
    } else {
      statusDates[step] = null;
    }
  }

  return OrderData(
    id: id,
    currentStatus: status,
    address: address,
    createdAt: createdAt,
    statusDates: statusDates,
  );
}