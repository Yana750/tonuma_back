import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/constants.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? currentEmail;
  bool isLoading = true;

  String? validatePhone(String value) {
    final regex = RegExp(r'^\+7[0-9]{10}$');
    if (!regex.hasMatch(value)) {
      return 'Введите номер в формате +79999999999';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final userId = user.id;
      currentEmail = user.email;

      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(); // <— ключевой момент

      if (response != null) {
        setState(() {
          _nameController.text = response['name'] ?? '';
          _phoneController.text = response['phone'] ?? '';
          _addressController.text = response['address'] ?? '';
          isLoading = false;
        });
      } else {
        // Если запись отсутствует — создаём новую
        await Supabase.instance.client.from('user_profiles').insert({
          'id': userId,
          'name': '',
          'phone': '',
          'address': '',
        });
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final updates = {
      'id': user.id,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
    };

    final response = await Supabase.instance.client
        .from('user_profiles')
        .upsert(updates)
        .eq('id', user.id);

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Изменения успешно сохранены!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Личные данные")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Электронная почта",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                currentEmail ?? 'Не авторизован',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              buildInput("Фамилия / Имя", _nameController),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  hintText: '+79999999999',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Телефон обязателен';
                  }
                  return validatePhone(value);
                },
              ),
              const SizedBox(height: 10),
              buildInput("Адрес", _addressController),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Сохранить изменения"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}