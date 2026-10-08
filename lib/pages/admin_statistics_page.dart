import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);
const Color secondaryText = Color(0xFF817781);
const Color softBrown = Color(0xFFF1E9F0);

class AdminStatisticsPage extends StatelessWidget {
  const AdminStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: espresso),
        title: const Text(
          'إحصائيات وتفاعل المستخدمين',
          style: TextStyle(
            color: espresso,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('perfumes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: champagne));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          }

          var perfumes = snapshot.data?.docs.toList() ?? [];
          perfumes.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aLikes = aData.containsKey('likesCount') ? (aData['likesCount'] as int) : 0;
            final bLikes = bData.containsKey('likesCount') ? (bData['likesCount'] as int) : 0;
            return bLikes.compareTo(aLikes);
          });
          if (perfumes.isEmpty) {
            return const Center(child: Text('لا توجد عطور حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: perfumes.length,
            itemBuilder: (context, index) {
              final data = perfumes[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'بدون اسم';
              final likes = data['likesCount'] ?? 0;
              final perfumeId = perfumes[index].id;

              return Card(
                color: ivory,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: champagne, size: 20),
                              const SizedBox(width: 5),
                              Text('$likes إعجاب', style: const TextStyle(color: warmBrown, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            name,
                            style: const TextStyle(color: espresso, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(color: softChampagne, height: 20),
                      const Text(
                        'تعليقات المستخدمين:',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: secondaryText, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('perfumes')
                            .doc(perfumeId)
                            .collection('comments').snapshots(),
                        builder: (context, commentSnapshot) {
                          if (commentSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                          }
                          var comments = commentSnapshot.data?.docs.toList() ?? [];
                          comments.sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>;
                            final bData = b.data() as Map<String, dynamic>;
                            final aTime = aData['timestamp'];
                            final bTime = bData['timestamp'];
                            if (aTime == null && bTime == null) return 0;
                            if (aTime == null) return -1;
                            if (bTime == null) return 1;
                            return bTime.compareTo(aTime);
                          });
                          if (comments.isEmpty) {
                            return const Text('لا توجد تعليقات', style: TextStyle(color: secondaryText, fontSize: 12));
                          }
                          return Column(
                            children: comments.map((c) {
                              final commentData = c.data() as Map<String, dynamic>;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: softBrown,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      commentData['name'] ?? 'مستخدم',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: espresso, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      commentData['text'] ?? '',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(color: secondaryText, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
