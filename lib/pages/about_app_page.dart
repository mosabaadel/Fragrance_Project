import 'package:flutter/material.dart';

// ============================================================
// Fragrance Identity — About App
// ============================================================

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color mauve = Color(0xFF8B7185);
const Color rose = Color(0xFFD8A9B8);
const Color lightRose = Color(0xFFEBD7E0);

class AboutAppPage extends StatelessWidget {
const AboutAppPage({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: backgroundColor,

appBar: AppBar(
backgroundColor: backgroundColor,
elevation: 0,
centerTitle: true,
iconTheme: const IconThemeData(color: espresso),
title: const Text(
'عن التطبيق',
style: TextStyle(
color: espresso,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
),

body: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

child: Column(
children: [

// ==================================================
// Logo / App Header
// ==================================================
Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 28,
),
decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 15,
offset: const Offset(0, 5),
),
],
),

child: Column(
children: [
Container(
width: 78,
height: 78,
decoration: BoxDecoration(
color: lightRose,
shape: BoxShape.circle,
),
child: const Icon(
Icons.auto_awesome,
size: 38,
color: espresso,
),
),

const SizedBox(height: 18),

const Text(
'Fragrance Identity',
textAlign: TextAlign.center,
style: TextStyle(
color: espresso,
fontSize: 25,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
'تطبيق ذكي لبناء هوية عطرية مخصصة لكل فرد',
textAlign: TextAlign.center,
style: TextStyle(
color: mauve,
fontSize: 15,
height: 1.6,
),
),
],
),
),

const SizedBox(height: 20),

// ==================================================
// About
// ==================================================
_buildSection(
icon: Icons.info_outline,
title: 'نبذة عن التطبيق',
child: const Text(
'Fragrance Identity هو تطبيق يساعد المستخدم على اكتشاف '
'هويته العطرية من خلال تحليل شخصيته ونمط حياته واهتماماته '
'وتفضيلاته العطرية، ثم مطابقة هذه المعلومات مع خصائص '
'العطور لتقديم توصيات عطرية مناسبة له.',
style: TextStyle(
color: espresso,
fontSize: 15,
height: 1.8,
),
),
),

const SizedBox(height: 16),

// ==================================================
// How it works
// ==================================================
_buildSection(
icon: Icons.auto_awesome,
title: 'كيف يعمل التطبيق؟',
child: Column(
children: [
_buildStep(
number: '1',
title: 'الإجابة عن الأسئلة',
description:
'يجيب المستخدم عن مجموعة من الأسئلة المتعلقة بشخصيته ونمط حياته وتفضيلاته.',
),
_buildStep(
number: '2',
title: 'تحليل الإجابات',
description:
'يتم تحليل الإجابات النصية واستخراج الخصائص والسمات العطرية منها.',
),
_buildStep(
number: '3',
title: 'بناء الهوية العطرية',
description:
'يتم إنشاء ملف يمثل الهوية العطرية الخاصة بالمستخدم.',
),
_buildStep(
number: '4',
title: 'مطابقة العطور',
description:
'تتم مقارنة الهوية العطرية مع خصائص العطور الموجودة في التطبيق.',
),
_buildStep(
number: '5',
title: 'التوصيات',
description:
'يتم ترتيب العطور وإظهار التوصيات الأكثر توافقًا مع المستخدم.',
),
],
),
),

const SizedBox(height: 16),

// ==================================================
// Features
// ==================================================
_buildSection(
icon: Icons.stars_outlined,
title: 'مميزات التطبيق',
child: Column(
children: [
_buildFeature(
Icons.person_outline,
'بناء الهوية العطرية',
'إنشاء هوية عطرية مخصصة لكل مستخدم.',
),
_buildFeature(
Icons.analytics_outlined,
'التحليل العطري',
'تحليل إجابات المستخدم واستخراج السمات العطرية.',
),
_buildFeature(
Icons.recommend,
'التوصيات المخصصة',
'اقتراح العطور بناءً على مدى توافقها مع هوية المستخدم.',
),
_buildFeature(
Icons.explore_outlined,
'اكتشاف العطور',
'استعراض مجموعة العطور وخصائصها المختلفة.',
),
_buildFeature(
Icons.favorite_border,
'العطور المفضلة',
'حفظ العطور التي يفضلها المستخدم للرجوع إليها لاحقًا.',
),
],
),
),

const SizedBox(height: 16),

// ==================================================
// Project
// ==================================================
_buildSection(
icon: Icons.school_outlined,
title: 'عن المشروع',
child: const Text(
'تم تطوير Fragrance Identity كمشروع تخرج بهدف تقديم '
'تجربة رقمية تساعد المستخدم على فهم تفضيلاته العطرية '
'والوصول إلى عطور تتناسب مع هويته الشخصية.',
style: TextStyle(
color: espresso,
fontSize: 15,
height: 1.8,
),
),
),

const SizedBox(height: 25),

// ==================================================
// Version
// ==================================================
const Text(
'Fragrance Identity',
style: TextStyle(
color: espresso,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 5),

const Text(
'الإصدار 1.0.0',
style: TextStyle(
color: mauve,
fontSize: 13,
),
),

const SizedBox(height: 8),

const Text(
'مشروع تخرج',
style: TextStyle(
color: mauve,
fontSize: 13,
),
),
],
),
),
);
}

// ============================================================
// Section
// ============================================================

static Widget _buildSection({
required IconData icon,
required String title,
required Widget child,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 12,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: lightRose,
borderRadius: BorderRadius.circular(13),
),
child: Icon(
icon,
color: espresso,
size: 23,
),
),

const SizedBox(width: 12),

Text(
title,
style: const TextStyle(
color: espresso,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
],
),

const SizedBox(height: 16),

child,
],
),
);
}

// ============================================================
// Steps
// ============================================================

static Widget _buildStep({
required String number,
required String title,
required String description,
}) {
return Padding(
padding: const EdgeInsets.only(bottom: 16),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 34,
height: 34,
decoration: const BoxDecoration(
color: espresso,
shape: BoxShape.circle,
),
alignment: Alignment.center,
child: Text(
number,
style: const TextStyle(
color: ivory,
fontSize: 14,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: espresso,
fontSize: 15,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
description,
style: const TextStyle(
color: mauve,
fontSize: 13,
height: 1.6,
),
),
],
),
),
],
),
);
}

// ============================================================
// Features
// ============================================================

static Widget _buildFeature(
IconData icon,
String title,
String description,
) {
return Padding(
padding: const EdgeInsets.only(bottom: 16),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
color: rose,
size: 25,
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: espresso,
fontSize: 15,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 3),

Text(
description,
style: const TextStyle(
color: mauve,
fontSize: 13,
height: 1.5,
),
),
],
),
),
],
),
);
}
}

