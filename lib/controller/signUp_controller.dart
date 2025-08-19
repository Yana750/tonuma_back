import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpController {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> isLoading;

  final AuthService _authService = AuthService();

  SignUpController({
    required this.phoneController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
  });

  Future<String?> signUp() async {
    final phone = phoneController.text.trim();
    final username = nameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (phone.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'Пожалуйста, заполните все поля.';
    }

    if (password != confirmPassword) {
      return 'Пароли не совпадают.';
    }

    isLoading.value = true;

    try {
      final error = await _authService.register(username, phone, password, confirmPassword);
      return error; // null если успех, строка если ошибка
    } catch (e) {
      return 'Произошла ошибка: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
