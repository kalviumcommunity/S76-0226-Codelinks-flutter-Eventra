import 'package:flutter/material.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import '../../core/models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  void _signup() {
    // TODO: Replace signup logic with FirebaseAuth
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join Eventra',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start managing or discovering events today.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Full Name',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Your Role',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    title: 'Student',
                    icon: Icons.school_outlined,
                    isSelected: _selectedRole == UserRole.student,
                    onTap: () =>
                        setState(() => _selectedRole = UserRole.student),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleCard(
                    title: 'Admin',
                    icon: Icons.admin_panel_settings_outlined,
                    isSelected: _selectedRole == UserRole.admin,
                    onTap: () => setState(() => _selectedRole = UserRole.admin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            CustomButton(text: 'Sign Up', onPressed: _signup),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
