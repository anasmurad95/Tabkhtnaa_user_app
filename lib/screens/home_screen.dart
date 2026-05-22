import 'package:flutter/material.dart';
import 'package:user_app/common/app_colors.dart';
import 'package:user_app/screens/menu_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const MenuPage(),
    const MapPage(),
    const NotificationsPage(),
    const ChatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تابختنا'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.label,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'القائمة',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'الخريطة'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'الدردشة',
          ),
        ],
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مرحباً بك في القائمة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر فئة أو اطلب من القائمة الأكثر مبيعاً.',
            style: TextStyle(color: AppColors.label),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CategoryCard(label: 'سندويشات', icon: Icons.fastfood),
                CategoryCard(label: 'مشروبات', icon: Icons.local_drink),
                CategoryCard(label: 'حلويات', icon: Icons.icecream),
                CategoryCard(label: 'عروض', icon: Icons.local_offer),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                FoodItemCard(
                  title: 'وجبة مميزة',
                  subtitle: 'دجاج مشوي مع سلطة',
                  price: '12 دينار',
                  onTap: () {
                    Navigator.pushNamed(context, MenuDetailsScreen.routeName);
                  },
                ),
                FoodItemCard(
                  title: 'كبسة لحم',
                  subtitle: 'طبق كامل مع صلصة خاصة',
                  price: '15 دينار',
                  onTap: () {
                    Navigator.pushNamed(context, MenuDetailsScreen.routeName);
                  },
                ),
                FoodItemCard(
                  title: 'عصير طبيعي',
                  subtitle: 'خيار فريش مع نعناع',
                  price: '4 دينار',
                  onTap: () {
                    Navigator.pushNamed(context, MenuDetailsScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'المواقع القريبة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'اختَر أقرب طباخ أو طلبك من الخريطة.',
            style: TextStyle(color: AppColors.label),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 120,
                        color: AppColors.primary.withOpacity(0.45),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text(
                          'الخريطة قيد التجهيز حالياً',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'سيظهر هنا موقع أطباقك القريبة وتفاصيل التوصيل.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.label),
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
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'الإشعارات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          NotificationTile(
            title: 'طلبك قيد التحضير',
            subtitle: 'سيكون جاهزاً خلال 20 دقيقة.',
          ),
          NotificationTile(
            title: 'عرض خاص اليوم',
            subtitle: 'احصل على خصم 15% على الوجبات السريعة.',
          ),
          NotificationTile(
            title: 'تم توصيل الطلب',
            subtitle: 'استمتع بطعامك اللذيذ وتمتع بيومك.',
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الدردشة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: const [
                ChatTile(
                  name: 'فريق الدعم',
                  message: 'تم تأكيد طلبك وسيتم التوصيل قريباً.',
                ),
                ChatTile(
                  name: 'المندوب',
                  message: 'سأكون عند الباب بعد 10 دقائق.',
                ),
                ChatTile(
                  name: 'مطعم المميز',
                  message: 'شكراً لاستخدامك طابختنا!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const CategoryCard({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const Spacer(),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  const FoodItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.label),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const NotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accent,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;

  const ChatTile({super.key, required this.name, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.chat_bubble, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
