import 'package:flutter/material.dart';
import '../../widgets/constants.dart';
import '../../controller/signup_controller.dart';
import '../../logo_shop.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  late SignUpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignUpController(
      phoneController: _phoneController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      isLoading: _isLoading,
      nameController: _nameController,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final errorMessage = await _controller.signUp();
    if (errorMessage != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ошибка регистрации'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ок'),
            ),
          ],
        ),
      );
    }
  }

  Widget buildInput(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        keyboardType: label.toLowerCase().contains('телефон') ? TextInputType.phone : TextInputType.text,
      ),
    );
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
                    const Text('Регистрация', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    buildInput('Телефон', _phoneController),
                    buildInput('Имя пользователя', _nameController),
                    buildInput('Пароль', _passwordController, obscure: true),
                    buildInput('Повторите пароль', _confirmPasswordController, obscure: true),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isLoading,
                      builder: (context, isLoading, _) {
                        return isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _handleSignUp,
                          style: buttonStyle(),
                          child: const Text('Зарегистрироваться'),
                        );
                      },
                    ),
                    const Spacer(),
                    const Text("Уже есть аккаунт?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Войти'),
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
