import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ============================================================
// Fragrance Identity — المفضلة
// يعرض العطور التي قام المستخدم بعمل Like لها
// ============================================================

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);

class SavedPerfumesPage extends StatelessWidget {
const SavedPerfumesPage({super.key});

@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
return Scaffold(
backgroundColor: backgroundColor,
appBar: AppBar(
title: const Text(
'المفضلة',
style: TextStyle(
fontWeight: FontWeight.bold,
color: espresso,
),
),
centerTitle: true,
backgroundColor: backgroundColor,
foregroundColor: espresso,
elevation: 0,
),
body: const Center(
child: Text(
'يرجى تسجيل الدخول أولاً',
style: TextStyle(color: espresso),
),
),
);
}

return Scaffold(
backgroundColor: backgroundColor,

appBar: AppBar(
title: const Text(
'المفضلة',
style: TextStyle(
fontWeight: FontWeight.bold,
color: espresso,
),
),
centerTitle: true,
backgroundColor: backgroundColor,
foregroundColor: espresso,
elevation: 0,
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .collection('interactions')
    .where('action', isEqualTo: 'liked')
    .snapshots(),

builder: (context, snapshot) {
// ----------------------------------------------------
// Loading
// ----------------------------------------------------

if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(
color: champagne,
),
);
}

// ----------------------------------------------------
// Error
// ----------------------------------------------------

if (snapshot.hasError) {
return _buildEmptyState(
icon: Icons.error_outline,
title: 'حدث خطأ',
subtitle: 'تعذر تحميل العطور المفضلة.',
);
}

final documents = snapshot.data?.docs ?? [];

// ----------------------------------------------------
// لا توجد مفضلة
// ----------------------------------------------------

if (documents.isEmpty) {
return _buildEmptyState(
icon: Icons.favorite_border,
title: 'لا توجد عطور في المفضلة',
subtitle:
'عندما يعجبك أحد العطور سيظهر هنا ❤️',
);
}

// ----------------------------------------------------
// عرض العطور
// ----------------------------------------------------

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: documents.length,
itemBuilder: (context, index) {
final data =
documents[index].data()
as Map<String, dynamic>;

return _buildPerfumeCard(data);
},
);
},
),
);
}

// ============================================================
// بطاقة العطر
// ============================================================

Widget _buildPerfumeCard(
Map<String, dynamic> data,
) {
final perfumeName =
data['perfumeName']?.toString() ?? 'عطر';

final perfumeFamily =
data['perfumeFamily']?.toString() ?? '';

final perfumeStrength =
data['perfumeStrength']?.toString() ?? '';

final perfumeNotes =
data['perfumeNotes'] as List<dynamic>? ?? [];

return Container(
margin: const EdgeInsets.only(bottom: 16),

decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(22),

boxShadow: [
BoxShadow(
color: espresso.withOpacity(0.08),
blurRadius: 12,
offset: const Offset(0, 5),
),
],
),

child: Padding(
padding: const EdgeInsets.all(18),

child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// --------------------------------------------------
// أيقونة العطر
// --------------------------------------------------

Container(
width: 72,
height: 72,

decoration: BoxDecoration(
color: softChampagne,
borderRadius: BorderRadius.circular(18),
),

child: const Icon(
Icons.local_florist_outlined,
size: 38,
color: warmBrown,
),
),

const SizedBox(width: 15),

// --------------------------------------------------
// معلومات العطر
// --------------------------------------------------

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
Text(
perfumeName,

maxLines: 2,
overflow: TextOverflow.ellipsis,

style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: espresso,
),
),

const SizedBox(height: 8),

if (perfumeFamily.isNotEmpty)
_buildInfoRow(
Icons.local_florist_outlined,
perfumeFamily,
),

if (perfumeStrength.isNotEmpty)
Padding(
padding:
const EdgeInsets.only(top: 5),
child: _buildInfoRow(
Icons.water_drop_outlined,
perfumeStrength,
),
),

if (perfumeNotes.isNotEmpty)
Padding(
padding:
const EdgeInsets.only(top: 7),
child: Text(
perfumeNotes.join(' • '),

maxLines: 2,
overflow: TextOverflow.ellipsis,

style: const TextStyle(
fontSize: 12,
color: warmBrown,
),
),
),
],
),
),

// --------------------------------------------------
// القلب
// --------------------------------------------------

const Padding(
padding: EdgeInsets.only(left: 8),
child: Icon(
Icons.favorite,
color: champagne,
size: 27,
),
),
],
),
),
);
}

// ============================================================
// صف المعلومات
// ============================================================

Widget _buildInfoRow(
IconData icon,
String text,
) {
return Row(
children: [
Icon(
icon,
size: 15,
color: warmBrown,
),

const SizedBox(width: 5),

Flexible(
child: Text(
text,

maxLines: 1,
overflow: TextOverflow.ellipsis,

style: const TextStyle(
fontSize: 13,
color: warmBrown,
),
),
),
],
);
}

// ============================================================
// حالة عدم وجود بيانات
// ============================================================

Widget _buildEmptyState({
required IconData icon,
required String title,
required String subtitle,
}) {
return Center(
child: Padding(
padding: const EdgeInsets.all(30),

child: Column(
mainAxisAlignment: MainAxisAlignment.center,

children: [
Icon(
icon,
size: 70,
color: champagne,
),

const SizedBox(height: 18),

Text(
title,

textAlign: TextAlign.center,

style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: espresso,
),
),

const SizedBox(height: 8),

Text(
subtitle,

textAlign: TextAlign.center,

style: const TextStyle(
fontSize: 14,
color: warmBrown,
),
),
],
),
),
);
}
}

