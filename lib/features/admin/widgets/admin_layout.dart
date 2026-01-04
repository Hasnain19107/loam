import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../user/auth/controller/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String? title;

  const AdminLayout({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentRoute = Get.currentRoute;

    final navItems = [
      _NavItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        route: AppRoutes.adminDashboard,
      ),
      _NavItem(icon: Icons.people, label: 'Users', route: AppRoutes.adminUsers),
      _NavItem(
        icon: Icons.calendar_today,
        label: 'Events',
        route: AppRoutes.adminEvents,
      ),
      _NavItem(
        icon: Icons.list_alt,
        label: 'Event Requests',
        route: AppRoutes.adminRequests,
      ),
      _NavItem(
        icon: Icons.help_outline,
        label: 'Quiz Builder',
        route: AppRoutes.adminQuizBuilder,
      ),
      _NavItem(
        icon: Icons.message,
        label: 'Quiz Responses',
        route: AppRoutes.adminQuizResponses,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: AppColors.foreground,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          title ?? 'Loam Admin',
          style: TextStyle(
            color: AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppColors.foreground,
            tooltip: 'Sign out',
            onPressed: () async {
              await authController.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.card,
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Loam Admin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: navItems.map((item) {
                    final isActive = currentRoute == item.route;
                    return _NavButton(
                      item: item,
                      isActive: isActive,
                      onTap: () {
                        Navigator.of(context).pop(); // Close drawer
                        Get.toNamed(item.route);
                      },
                    );
                  }).toList(),
                ),
              ),
              // Sign out button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close drawer
                      await authController.signOut();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('Sign out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.foreground,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({required this.icon, required this.label, required this.route});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          item.icon,
          size: 24,
          color: isActive ? AppColors.primary : AppColors.mutedForeground,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.foreground,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
