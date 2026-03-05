import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final isAdmin = AuthService.instance.isAdmin;
    final roleName = isAdmin ? 'Admin' : 'Student';
    final avatarId = isAdmin ? '12' : '33';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/300?img=$avatarId'),
            ),
            const SizedBox(height: 24),
            Text(
              user?.name ?? 'User',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isAdmin
                    ? Colors.indigo.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAdmin
                        ? Icons.admin_panel_settings
                        : Icons.school,
                    size: 16,
                    color: isAdmin ? Colors.indigo : Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$roleName User',
                    style: TextStyle(
                      color: isAdmin ? Colors.indigo : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: Icons.email_outlined,
              title: 'Email',
              value: user?.email ?? 'user@college.edu',
            ),
            const _ProfileTile(
              icon: Icons.school_outlined,
              title: 'Department',
              value: 'Computer Science',
            ),
            const _ProfileTile(
              icon: Icons.phone_android_outlined,
              title: 'Phone',
              value: '+1 234 567 8900',
            ),
            const SizedBox(height: 48),
            ListTile(
              onTap: () async {
                if (isFirebaseInitialized) {
                  await FirebaseAuth.instance.signOut();
                }
                AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: Colors.red.withOpacity(0.05),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
