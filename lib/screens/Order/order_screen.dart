import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tonuma_back/screens/Order/payment_screen.dart';

import '../../models/address_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../widgets/constants.dart';
import '../Provider/cart_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = false;

  final _authService = AuthService();
  late final OrderService _orderService;

  Address? _selectedAddress;
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();

    // Инициализируем OrderService с базовым URL из AuthService
    _orderService = OrderService(baseUrl: 'http://192.168.0.20:8000/');
    // Загружаем данные пользователя
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      _userName = user?['name'] ?? '';
      _userPhone = user?['phone'] ?? '';
    });
  }

  void _onAddressSelected(Address address) {
    setState(() {
      _selectedAddress = address;
    });
  }

  Future<void> _submitOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите адрес доставки')),
      );
      return;
    }

    if (_userName == null || _userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка получения данных пользователя')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final total = cartProvider.totalPrice();

      final cartProducts = cartProvider.cart; // Список Product

      final success = await _orderService.sendOrder(
        cartProducts: cartProducts,
        totalPrice: total,
        name: _userName!,
        phone: _userPhone!,
        address: _selectedAddress!.address,
        comment: _commentController.text,
      );

      if (success) {
        cartProvider.clearCart();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при оформлении заказа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final total = cartProvider.totalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оформление заказа', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 6),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AddressFieldSection(onAddressSelected: _onAddressSelected),
              _PaymentMethodSection(),
              _CommentSection(controller: _commentController),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Оплатить $total ₽",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

// Виджет выбора адреса с callback
class _AddressFieldSection extends StatefulWidget {
  final Function(Address) onAddressSelected;

  const _AddressFieldSection({Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  State<_AddressFieldSection> createState() => _AddressFieldSectionState();
}

class _AddressFieldSectionState extends State<_AddressFieldSection> {
  final _authService = AuthService();

  List<Address> _addresses = [];
  bool _isLoading = true;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final data = await _authService.getAddresses();
    if (data != null && data.isNotEmpty) {
      setState(() {
        _addresses = data;
        _selectedAddress = data.firstWhere((a) => a.isDefault, orElse: () => data.first);
        _isLoading = false;
      });
      widget.onAddressSelected(_selectedAddress!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onAddressTap(Address address) {
    setState(() {
      _selectedAddress = address;
    });
    widget.onAddressSelected(address);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Адрес доставки", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ..._addresses.map((address) {
              final isSelected = _selectedAddress == address;
              return ListTile(
                title: Text(address.address),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                selected: isSelected,
                onTap: () => _onAddressTap(address),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Отдельный виджет способа оплаты (оставил без изменений, тк он у тебя уже есть)
class _PaymentMethodSection extends StatefulWidget {
  @override
  State<_PaymentMethodSection> createState() => _PaymentMethodSectionState();
}

class _PaymentMethodSectionState extends State<_PaymentMethodSection> {
  String _paymentType = 'Сразу';
  String _paymentMethod = 'Банковская карта';
  String _selectedBank = 'Сбербанк';

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //... оставляем как есть из твоего кода
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Способ оплаты",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            // Кнопки и остальные элементы как у тебя
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _paymentType = 'Сразу'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _paymentType == 'Сразу'
                          ? Colors.orange
                          : Colors.grey.shade400,
                      width: _paymentType == 'Сразу' ? 2 : 1,
                    ),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    'Сразу',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() => _paymentType = 'При получении'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _paymentType == 'При получении'
                          ? Colors.orange
                          : Colors.grey.shade400,
                      width: _paymentType == 'При получении' ? 2 : 1,
                    ),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    'При получении',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_paymentType == 'Сразу') ...[
              RadioOption<String>(
                title: 'Банковская карта',
                value: 'Банковская карта',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),
              RadioOption<String>(
                title: 'СБП',
                value: 'СБП',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),
              const SizedBox(height: 10),

              if (_paymentMethod == 'Банковская карта') ...[
                buildStyledInput('Номер карты', _cardNumberController),
                Row(
                  children: [
                    Expanded(child: buildStyledInput('MM/ГГ', _expiryController)),
                    const SizedBox(width: 12),
                    Expanded(child: buildStyledInput('CVV', _cvvController)),
                  ],
                ),
              ],

              if (_paymentMethod == 'СБП') ...[
                DropdownButton<String>(
                  value: _selectedBank,
                  onChanged: (value) => setState(() => _selectedBank = value!),
                  items: const [
                    DropdownMenuItem(value: 'Сбербанк', child: Text('Сбербанк')),
                    DropdownMenuItem(value: 'Тинькофф', child: Text('Тинькофф')),
                    DropdownMenuItem(value: 'ВТБ', child: Text('ВТБ')),
                    DropdownMenuItem(value: 'Альфа-Банк', child: Text('Альфа-Банк')),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStyledInput(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// Комментарий
class _CommentSection extends StatelessWidget {
  final TextEditingController controller;

  const _CommentSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Комментарий к заказу',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
