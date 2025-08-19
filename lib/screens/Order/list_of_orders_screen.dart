import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../nav_bar_screen.dart';
import 'order_tracking_screen.dart';

class ListOrdersScreen extends StatefulWidget {
  const ListOrdersScreen({super.key});

  @override
  State<ListOrdersScreen> createState() => _ListOrdersScreenState();
}

class _ListOrdersScreenState extends State<ListOrdersScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allOrders = [];
  bool isLoading = true;
  late TabController _tabController;
  Map<String, String> orderStates = {};
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final phone = await _getUserPhone();
      if (phone == null) throw Exception('Телефон пользователя не найден');

      // Показываем кэш, если есть, чтобы ускорить отображение
      final cachedOrders = await _getCachedOrders();
      if (cachedOrders != null) {
        setState(() => allOrders = cachedOrders);
      }

      // Всегда загружаем свежие данные
      // final freshOrders = await moySkladService.loadOrders(phone);
      // setState(() => allOrders = freshOrders);
      // await _cacheOrders(freshOrders);

    } catch (e) {
      debugPrint('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
    allOrders.sort((a, b) {
      final dateA = DateTime.tryParse(a['moment'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['moment'] ?? '') ?? DateTime(2000);
      return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }

  Future<String?> _getUserPhone() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return null;

    try {
      final response = await supabase
          .from('user_profiles')
          .select('phone')
          .eq('id', userId)
          .single();

      return response['phone'] as String?;
    } catch (e) {
      print('Ошибка при получении телефона пользователя: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> _getCachedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedOrders');

    if (cachedData != null) {
      // Данные в кэше есть, парсим их
      final List<Map<String, dynamic>> cachedOrders = List<Map<String, dynamic>>.from(
        (await json.decode(cachedData)) as List,
      );
      return cachedOrders;
    }

    return null; // Кэш пуст
  }

  Future<void> _cacheOrders(List<Map<String, dynamic>> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(orders); // Преобразуем в строку
    prefs.setString('cachedOrders', encodedData);
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('подтвержден') ||
        lowerStatus.contains('новый') ||
        lowerStatus.contains('в обработке')) {
      return Colors.orange;
    } else if (lowerStatus.contains('получен') ||
        lowerStatus.contains('завершен') ||
        lowerStatus.contains('подтверждение') ||
        lowerStatus.contains('выполнен')) {
      return Colors.green;
    } else if (lowerStatus.contains('отменен') ||
        lowerStatus.contains('возврат') ||
        lowerStatus.contains('отказ')) {
      return Colors.red;
    } else if (lowerStatus.contains('в пути') ||
        lowerStatus.contains('отправлен')) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders =
    allOrders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      return !status.contains('завершен') &&
          !status.contains('получен') &&
          !status.contains('отменен') &&
          !status.contains('возврат');
    }).toList();

    final completedOrders =
    allOrders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      return status.contains('завершен') ||
          status.contains('получен') ||
          status.contains('отменен') ||
          status.contains('возврат');
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC02425), Color(0xfff0cb35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const BottomNavBar(initialIndex: 4)),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Мои заказы",
                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: "Активные",),
                      Tab(text: "Завершённые"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Сортировка: ", style: TextStyle(color: Colors.white)),
                        DropdownButton<bool>(
                          value: isAscending,
                          items: const [
                            DropdownMenuItem(value: false, child: Text("Сначала новые", style: TextStyle(fontSize: 14),)),
                            DropdownMenuItem(value: true, child: Text("Сначала старые", style: TextStyle(fontSize: 14))),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              isAscending = value;
                              allOrders.sort((a, b) {
                                final dateA = DateTime.tryParse(a['moment'] ?? '') ?? DateTime(2000);
                                final dateB = DateTime.tryParse(b['moment'] ?? '') ?? DateTime(2000);
                                return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildStyledOrderList(activeOrders),
                _buildStyledOrderList(completedOrders),
              ],
            ),
          ),
        ],
      ),
    );
  }


Widget _buildStyledOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "Нет заказов",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final status = order['status'] ?? 'Без статуса';
        final statusColor = _getStatusColor(status);
        final positions = order['positions']?['rows'] ?? [];
        
        return GestureDetector(
            onTap: () {
              // final orderData = mapToOrderData(order);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => OrderTrackingScreen(order: orderData),
              //   ),
              // );
            },
            child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Дата: ${_formatDate(order['moment'])}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Товары:", style: const TextStyle(fontWeight: FontWeight.bold)),
                ...positions.map<Widget>((position) {
                  final quantity = position['quantity'] ?? 0;
                  final price = (position['price'] ?? 0) / 100;
                  final href = position['assortment']?['meta']?['href'];

                  if (href == null) {
                    return const Text("- Неизвестный товар (нет ссылки)");
                  }

                  // return FutureBuilder<Map<String, dynamic>?>(
                  //   future: moySkladService.fetchProductDetails(href),
                  //   builder: (context, snapshot) {
                  //     final productName = snapshot.data?['name'] ?? 'Неизвестный товар';
                  //     return Padding(
                  //       padding: const EdgeInsets.symmetric(vertical: 2.0),
                  //       child: Text("- $productName × $quantity шт. по ${price.toStringAsFixed(2)} ₽"),
                  //     );
                  //   },
                  // );
                }).toList(),

                const SizedBox(height: 6),
                Text(
                  "Итого: ${_formatAmount(order['sum'])}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date == null) return '-';
      final dateStr = date.toString();
      if (dateStr.contains('T')) {
        return DateFormat('dd.MM.yyyy').format(DateTime.parse(dateStr));
      }
      return dateStr.length >= 10 ? dateStr.substring(0, 10) : '-';
    } catch (e) {
      return '-';
    }
  }

  String _formatAmount(dynamic amount) {
    try {
      if (amount == null) return '₽0.00';
      final value = (amount is int)
          ? amount
          : (int.tryParse(amount.toString()) ?? 0);
      return '${value.toStringAsFixed(2)} ₽';
    } catch (e) {
      return '₽0.00';
    }
  }
}
