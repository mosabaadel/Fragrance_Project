import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDarkMode;

    final Color pageBackground =
    dark ? const Color(0xFF211D24) : backgroundColor;

    final Color cardColor =
    dark ? const Color(0xFF302A34) : ivory;

    final Color mainText =
    dark ? Colors.white : espresso;

    final Color secondaryText =
    dark ? const Color(0xFFD0C7D1) : warmBrown;

    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        centerTitle: true,

        iconTheme: IconThemeData(
          color: mainText,
        ),

        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: mainText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'التفضيلات',
            style: TextStyle(
              color: mainText,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            cardColor: cardColor,
            mainText: mainText,
            secondaryText: secondaryText,
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات',
            subtitle: notificationsEnabled
                ? 'الإشعارات مفعلة'
                : 'الإشعارات متوقفة',
            trailing: Switch(
              value: notificationsEnabled,
              activeColor: champagne,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            cardColor: cardColor,
            mainText: mainText,
            secondaryText: secondaryText,
            icon: dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            title: 'المظهر',
            subtitle: dark
                ? 'المظهر الحالي: داكن'
                : 'المظهر الحالي: فاتح',
            trailing: Switch(
              value: dark,
              activeColor: champagne,
              onChanged: widget.onThemeChanged,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'الحساب والأمان',
            style: TextStyle(
              color: mainText,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            cardColor: cardColor,
            mainText: mainText,
            secondaryText: secondaryText,
            icon: Icons.lock_outline_rounded,
            title: 'تغيير كلمة المرور',
            subtitle: 'إرسال رابط لتغيير كلمة المرور',
            trailing: Icon(
              Icons.chevron_left_rounded,
              color: secondaryText,
            ),
            onTap: _changePassword,
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            cardColor: cardColor,
            mainText: mainText,
            secondaryText: secondaryText,
            icon: Icons.logout_rounded,
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من حسابك',
            trailing: Icon(
              Icons.chevron_left_rounded,
              color: secondaryText,
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required Color cardColor,
    required Color mainText,
    required Color secondaryText,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: softChampagne,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: softChampagne,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: espresso,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: mainText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يوجد بريد إلكتروني مرتبط بالحساب',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: user!.email!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(
              color: espresso,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: espresso,
                foregroundColor: Colors.white,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
  }
}
