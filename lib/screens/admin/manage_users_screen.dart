import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final me = context.watch<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: admin.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: admin.users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final u = admin.users[i];
                final canModerate = admin.canBan(me, u);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(u.avatarColorValue),
                        child: Text(u.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                                if (u.role == UserRole.admin) ...[
                                  const SizedBox(width: 6),
                                  const PillLabel(text: 'Admin', background: AppColors.brown500, foreground: Colors.white),
                                ],
                                if (u.isBanned) ...[
                                  const SizedBox(width: 6),
                                  const PillLabel(text: 'Suspended', background: AppColors.red, foreground: Colors.white),
                                ],
                              ],
                            ),
                            Text(u.email, style: const TextStyle(fontSize: 12.5, color: AppColors.grayText)),
                          ],
                        ),
                      ),
                      if (canModerate)
                        PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'ban') {
                              await admin.setBanned(u, true);
                            } else if (action == 'unban') {
                              await admin.setBanned(u, false);
                            } else if (action == 'promote') {
                              await admin.setRole(u, UserRole.admin);
                            } else if (action == 'demote') {
                              await admin.setRole(u, UserRole.reader);
                            }
                            if (context.mounted) showSnack(context, 'Updated ${u.name}.');
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: u.isBanned ? 'unban' : 'ban', child: Text(u.isBanned ? 'Unsuspend' : 'Suspend')),
                            PopupMenuItem(
                              value: u.role == UserRole.admin ? 'demote' : 'promote',
                              child: Text(u.role == UserRole.admin ? 'Remove admin' : 'Make admin'),
                            ),
                          ],
                        )
                      else
                        const SizedBox(width: 24),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
