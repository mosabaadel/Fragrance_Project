import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'fragrance_identity_page.dart';
import '../widgets/app_logo.dart';
import 'admin_dashboard_page.dart';
import 'discover_perfumes_page.dart';
import 'fragrance_analysis_page.dart';
import 'recommendations_page.dart';
import 'saved_perfumes_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'about_app_page.dart';
import 'admin_statistics_page.dart';
import '../widgets/app_drawer.dart';

// ============================================================
// 🎨 Fragrance Identity — Luxury Unisex Theme
// ============================================================

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color darkBrown = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);
const Color taupe = Color(0xFF9A8D98);
const Color secondaryText = Color(0xFF817781);
const Color softBrown = Color(0xFFF1E9F0);

// ============================================================
// 🏠 Home Page
// ============================================================

class HomePage extends StatefulWidget {
const HomePage({super.key});

@override
State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
with SingleTickerProviderStateMixin {
late AnimationController _animationController;

late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;

bool _isAdmin = false;
bool _isDarkMode = false;
@override
void initState() {
super.initState();

_animationController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 900),
);

_fadeAnimation = CurvedAnimation(
parent: _animationController,
curve: Curves.easeOut,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.08),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
),
);

_animationController.forward();

_checkAdminStatus();
}

// ============================================================
// 🔐 Check Admin
// ============================================================

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
void dispose() {
_animationController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;

final String userName =
user?.displayName?.trim().isNotEmpty == true
? user!.displayName!
    : 'مستخدمنا العزيز';

final double screenWidth = MediaQuery.of(context).size.width;

final double horizontalPadding = screenWidth < 360 ? 16 : 22;

return Scaffold(
backgroundColor: backgroundColor,

// ========================================================
// AppBar
// ========================================================

appBar: AppBar(
backgroundColor: backgroundColor,
elevation: 0,
scrolledUnderElevation: 0,
automaticallyImplyLeading: false,
titleSpacing: 20,

title: Row(
children: [
// Logo صغير
Container(
width: 42,
height: 42,
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: softChampagne,
width: 1,
),
),
child: const AppLogo(
size: 30,
),
),

const SizedBox(width: 12),

const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'FRAGRANCE',
style: TextStyle(
color: espresso,
fontSize: 12,
fontWeight: FontWeight.w800,
letterSpacing: 2.2,
),
),
SizedBox(height: 2),
Text(
'IDENTITY',
style: TextStyle(
color: warmBrown,
fontSize: 9,
fontWeight: FontWeight.w600,
letterSpacing: 2.8,
),
),
],
),
),
],
),

// ======================================================
// ⋮ More Menu
// ======================================================

actions: [
Padding(
padding: const EdgeInsets.only(right: 14),
  child: Builder(
    builder: (context) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ivory,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: softChampagne,
            width: 1,
          ),
        ),
        child: IconButton(
          tooltip: 'القائمة',
          icon: const Icon(
            Icons.menu_rounded,
            color: espresso,
            size: 25,
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      );
    },
  ),
),
  ],
  ), // إغلاق AppBar هنا فقط

// ======================================================
// Drawer
// ======================================================

  endDrawer: AppDrawer(
  isDarkMode: _isDarkMode,
  onThemeChanged: (value) {
  setState(() {
  _isDarkMode = value;
  });
  },
  ),

// ========================================================
// Body
// ========================================================

  body: SafeArea(
  child: FadeTransition(
  opacity: _fadeAnimation,
  child: SlideTransition(
  position: _slideAnimation,
  child: SingleChildScrollView(
  physics: const BouncingScrollPhysics(),

padding: EdgeInsets.fromLTRB(
horizontalPadding,
8,
horizontalPadding,
30,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
// ==================================================
// ✨ 3 Connected Dots
// ==================================================

_buildJourneyIndicator(),

const SizedBox(height: 28),

// ==================================================
// 👋 Welcome
// ==================================================

Center(
child: Text(
'مرحباً $userName',
textAlign: TextAlign.center,
style: const TextStyle(
color: warmBrown,
fontSize: 17,
fontWeight: FontWeight.w600,
),
),
),

const SizedBox(height: 10),

// ==================================================
// Main Title
// ==================================================

const Text(
'اكتشف هويتك العطرية',
textAlign: TextAlign.center,
style: TextStyle(
color: espresso,
fontSize: 30,
height: 1.2,
fontWeight: FontWeight.w800,
letterSpacing: -0.5,
),
),

const SizedBox(height: 12),

const Text(
'عطرك ليس مجرد رائحة...',
textAlign: TextAlign.center,
style: TextStyle(
color: warmBrown,
fontSize: 15,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 8),

const Padding(
padding: EdgeInsets.symmetric(horizontal: 12),
child: Text(
'اكتشف العطر الذي يعكس شخصيتك، '
'أسلوب حياتك وذوقك الخاص باستخدام تقنية معالجة اللغة الطبيعية NLP.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14,
height: 1.7,
color: secondaryText,
),
),
),

const SizedBox(height: 28),

// ==================================================
// 🧴 Luxury Hero Card
// ==================================================

_buildHeroCard(context),

const SizedBox(height: 22),

// ==================================================
// 🧠 NLP Card
// ==================================================

_buildNLPCard(),

const SizedBox(height: 24),

// ==================================================
// YOUR JOURNEY
// ==================================================

const Text(
'رحلتك العطرية',
textAlign: TextAlign.right,
style: TextStyle(
color: espresso,
fontSize: 19,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 14),

// ==================================================
// Journey Cards
// ==================================================

// هويتي العطرية فقط
// المفضلة أصبحت داخل قائمة ⋮
_buildFeatureCard(
icon: Icons.auto_awesome_rounded,
title: 'هويتي العطرية',
subtitle: 'اكتشف شخصيتك العطرية',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const FragranceIdentityPage(),
),
);
},
),
  const SizedBox(height: 18),

  _buildFeatureCard(
    icon: Icons.insights_rounded,
    title: 'تحليلي العطري',
    subtitle: 'شاهدي ملامح هويتك العطرية',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FragranceAnalysisPage(),
        ),
      );
    },
  ),
const SizedBox(height: 18),

// ==================================================
// Recommendation Preview
// ==================================================
  _buildRecommendationCard(context),

  const SizedBox(height: 18),

  _buildFeatureCard(
    icon: Icons.search_rounded,
    title: 'اكتشف العطور',
    subtitle: 'ابحث واكتشف العطور المختلفة',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiscoverPerfumesPage(),
        ),
      );
    },
  ),

  const SizedBox(height: 26),
// ==================================================
// App Version / Brand
// ==================================================

const Center(
child: Text(
'FRAGRANCE IDENTITY • YOUR SIGNATURE',
style: TextStyle(
color: taupe,
fontSize: 8.5,
letterSpacing: 1.7,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
),
),
),
);
}

// ============================================================
// ⋮ More Menu
// ============================================================

void _showMoreMenu(
BuildContext context,
String userName,
) {
showModalBottomSheet(
context: context,
backgroundColor: Colors.transparent,
isScrollControlled: true,
builder: (sheetContext) {
return Container(
decoration: const BoxDecoration(
color: ivory,
borderRadius: BorderRadius.vertical(
top: Radius.circular(30),
),
),
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
28,
),
child: SafeArea(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
// Handle
Container(
width: 42,
height: 4,
decoration: BoxDecoration(
color: softChampagne,
borderRadius: BorderRadius.circular(10),
),
),

const SizedBox(height: 20),

const Align(
alignment: Alignment.centerRight,
child: Text(
'المزيد',
style: TextStyle(
color: espresso,
fontSize: 20,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(height: 16),

// ==================================================
// 👤 الحساب
// ==================================================

_buildMenuItem(
icon: Icons.person_outline_rounded,
title: 'حسابي',
subtitle: userName,
onTap: () {
Navigator.pop(sheetContext);

_showAccountDialog(
context,
userName,
);
},
),

const SizedBox(height: 10),

// ==================================================
// ❤️ المفضلة
// ==================================================
  _buildMenuItem(
    icon: Icons.favorite_border_rounded,
    title: 'المفضلة',
    subtitle: 'العطور التي أعجبتك',
    onTap: () {
      Navigator.pop(sheetContext);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SavedPerfumesPage(),
        ),
      );
    },
  ),

  _buildMenuItem(
    icon: Icons.person_outline_rounded,
    title: 'الملف الشخصي',
    subtitle: 'بيانات حسابك',
    onTap: () {
      Navigator.pop(sheetContext);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        ),
      );
    },
  ),
  _buildMenuItem(
    icon: Icons.settings_outlined,
    title: 'الإعدادات',
    subtitle: 'إعدادات التطبيق والحساب',
    onTap: () {
      Navigator.pop(sheetContext);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_)
          => SettingsPage(
            isDarkMode: _isDarkMode,
            onThemeChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
        ),
      );
    },
  ),

// ==================================================
// ℹ️ عن التطبيق
// ==================================================

  _buildMenuItem(
    icon: Icons.info_outline_rounded,
    title: 'عن التطبيق',
    subtitle: 'تعرف على Fragrance Identity',
    onTap: () {
      Navigator.pop(sheetContext);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AboutAppPage(),
        ),
      );
    },
  ),

  const SizedBox(height: 10),

// ==================================================
// 🧴 إدارة العطور — Admin فقط
// ==================================================

if (_isAdmin) ...[
const SizedBox(height: 10),

_buildMenuItem(
icon: Icons.admin_panel_settings_outlined,
title: 'إدارة العطور',
subtitle: 'إضافة وتعديل وحذف العطور',
onTap: () {
Navigator.pop(sheetContext);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminDashboardPage(),
),
);
},
),
],

const SizedBox(height: 10),

// ==================================================
// 🚪 تسجيل الخروج
// ==================================================

_buildMenuItem(
icon: Icons.logout_rounded,
title: 'تسجيل الخروج',
subtitle: 'الخروج من الحساب',
iconColor: secondaryText,
onTap: () async {
Navigator.pop(sheetContext);

await FirebaseAuth.instance.signOut();
},
),
],
),
),
);
},
);
}

// ============================================================
// Menu Item
// ============================================================

Widget _buildMenuItem({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
Color iconColor = warmBrown,
}) {
return Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(18),
child: Ink(
padding: const EdgeInsets.symmetric(
horizontal: 15,
vertical: 13,
),
decoration: BoxDecoration(
color: backgroundColor,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: softChampagne,
width: 1,
),
),
child: Row(
textDirection: TextDirection.rtl,
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: softBrown,
borderRadius: BorderRadius.circular(14),
),
child: Icon(
icon,
color: iconColor,
size: 23,
),
),

const SizedBox(width: 13),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
title,
textAlign: TextAlign.right,
style: const TextStyle(
color: espresso,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 3),
Text(
subtitle,
textAlign: TextAlign.right,
style: const TextStyle(
color: secondaryText,
fontSize: 10.5,
),
),
],
),
),

const SizedBox(width: 8),

const Icon(
Icons.arrow_back_ios_new_rounded,
color: champagne,
size: 15,
),
],
),
),
),
);
}

// ============================================================
// ✨ 3 Connected Dots
// ============================================================

Widget _buildJourneyIndicator() {
return Center(
child: SizedBox(
width: 245,
child: Row(
children: [
_buildJourneyDot(
icon: Icons.person_outline_rounded,
label: 'أنت',
active: true,
),

Expanded(
child: Container(
height: 1.2,
color: champagne,
),
),

_buildJourneyDot(
icon: Icons.auto_awesome_rounded,
label: 'تحليل NLP',
active: false,
),

Expanded(
child: Container(
height: 1.2,
color: champagne,
),
),

_buildJourneyDot(
icon: Icons.local_florist_outlined,
label: 'عطرك',
active: false,
),
],
),
),
);
}

Widget _buildJourneyDot({
required IconData icon,
required String label,
required bool active,
}) {
return Column(
mainAxisSize: MainAxisSize.min,
children: [
AnimatedContainer(
duration: const Duration(milliseconds: 500),
width: 40,
height: 40,
decoration: BoxDecoration(
color: active ? espresso : ivory,
shape: BoxShape.circle,
border: Border.all(
color: active ? espresso : champagne,
width: 1.2,
),
boxShadow: active
? [
BoxShadow(
color: espresso.withOpacity(0.15),
blurRadius: 12,
offset: const Offset(0, 5),
),
]
    : null,
),
child: Icon(
icon,
size: 19,
color: active ? champagne : warmBrown,
),
),

const SizedBox(height: 6),

Text(
label,
style: TextStyle(
fontSize: 9.5,
color: active ? espresso : taupe,
fontWeight: active
? FontWeight.w700
    : FontWeight.w500,
),
),
],
);
}

// ============================================================
// 🧴 Hero Card
// ============================================================

Widget _buildHeroCard(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(25),
decoration: BoxDecoration(
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFF4A3B52),
Color(0xFF66516D),
Color(0xFF8B7185),
],
),
borderRadius: BorderRadius.circular(30),
boxShadow: [
BoxShadow(
color: espresso.withOpacity(0.20),
blurRadius: 28,
offset: const Offset(0, 14),
),
],
),
child: Stack(
children: [
Positioned(
top: -50,
right: -45,
child: Container(
width: 145,
height: 145,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: champagne.withOpacity(0.16),
width: 1,
),
),
),
),

Positioned(
bottom: -65,
left: -45,
child: Container(
width: 130,
height: 130,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: Colors.white.withOpacity(0.08),
width: 1,
),
),
),
),

Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 30,
height: 1,
color: champagne,
),
const SizedBox(width: 9),
const Text(
'YOUR SIGNATURE',
style: TextStyle(
color: champagne,
fontSize: 9,
fontWeight: FontWeight.w700,
letterSpacing: 2,
),
),
],
),

const SizedBox(height: 22),

const Text(
'عطرك يبدأ\nمن شخصيتك.',
textAlign: TextAlign.left,
style: TextStyle(
color: Colors.white,
fontSize: 27,
height: 1.25,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 13),

const Text(
'دعنا نتعرف عليك ونحوّل شخصيتك '
'وتفضيلاتك إلى هوية عطرية فريدة.',
textAlign: TextAlign.left,
style: TextStyle(
color: Color(0xFFE9DED4),
fontSize: 13,
height: 1.7,
),
),

const SizedBox(height: 23),

SizedBox(
height: 50,
child: ElevatedButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const FragranceIdentityPage(),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: champagne,
foregroundColor: espresso,
elevation: 0,
padding: const EdgeInsets.symmetric(
horizontal: 22,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
child: const Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'ابدأ بناء هويتي',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
SizedBox(width: 8),
Icon(
Icons.arrow_forward_rounded,
size: 19,
),
],
),
),
),
],
),
],
),
);
}

// ============================================================
// 🧠 NLP Card
// ============================================================

Widget _buildNLPCard() {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: softChampagne,
width: 1,
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
borderRadius: BorderRadius.circular(16),
),
child: const Icon(
Icons.psychology_alt_rounded,
color: warmBrown,
size: 27,
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'تحليل شخصيتك وتفضيلاتك',
textAlign: TextAlign.right,
style: TextStyle(
color: espresso,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),

SizedBox(height: 5),

Text(
'نحلل إجاباتك باستخدام تقنية NLP '
'لاكتشاف ملامح هويتك العطرية.',
textAlign: TextAlign.right,
style: TextStyle(
color: secondaryText,
fontSize: 11.5,
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
// ✦ Feature Card
// ============================================================

Widget _buildFeatureCard({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(22),
child: Ink(
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: softChampagne,
width: 1,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: softBrown,
borderRadius: BorderRadius.circular(15),
),
child: Icon(
icon,
color: warmBrown,
size: 23,
),
),

const SizedBox(height: 14),

Text(
title,
textAlign: TextAlign.right,
style: const TextStyle(
color: espresso,
fontSize: 13,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 5),

Text(
subtitle,
textAlign: TextAlign.right,
style: const TextStyle(
color: secondaryText,
fontSize: 10.5,
),
),

const SizedBox(height: 11),

const Align(
alignment: Alignment.centerLeft,
child: Icon(
Icons.arrow_back_rounded,
color: champagne,
size: 18,
),
),
],
),
),
),
);
}

// ============================================================
// 🧴 Recommendation Card
// ============================================================

Widget _buildRecommendationCard(BuildContext context) {
return Material(
color: Colors.transparent,
child: InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecommendationsPage(),
      ),
    );
  },
borderRadius: BorderRadius.circular(24),
child: Ink(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: darkBrown,
borderRadius: BorderRadius.circular(24),
),
child: Row(
textDirection: TextDirection.rtl,
children: [
Container(
width: 54,
height: 54,
decoration: BoxDecoration(
color: champagne.withOpacity(0.16),
borderRadius: BorderRadius.circular(17),
),
child: const Icon(
Icons.local_florist_outlined,
color: champagne,
size: 27,
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'اكتشف توصياتك',
textAlign: TextAlign.right,
style: TextStyle(
color: Colors.white,
fontSize: 15,
fontWeight: FontWeight.w800,
),
),
SizedBox(height: 5),
Text(
'عطور مختارة بناءً على هويتك العطرية',
textAlign: TextAlign.right,
style: TextStyle(
color: Color(0xFFD8C8BA),
fontSize: 11,
),
),
],
),
),

const SizedBox(width: 8),

const Icon(
Icons.arrow_back_ios_new_rounded,
color: champagne,
size: 17,
),
],
),
),
),
);
}

// ============================================================
// 👤 Account Dialog
// ============================================================

void _showAccountDialog(
BuildContext context,
String userName,
) {
final user = FirebaseAuth.instance.currentUser;

showDialog(
context: context,
builder: (context) {
return Dialog(
backgroundColor: Colors.transparent,
insetPadding: const EdgeInsets.symmetric(
horizontal: 24,
),
child: Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: ivory,
borderRadius: BorderRadius.circular(30),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.15),
blurRadius: 30,
offset: const Offset(0, 12),
),
],
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 78,
height: 78,
decoration: BoxDecoration(
color: softBrown,
shape: BoxShape.circle,
border: Border.all(
color: champagne,
width: 1,
),
),
child: const Icon(
Icons.person_outline_rounded,
color: warmBrown,
size: 42,
),
),

const SizedBox(height: 17),

const Text(
'حسابي',
style: TextStyle(
color: espresso,
fontSize: 20,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 12),

Text(
userName,
textAlign: TextAlign.center,
style: const TextStyle(
color: warmBrown,
fontSize: 16,
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 7),

Text(
user?.email ?? '',
textAlign: TextAlign.center,
style: const TextStyle(
color: secondaryText,
fontSize: 12.5,
),
),

const SizedBox(height: 22),

SizedBox(
width: double.infinity,
height: 48,
child: OutlinedButton(
onPressed: () {
Navigator.pop(context);
},
style: OutlinedButton.styleFrom(
foregroundColor: warmBrown,
side: const BorderSide(
color: champagne,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
),
child: const Text(
'إغلاق',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
),
],
),
),
);
},
);
}

// ============================================================
// Coming Soon
// ============================================================

void _showComingSoon(
BuildContext context,
String title,
) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'$title ستكون متاحة من خلال صفحة التوصيات الحالية.',
textAlign: TextAlign.right,
),
behavior: SnackBarBehavior.floating,
backgroundColor: espresso,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
);
}
}

