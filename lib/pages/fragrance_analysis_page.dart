import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);
const Color secondaryText = Color(0xFF817781);
const Color softBrown = Color(0xFFF1E9F0);

class FragranceAnalysisPage extends StatelessWidget {
  const FragranceAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('يرجى تسجيل الدخول أولاً'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme:
        const IconThemeData(color: espresso),
        title: const Text(
          'تحليلي العطري',
          style: TextStyle(
            color: espresso,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: warmBrown,
              ),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'لم يتم العثور على بيانات الهوية العطرية.',
                style: TextStyle(
                  color: secondaryText,
                ),
              ),
            );
          }

          final data =
          snapshot.data!.data()
          as Map<String, dynamic>;

          final family =
              data['fragranceFamily']?.toString() ??
                  'غير محدد';

          final strength =
              data['fragranceStrength']?.toString() ??
                  'غير محدد';

          final usage =
              data['fragranceUsage']?.toString() ??
                  'غير محدد';

          final season =
              data['season']?.toString() ??
                  'غير محدد';

          final preferredNotes =
          _toList(data['preferredNotes']);

          final dislikedNotes =
          _toList(data['dislikedNotes']);

          final personality =
          _toList(data['personality']);

          final mood =
          _toList(data['mood']);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),

                const SizedBox(height: 20),

                _buildMainCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'عائلتك العطرية',
                  value: family,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.water_drop_outlined,
                        'القوة',
                        strength,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.access_time_rounded,
                        'الاستخدام',
                        usage,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildInfoCard(
                  Icons.calendar_month_outlined,
                  'الموسم',
                  season,
                ),

                const SizedBox(height: 20),

                _buildListSection(
                  title: 'النوتات المفضلة',
                  icon: Icons.favorite_border_rounded,
                  items: preferredNotes,
                ),

                const SizedBox(height: 12),

                _buildListSection(
                  title: 'النوتات غير المفضلة',
                  icon: Icons.remove_circle_outline_rounded,
                  items: dislikedNotes,
                ),

                const SizedBox(height: 20),

                _buildListSection(
                  title: 'ملامح الشخصية',
                  icon: Icons.person_outline_rounded,
                  items: personality,
                ),

                const SizedBox(height: 12),

                _buildListSection(
                  title: 'المزاج',
                  icon: Icons.mood_outlined,
                  items: mood,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static List<String> _toList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            espresso,
            Color(0xFF66516D),
            warmBrown,
          ],
        ),
        borderRadius:
        BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: champagne,
            size: 30,
          ),
          SizedBox(height: 12),
          Text(
            'ملامح هويتك العطرية',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'هذه النتائج مبنية على إجاباتك وتحليل تفضيلاتك.',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: softBrown,
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: warmBrown,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: espresso,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Icon(
            icon,
            color: warmBrown,
            size: 22,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: espresso,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                icon,
                color: warmBrown,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: espresso,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (items.isEmpty)
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'لا توجد بيانات',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 11,
                ),
              ),
            )
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              alignment: WrapAlignment.end,
              children: items.map((item) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: softBrown,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: warmBrown,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}