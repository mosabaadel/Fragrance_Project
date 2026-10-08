import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لم يتم تسجيل الدخول'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            color: espresso,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: espresso,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: champagne,
              ),
            );
          }

          final data =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};

          final String name =
          data['displayName']?.toString().trim().isNotEmpty == true
              ? data['displayName'].toString()
              : user.displayName ?? 'مستخدم Fragrance Identity';

          final String email = user.email ?? 'لا يوجد بريد إلكتروني';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // صورة الحساب
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: softChampagne,
                    border: Border.all(
                      color: champagne,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 55,
                    color: espresso,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: espresso,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: warmBrown,
                  ),
                ),

                const SizedBox(height: 30),

                // بيانات الحساب
                _buildInfoCard(
                  icon: Icons.person_outline_rounded,
                  title: 'الاسم',
                  value: name,
                ),

                const SizedBox(height: 12),

                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: 'البريد الإلكتروني',
                  value: email,
                ),

                const SizedBox(height: 12),

                _buildInfoCard(
                  icon: Icons.fingerprint_rounded,
                  title: 'معرّف الحساب',
                  value: user.uid,
                  smallText: true,
                ),

                const SizedBox(height: 30),

                // زر تعديل البيانات
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showEditNameDialog(
                        context,
                        user,
                        name,
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text(
                      'تعديل الاسم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: espresso,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool smallText = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: warmBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: smallText ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: smallText ? 12 : 15,
                    fontWeight: FontWeight.w600,
                    color: espresso,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context,
      User user,
      String currentName,
      ) {
    final controller = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تعديل الاسم',
            style: TextStyle(
              color: espresso,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'الاسم',
              filled: true,
              fillColor: backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: warmBrown,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();

                if (newName.isEmpty) return;

                try {
                  await user.updateDisplayName(newName);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set(
                    {
                      'displayName': newName,
                    },
                    SetOptions(merge: true),
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم تحديث الاسم بنجاح',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'حدث خطأ أثناء التحديث: $e',
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: espresso,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}