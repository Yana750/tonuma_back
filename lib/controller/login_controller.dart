import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginController {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueNotifier<bool> isLoading;

  final AuthService _authService = AuthService();

  LoginController({
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
  });

  Future<String?> login() async {
    final username = emailController.text.trim(); // переименуй, если надо
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      return 'Пожалуйста, заполните все поля.';
    }

    isLoading.value = true;

    try {
      final error = await _authService.login(username, password); // передаём username
      if (error != null) {
        return error;
      }
      return null; // Успех
    } catch (e) {
      return 'Произошла ошибка: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
