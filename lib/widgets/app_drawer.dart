import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/product_catalog_screen.dart';
import '../utils/theme_config.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: Drawer(
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.95),
                Color.lerp(
                  Theme.of(context).primaryColor,
                  Colors.black,
                  0.2,
                )!.withOpacity(0.95),
              ],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Header
                  _buildAnimatedHeader(),

                  // Navigation Menu
                  Expanded(
                    child: ClipRRect(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          const SizedBox(height: 8),

                          _buildNavItem(
                            index: 0,
                            title: 'Dashboard',
                            icon: Icons.dashboard_outlined,
                            activeIcon: Icons.dashboard,
                            onTap: () {
                              _handleNavigation(0, const HomeScreen());
                            },
                          ),

                          _buildNavItem(
                            index: 1,
                            title: 'Current Bill',
                            icon: Icons.shopping_cart_outlined,
                            activeIcon: Icons.shopping_cart,

                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, animation, __) => FadeTransition(
                                        opacity: animation,
                                        child: const CartScreen(),
                                      ),
                                ),
                              );
                            },
                          ),

                          _buildNavItem(
                            index: 2,
                            title: 'Transaction History',
                            icon: Icons.receipt_outlined,
                            activeIcon: Icons.receipt,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, animation, __) => FadeTransition(
                                        opacity: animation,
                                        child: const TransactionHistoryScreen(),
                                      ),
                                ),
                              );
                            },
                          ),

                          _buildNavItem(
                            index: 3,
                            title: 'Product Catalog',
                            icon: Icons.inventory_2_outlined,
                            activeIcon: Icons.inventory_2,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, animation, __) => FadeTransition(
                                        opacity: animation,
                                        child: const ProductCatalogScreen(),
                                      ),
                                ),
                              );
                            },
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0,
                            ),
                            child: Divider(height: 1, color: Colors.white38),
                          ),

                          _buildNavItem(
                            index: 4,
                            title: 'Settings',
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings,
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Settings will be available in future versions',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // User Profile Section
                  _buildUserProfileSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Row(
            children: [
              // App Logo with animated scales
              Transform.scale(
                scale: 0.8 + (0.2 * _animationController.value),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.point_of_sale,
                    color: Theme.of(context).primaryColor,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // App Title with animated opacity
              Opacity(
                opacity: _animationController.value,
                child: Transform.translate(
                  offset: Offset(-20 * (1 - _animationController.value), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TATA Retail',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'GST Billing System',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    required VoidCallback onTap,
    String? badge,
  }) {
    final isSelected = index == _selectedIndex;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.fromLTRB(
            16 + (8 * _animationController.value),
            4,
            16,
            4,
          ),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () {
              setState(() => _selectedIndex = index);
              onTap();
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(isSelected ? 1 : 0.8),
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (isSelected)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              radius: 22,
            ),
          ),
          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Store Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cashier Panel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout will be available in future versions',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index, Widget screen) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);

    // Only push new screen if we're not already on the home screen
    if (index != 0 || ModalRoute.of(context)?.settings.name != '/') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (_, animation, __) =>
                  FadeTransition(opacity: animation, child: screen),
        ),
      );
    }
  }
}
