import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/about_app_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/discover_perfumes_page.dart';
import '../pages/fragrance_analysis_page.dart';
import '../pages/fragrance_identity_page.dart';
import '../pages/profile_page.dart';
import '../pages/recommendations_page.dart';
import '../pages/saved_perfumes_page.dart';
import '../pages/settings_page.dart';
import '../pages/admin_statistics_page.dart';

class AppDrawer extends StatefulWidget {
final bool isDarkMode;
final ValueChanged<bool> onThemeChanged;
const AppDrawer({
  super.key,
  this.isDarkMode = false,
  required this.onThemeChanged,
});

@override
State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
bool _isAdmin = false;

final Color lightBackground = const Color(0xFFFAF7F5);
final Color lightCard = const Color(0xFFFFFFFF);
final Color darkPurple = const Color(0xFF4A3B52);
final Color mauve = const Color(0xFF8B7185);
final Color champagne = const Color(0xFFD8A9B8);
final Color softChampagne = const Color(0xFFEBD7E0);
final Color secondaryText = const Color(0xFF817781);

@override
void initState() {
super.initState();
_checkAdminStatus();
}

Future<void> _checkAdminStatus() async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) return;

if (user.email == '17mosab69@gmail.com') {
  if (mounted) setState(() { _isAdmin = true; });
  return;
}

try {
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

if (!mounted) return;

setState(() {
_isAdmin = doc.data()?['isAdmin'] == true;
});
} catch (_) {
if (!mounted) return;

setState(() {
_isAdmin = false;
});
}
}

@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;

final userName =
user?.displayName?.trim().isNotEmpty == true
? user!.displayName!
    : 'مستخدمنا العزيز';

final bool dark = widget.isDarkMode;

final Color background =
dark ? const Color(0xFF211C24) : lightBackground;

final Color card =
dark ? const Color(0xFF2D2631) : lightCard;

final Color primaryText =
dark ? Colors.white : darkPurple;

final Color secondary =
dark ? const Color(0xFFD0C5D2) : secondaryText;

return Drawer(
width: MediaQuery.of(context).size.width * 0.84,
backgroundColor: background,
elevation: 0,

child: SafeArea(
child: Column(
children: [

// ==================================================
// Header
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
22,
24,
22,
22,
),
decoration: BoxDecoration(
color: card,
borderRadius: const BorderRadius.only(
bottomLeft: Radius.circular(30),
bottomRight: Radius.circular(30),
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(dark ? 0.20 : 0.05),
blurRadius: 15,
offset: const Offset(0, 5),
),
],
),

child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [

// Close button
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [

IconButton(
onPressed: () {
Navigator.pop(context);
},
icon: Icon(
Icons.close_rounded,
color: primaryText,
),
),

const Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'FRAGRANCE',
style: TextStyle(
color: Color(0xFF4A3B52),
fontSize: 13,
fontWeight: FontWeight.w800,
letterSpacing: 2.2,
),
),
SizedBox(height: 2),
Text(
'IDENTITY',
style: TextStyle(
color: Color(0xFF8B7185),
fontSize: 9,
fontWeight: FontWeight.w600,
letterSpacing: 2.8,
),
),
],
),
],
),

const SizedBox(height: 15),

// User
Row(
textDirection: TextDirection.rtl,
children: [

Container(
width: 54,
height: 54,
decoration: BoxDecoration(
color: softChampagne,
shape: BoxShape.circle,
),
child: const Icon(
Icons.person_outline_rounded,
color: Color(0xFF4A3B52),
size: 29,
),
),

const SizedBox(width: 13),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [

Text(
'مرحباً',
style: TextStyle(
color: secondary,
fontSize: 11,
),
),

const SizedBox(height: 3),

Text(
userName,
maxLines: 1,
overflow: TextOverflow.ellipsis,
textAlign: TextAlign.right,
style: TextStyle(
color: primaryText,
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
],
),
),
],
),
],
),
),

const SizedBox(height: 18),

// ==================================================
// Menu
// ==================================================

Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: 15,
),
child: Column(
children: [

_item(
context,
icon: Icons.home_outlined,
title: 'الرئيسية',
subtitle: 'الصفحة الرئيسية',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);
},
),

_item(
context,
icon: Icons.favorite_border_rounded,
title: 'المفضلة',
subtitle: 'العطور التي أعجبتك',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const SavedPerfumesPage(),
),
);
},
),

_item(
context,
icon: Icons.person_outline_rounded,
title: 'الملف الشخصي',
subtitle: 'بيانات حسابك',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ProfilePage(),
),
);
},
),

_item(
context,
icon: Icons.auto_awesome_rounded,
title: 'هويتي العطرية',
subtitle: 'اكتشف شخصيتك العطرية',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const FragranceIdentityPage(),
),
);
},
),

_item(
context,
icon: Icons.insights_rounded,
title: 'تحليلي العطري',
subtitle: 'شاهدي ملامح هويتك العطرية',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const FragranceAnalysisPage(),
),
);
},
),

_item(
context,
icon: Icons.local_florist_outlined,
title: 'اكتشف توصياتك',
subtitle: 'عطور مناسبة لهويتك',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const RecommendationsPage(),
),
);
},
),

_item(
context,
icon: Icons.search_rounded,
title: 'اكتشف العطور',
subtitle: 'ابحث واستكشف العطور',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const DiscoverPerfumesPage(),
),
);
},
),

_item(
context,
icon: Icons.settings_outlined,
title: 'الإعدادات',
subtitle: 'إعدادات التطبيق والحساب',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => SettingsPage(
isDarkMode: widget.isDarkMode,
onThemeChanged:
widget.onThemeChanged,
),
),
);
},
),

_item(
context,
icon: Icons.info_outline_rounded,
title: 'عن التطبيق',
subtitle: 'تعرف على Fragrance Identity',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AboutAppPage(),
),
);
},
),

if (_isAdmin) ...[
const SizedBox(height: 6),

Divider(
color: dark
? Colors.white12
    : softChampagne,
height: 20,
),

_item(
context,
icon: Icons.admin_panel_settings_outlined,
title: 'إدارة العطور',
subtitle: 'إضافة وتعديل وحذف العطور',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminDashboardPage(),
),
);
},
),
_item(
context,
icon: Icons.bar_chart_rounded,
title: 'إحصائيات التفاعل',
subtitle: 'التعليقات والإعجابات',
primaryText: primaryText,
secondaryText: secondary,
background: card,
onTap: () {
Navigator.pop(context);
Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStatisticsPage()));
},
),
],

const SizedBox(height: 6),

Divider(
color: dark
? Colors.white12
    : softChampagne,
height: 20,
),

_item(
context,
icon: Icons.logout_rounded,
title: 'تسجيل الخروج',
subtitle: 'الخروج من الحساب',
primaryText: primaryText,
secondaryText: secondary,
background: card,
iconColor: mauve,
onTap: () async {
Navigator.pop(context);

await FirebaseAuth.instance.signOut();
},
),

const SizedBox(height: 20),
],
),
),
),

// ==================================================
// Footer
// ==================================================

Padding(
padding: const EdgeInsets.only(
bottom: 15,
),
child: Text(
'FRAGRANCE IDENTITY • YOUR SIGNATURE',
style: TextStyle(
color: dark
? const Color(0xFFB9ACBC)
    : const Color(0xFF9A8D98),
fontSize: 8,
letterSpacing: 1.5,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
);
}

Widget _item(
BuildContext context, {
required IconData icon,
required String title,
required String subtitle,
required Color primaryText,
required Color secondaryText,
required Color background,
required VoidCallback onTap,
Color? iconColor,
}) {
return Padding(
padding: const EdgeInsets.only(bottom: 9),
child: Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(19),
child: Ink(
padding: const EdgeInsets.symmetric(
horizontal: 13,
vertical: 12,
),
decoration: BoxDecoration(
color: background,
borderRadius: BorderRadius.circular(19),
border: Border.all(
color: widget.isDarkMode
? Colors.white10
    : softChampagne,
),
),
child: Row(
textDirection: TextDirection.rtl,
children: [

Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: widget.isDarkMode
? const Color(0xFF403542)
    : const Color(0xFFF1E9F0),
borderRadius: BorderRadius.circular(14),
),
child: Icon(
icon,
color: iconColor ??
(widget.isDarkMode
? champagne
    : mauve),
size: 23,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [

Text(
title,
textAlign: TextAlign.right,
style: TextStyle(
color: primaryText,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 3),

Text(
subtitle,
textAlign: TextAlign.right,
style: TextStyle(
color: secondaryText,
fontSize: 10.5,
),
),
],
),
),

const SizedBox(width: 8),

Icon(
Icons.arrow_back_ios_new_rounded,
color: widget.isDarkMode
? champagne
    : champagne,
size: 14,
),
],
),
),
),
),
);
}
}

