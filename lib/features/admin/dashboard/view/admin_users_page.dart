import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_profile_model.dart';
import '../controller/admin_users_controller.dart';
import '../../widgets/admin_layout.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminUsersController());

    return AdminLayout(
      title: 'Users',
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      '${controller.users.length} total users',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      onChanged: controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or phone...',
                        hintStyle: TextStyle(color: AppColors.mutedForeground),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.mutedForeground,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Users list
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = controller.filteredUsers;

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return _UserCard(user: user, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfileModel user;
  final AdminUsersController controller;

  const _UserCard({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.secondary,
            backgroundImage: user.photo != null
                ? NetworkImage(user.photo!)
                : null,
            child: user.photo == null
                ? Text(
                    user.firstName?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.firstName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '—',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (user.phone != null) ...[
                      Text(
                        user.phone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (user.gender != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.gender!.toLowerCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.isShadowBlocked
                  ? AppColors.destructive.withOpacity(0.1)
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user.isShadowBlocked ? 'Blocked' : 'Active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: user.isShadowBlocked
                    ? AppColors.destructive
                    : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('View profile'),
                  ],
                ),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () => _showUserDialog(context, user),
                  );
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      user.isShadowBlocked ? Icons.undo : Icons.block,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(user.isShadowBlocked ? 'Unblock' : 'Shadow block'),
                  ],
                ),
                onTap: () {
                  controller.toggleShadowBlock(user.id, user.isShadowBlocked);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, UserProfileModel user) {
    final notesController = TextEditingController(text: user.adminNotes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.secondary,
                      backgroundImage: user.photo != null
                          ? NetworkImage(user.photo!)
                          : null,
                      child: user.photo == null
                          ? Text(
                              user.firstName?.substring(0, 1).toUpperCase() ??
                                  '?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.firstName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email ?? '—',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          if (user.isShadowBlocked)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.destructive.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Shadow Blocked',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.destructive,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoRow(label: 'Phone', value: user.phone ?? '—'),
                _InfoRow(
                  label: 'Gender',
                  value: user.gender?.toLowerCase() ?? '—',
                ),
                _InfoRow(
                  label: 'Relationship',
                  value: user.relationshipStatus?.toLowerCase() ?? '—',
                ),
                _InfoRow(
                  label: 'Joined',
                  value: DateFormat('MMM d, yyyy').format(user.createdAt),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Notes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Internal notes about this user...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.updateAdminNotes(
                        user.id,
                        notesController.text,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                    ),
                    child: const Text('Save Notes'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.toggleShadowBlock(
                        user.id,
                        user.isShadowBlocked,
                      );
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isShadowBlocked
                          ? AppColors.primary
                          : AppColors.destructive,
                    ),
                    child: Text(
                      user.isShadowBlocked
                          ? 'Unblock User'
                          : 'Shadow Block User',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
