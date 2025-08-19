import 'package:flutter/material.dart';
import 'package:tonuma_back/screens/auth/login_screen.dart';

import '../../services/auth_service.dart';
import '../../widgets/constants.dart';
import '../Order/list_of_orders_screen.dart';
import 'address_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  String? userName;
  String? userPhone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final userData = await _authService.getCurrentUserData();
    // Предполагаю, что userData — Map или объект с нужными полями
    setState(() {
      userName = userData?['username'] ?? 'Имя не установлено';
      userPhone = userData?['phone'] ?? 'Телефон не установлен';
      isLoading = false;
    });
  }

  void logout(BuildContext context) async {
    await _authService.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, right: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: [...items]),
        ),
      ],
    );
  }

  Widget _buildMenuItems({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color:
                isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : kprimaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: grimaryColor,
                  end: Alignment.bottomCenter,
                  begin: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 48,
                    right: 16,
                    child: Text(
                      "Профиль",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery
                      .of(context)
                      .size
                      .height * 0.1,
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 1.5,
                      margin: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.person_outline,
                                  size: 60,
                                  color: Colors.orangeAccent,
                                ),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text('$userName', style: const TextStyle(
                              fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('$userPhone', style: const TextStyle(
                              fontSize: 14)),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildSection(
                            title: "Настройки аккаунта",
                            items: [
                              _buildMenuItems(
                                icon: Icons.lock_outlined,
                                title: 'Изменение пароля',
                                subtitle: 'Обновить пароль',
                                onTap: () {},
                                color: Colors.orange,
                              ),
                              _buildMenuItems(
                                icon: Icons.notifications,
                                title: 'Уведомления',
                                subtitle: 'Управление уведомлениями',
                                onTap: () {},
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          _buildSection(
                            title: "Предпочтения в покупках",
                            items: [
                              _buildMenuItems(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Мои заказы',
                                subtitle: 'Просмотр истории заказов',
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ListOfOrdersScreen(),
                                  //   ),
                                  // );
                                },
                                color: Colors.lime,
                              ),
                              _buildMenuItems(
                                icon: Icons.location_on_outlined,
                                title: 'Адрес доставки',
                                subtitle: 'Обновить адрес доставки',
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => AddressScreen()));
                                },
                                color: Colors.lime,
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          _buildSection(
                            title: "Другие",
                            items: [
                              _buildMenuItems(
                                icon: Icons.settings_outlined,
                                title: 'Настройки',
                                subtitle: 'Настройки приложения',
                                onTap: () {},
                                color: Colors.purple,
                              ),
                              _buildMenuItems(
                                icon: Icons.help_outline,
                                title: 'Помощь и поддержка',
                                subtitle: 'Получить помощь и связаться с нами',
                                onTap: () {},
                                color: Colors.purple,
                              ),
                              _buildMenuItems(
                                icon: Icons.logout_outlined,
                                title: 'Выход',
                                subtitle: 'Выйти из аккаунта',
                                onTap: () => logout(context),
                                color: Colors.red,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
