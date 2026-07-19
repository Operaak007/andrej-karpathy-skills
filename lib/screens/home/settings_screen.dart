import 'package:ak_api_test/bloc/auth/auth_bloc.dart';
import 'package:ak_api_test/bloc/auth/auth_event.dart';
import 'package:ak_api_test/screens/auth/login_screen.dart';
import 'package:ak_api_test/screens/home/set_new_pin_screen.dart';
import 'package:ak_api_test/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _pageBg = Color(0xFF101010);
  static const _headerBg = Color(0xFF1D1D1F);
  static const _cardBg = Color(0xFF1C1C1E);
  static const _divider = Color(0xFF2A2A2C);
  static const _mutedText = Color(0xFFA4A7AE);
  static const _danger = Color(0xFFFF4D57);

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        toolbarHeight: 110,
        titleSpacing: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 34),
          onPressed: () => Navigator.maybePop(context),
        ),
        backgroundColor: _headerBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(
          children: [
            _buildSection(
              title: 'Account',
              rows: [
                _SettingRow(
                  icon: Icons.person_outline,
                  label: 'Account Management',
                  onTap: () {
                    // TODO: Implement account management
                  },
                ),
                _SettingRow(
                  icon: Icons.security,
                  label: 'Security',
                  onTap: () {
                    // TODO: Implement security settings
                  },
                ),
                _SettingRow(
                  icon: Icons.lock,
                  label: 'Set New PIN',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SetNewPinScreen(),
                      ),
                    );
                  },
                ),
                _SettingRow(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  onTap: () {
                    // TODO: Implement notification settings
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: 'Support',
              rows: [
                _SettingRow(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {
                    // TODO: Implement help & support
                  },
                ),
                _SettingRow(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () {
                    // TODO: Implement terms & conditions
                  },
                ),
                _SettingRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {
                    // TODO: Implement privacy policy
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildLogoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingRow> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _buildSettingRow(rows[i]),
                if (i != rows.length - 1)
                  const Divider(height: 1, color: _divider),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(_SettingRow row) {
    return InkWell(
      onTap: row.onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            Icon(row.icon, color: _mutedText, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                row.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _mutedText, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout, color: _danger, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Logout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _danger,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: _mutedText, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingRow {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
