import 'package:flutter/material.dart';
import 'package:tonuma_back/screens/auth/register_screen.dart';

import '../../../widgets/constants.dart';
import '../../../controller/login_controller.dart';
import '../../../logo_shop.dart';
import '../nav_bar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
      emailController: _phoneController,
      passwordController: _passwordController,
      isLoading: _isLoading,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final errorMessage = await _controller.login();
    if (errorMessage != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ок'),
            ),
          ],
        ),
      );
    } else {
      // Если вход успешный — переходим на BottomNavBar и убираем Login из стека
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavBar()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Center(child: TonumaLogo()),
                    const SizedBox(height: 20),
                    const Text('Авторизация', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    buildInput('Телефон', _phoneController),
                    buildInput('Пароль', _passwordController, obscure: true),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isLoading,
                      builder: (context, isLoading, _) {
                        return isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _handleLogin,
                          style: buttonStyle(),
                          child: const Text('Войти'),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    const Text("Нет аккаунта?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text('Зарегистрироваться'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
