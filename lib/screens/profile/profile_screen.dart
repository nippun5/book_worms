import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import '../admin/admin_home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final nameCtrl = TextEditingController(text: auth.user?.name);
    final bioCtrl = TextEditingController(text: auth.user?.bio);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: bioCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved == true) {
      await auth.updateProfile(name: nameCtrl.text, bio: bioCtrl.text);
      if (context.mounted) showSnack(context, 'Profile updated.');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Log out?',
      message: 'You can log back in any time with the same email and password.',
      confirmLabel: 'Log out',
      destructive: true,
    );
    if (ok) await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Color(user.avatarColorValue),
                  child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 14),
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.brown900)),
                Text(user.email, style: const TextStyle(color: AppColors.grayText, fontSize: 13.5)),
                if (user.role.name == 'admin') ...[
                  const SizedBox(height: 8),
                  const PillLabel(text: 'Admin', background: AppColors.brown500, foreground: Colors.white),
                ],
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(user.bio, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.brown700, height: 1.4)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          _ProfileTile(icon: Icons.edit_outlined, label: 'Edit profile', onTap: () => _editProfile(context)),
          if (auth.isAdmin)
            _ProfileTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin panel',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen())),
            ),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'Log out',
            destructive: true,
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Book Worms · v1.0.0', style: TextStyle(color: AppColors.grayText, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.red : AppColors.brown900;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: destructive ? AppColors.red : AppColors.brown500),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grayText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
