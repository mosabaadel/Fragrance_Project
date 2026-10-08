import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/nlp_connection_service.dart';
import '../widgets/app_logo.dart';
import 'analysis_result_page.dart';

class FragranceIdentityPage extends StatefulWidget {
const FragranceIdentityPage({super.key});

@override
State<FragranceIdentityPage> createState() =>
_FragranceIdentityPageState();
}

class _FragranceIdentityPageState
extends State<FragranceIdentityPage> {
// ============================================================
// 🎨 Fragrance Identity — Luxury Unisex Theme
// ============================================================

static const Color backgroundColor = Color(0xFFFAF7F5);
static const Color ivory = Color(0xFFFFFFFF);
static const Color espresso = Color(0xFF4A3B52);
static const Color warmBrown = Color(0xFF8B7185);
static const Color champagne = Color(0xFFD8A9B8);
static const Color softChampagne = Color(0xFFEBD7E0);
static const Color taupe = Color(0xFF9A8D98);
static const Color secondaryText = Color(0xFF817781);
static const Color softBrown = Color(0xFFF1E9F0);

// ============================================================
// 📝 Form
// ============================================================

final _formKey = GlobalKey<FormState>();

final personalityController = TextEditingController();
final lifestyleController = TextEditingController();
final interestsController = TextEditingController();
final favoriteScentsController = TextEditingController();
final dislikedScentsController = TextEditingController();
final moodController = TextEditingController();
final fragranceDescriptionController =
TextEditingController();

String? gender;

bool isLoading = false;

// أثناء تحميل بيانات المستخدم
bool isProfileLoading = true;

// هل توجد إجابات محفوظة؟
bool hasSavedProfile = false;

// هل نعرض الأسئلة أم شاشة الاختيار؟
bool showQuestions = false;

// ============================================================
// 🚀 Init
// ============================================================

@override
void initState() {
super.initState();
loadSavedProfile();
}

// ============================================================
// 📥 تحميل البيانات المحفوظة للمستخدم
// ============================================================

Future<void> loadSavedProfile() async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
if (!mounted) return;

setState(() {
isProfileLoading = false;
hasSavedProfile = false;
showQuestions = true;
});

return;
}

try {
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

if (!userDoc.exists) {
if (!mounted) return;

setState(() {
isProfileLoading = false;
hasSavedProfile = false;
showQuestions = true;
});

return;
}

final data = userDoc.data();

if (data == null) {
if (!mounted) return;

setState(() {
isProfileLoading = false;
hasSavedProfile = false;
showQuestions = true;
});

return;
}

final savedGender =
data['gender']?.toString();

final personality =
data['personalityText']?.toString() ?? '';

final lifestyle =
data['lifestyleText']?.toString() ?? '';

final interests =
data['interestsText']?.toString() ?? '';

final favoriteScents =
data['favoriteScentsText']?.toString() ?? '';

final dislikedScents =
data['dislikedScentsText']?.toString() ?? '';

final mood =
data['moodText']?.toString() ?? '';

final fragranceDescription =
data['fragranceDescriptionText']?.toString() ?? '';

// نعتبر أن هناك Profile محفوظ إذا كان عندنا
// أي إجابة نصية أو جنس محفوظ.
final bool savedProfileExists =
savedGender != null ||
personality.isNotEmpty ||
lifestyle.isNotEmpty ||
interests.isNotEmpty ||
favoriteScents.isNotEmpty ||
dislikedScents.isNotEmpty ||
mood.isNotEmpty ||
fragranceDescription.isNotEmpty;

if (!mounted) return;

setState(() {
gender = savedGender;

personalityController.text = personality;
lifestyleController.text = lifestyle;
interestsController.text = interests;
favoriteScentsController.text = favoriteScents;
dislikedScentsController.text = dislikedScents;
moodController.text = mood;
fragranceDescriptionController.text =
fragranceDescription;

hasSavedProfile = savedProfileExists;

isProfileLoading = false;

// إذا عنده بيانات محفوظة:
// نعرض شاشة الاختيار.
//
// إذا ما عنده:
// ندخله مباشرة على الأسئلة.
showQuestions = !savedProfileExists;
});

debugPrint(
'✅ Saved fragrance profile loaded successfully.',
);
} catch (e) {
debugPrint(
'❌ Error loading saved fragrance profile: $e',
);

if (!mounted) return;

setState(() {
isProfileLoading = false;
hasSavedProfile = false;
showQuestions = true;
});
}
}

// ============================================================
// ✏️ تعديل الإجابات السابقة
// ============================================================

void editSavedAnswers() {
setState(() {
showQuestions = true;
});
}

// ============================================================
// 🔄 البدء من جديد
//
// ملاحظة:
// هذه الدالة لا تحذف بيانات Firestore.
// فقط تنظف النموذج الحالي.
// البيانات القديمة تستبدل فقط بعد الحفظ والتحليل الجديد.
// ============================================================

void startFromScratch() {
setState(() {
gender = null;

personalityController.clear();
lifestyleController.clear();
interestsController.clear();
favoriteScentsController.clear();
dislikedScentsController.clear();
moodController.clear();
fragranceDescriptionController.clear();

showQuestions = true;
});
}

// ============================================================
// 🧠 إرسال النص إلى NLP Backend
// ============================================================

Future<Map<String, dynamic>?> analyzeWithNLP(
String combinedText,
) async {
try {
final nlpBaseUrl =
NlpConnectionService.baseUrl;

if (nlpBaseUrl == null) {
debugPrint(
'NLP Backend is not connected.',
);

return null;
}

final response = await http
    .post(
Uri.parse(
'$nlpBaseUrl/analyze',
),
headers: {
'Content-Type': 'application/json',
'Accept': 'application/json',
},
body: jsonEncode({
'text': combinedText,
}),
)
    .timeout(
const Duration(seconds: 15),
);

if (response.statusCode != 200) {
debugPrint(
'NLP Error: ${response.statusCode}',
);

debugPrint(
'NLP Response: ${response.body}',
);

return null;
}

final data = jsonDecode(response.body);

if (data is Map<String, dynamic> &&
data['success'] == true) {
return data;
}

return null;
} catch (e) {
debugPrint(
'NLP Connection Error: $e',
);

return null;
}
}

// ============================================================
// 🧩 بناء النص الذي سيتم إرساله إلى NLP
// ============================================================

String buildCombinedText() {
return '''
الشخصية: ${personalityController.text.trim()}
نمط الحياة: ${lifestyleController.text.trim()}
الاهتمامات: ${interestsController.text.trim()}
الروائح المفضلة: ${favoriteScentsController.text.trim()}
الروائح غير المفضلة: ${dislikedScentsController.text.trim()}
المزاج والانطباع: ${moodController.text.trim()}
وصف العطر المثالي: ${fragranceDescriptionController.text.trim()}
'''.trim();
}

// ============================================================
// 🧹 تحويل نتيجة NLP إلى List<String>
// ============================================================

List<String> _toStringList(dynamic value) {
if (value is List) {
return value
    .map(
(item) => item.toString(),
)
    .toList();
}

return [];
}

// ============================================================
// 💾 حفظ الهوية العطرية + نتائج NLP
// ============================================================

Future<void> saveFragranceIdentity() async {
if (!_formKey.currentState!.validate()) {
return;
}

final user =
FirebaseAuth.instance.currentUser;

if (user == null) {
_showMessage(
'يجب تسجيل الدخول أولاً',
);

return;
}

setState(() {
isLoading = true;
});

try {
// ========================================================
// 1️⃣ النص الكامل الذي سيدخل إلى NLP
// ========================================================

final combinedText =
buildCombinedText();

// ========================================================
// 2️⃣ مرجع المستخدم
// ========================================================

final userRef = FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid);

// ========================================================
// 3️⃣ حفظ النصوص الأصلية أولاً
// ========================================================

await userRef.set(
{
'gender': gender,

'personalityText':
personalityController.text.trim(),

'lifestyleText':
lifestyleController.text.trim(),

'interestsText':
interestsController.text.trim(),

'favoriteScentsText':
favoriteScentsController.text.trim(),

'dislikedScentsText':
dislikedScentsController.text.trim(),

'moodText':
moodController.text.trim(),

'fragranceDescriptionText':
fragranceDescriptionController.text.trim(),

'nlpAnalysisStatus': 'processing',

'fragranceIdentityCompleted': true,

'updatedAt':
FieldValue.serverTimestamp(),
},
SetOptions(merge: true),
);

// ========================================================
// 4️⃣ إرسال النص إلى FastAPI NLP
// ========================================================

final nlpResult =
await analyzeWithNLP(
combinedText,
);

// ========================================================
// 5️⃣ التأكد من نجاح NLP
// ========================================================

if (nlpResult == null) {
await userRef.set(
{
'nlpAnalysisStatus': 'failed',
},
SetOptions(merge: true),
);

if (!mounted) return;

_showMessage(
'تعذر الاتصال بخدمة NLP. '
'تأكدي أن FastAPI يعمل.',
);

return;
}

// ========================================================
// 6️⃣ استخراج نتائج NLP
// ========================================================

final personality =
_toStringList(
nlpResult['personality'],
);

final mood =
_toStringList(
nlpResult['mood'],
);

final lifestyle =
_toStringList(
nlpResult['lifestyle'],
);

final interests =
_toStringList(
nlpResult['interests'],
);

final preferredNotes =
_toStringList(
nlpResult['preferredNotes'],
);

final dislikedNotes =
_toStringList(
nlpResult['dislikedNotes'],
);

final strength =
nlpResult['strength'];

final usage =
nlpResult['usage'];

final family =
nlpResult['family'];

final season =
nlpResult['season'];

// ========================================================
// 7️⃣ حفظ نتائج NLP في Firestore
// ========================================================

await userRef.set(
{
// -----------------------------------------------
// نتائج NLP
// -----------------------------------------------

'personality': personality,

'mood': mood,

'lifestyle': lifestyle,

'interests': interests,

'preferredNotes': preferredNotes,

'dislikedNotes': dislikedNotes,

'fragranceStrength': strength,

'fragranceUsage': usage,

'fragranceFamily': family,

'season': season,

// -----------------------------------------------
// النص الذي تم تحليله
// -----------------------------------------------

'nlpOriginalText':
nlpResult['originalText'],

'nlpCleanedText':
nlpResult['cleanedText'],

// -----------------------------------------------
// حالة التحليل
// -----------------------------------------------

'nlpAnalysisStatus':
'completed',

'fragranceIdentityCompleted':
true,

'updatedAt':
FieldValue.serverTimestamp(),
},
SetOptions(merge: true),
);

// ========================================================
// 8️⃣ الانتقال إلى نتيجة التحليل
// ========================================================

if (!mounted) return;

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) =>
const AnalysisResultPage(),
),
);
} on FirebaseException catch (e) {
_showMessage(
'حدث خطأ أثناء حفظ البيانات: ${e.message}',
);
} on FormatException {
_showMessage(
'حدث خطأ في قراءة نتيجة NLP.',
);
} catch (e) {
debugPrint(
'saveFragranceIdentity Error: $e',
);

_showMessage(
'حدث خطأ غير متوقع أثناء تحليل الهوية العطرية.',
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

// ============================================================
// 🔔 رسالة
// ============================================================

void _showMessage(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
message,
textDirection: TextDirection.rtl,
),
behavior: SnackBarBehavior.floating,
backgroundColor: espresso,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
margin: const EdgeInsets.all(16),
),
);
}

// ============================================================
// 🧹 Dispose
// ============================================================

@override
void dispose() {
personalityController.dispose();
lifestyleController.dispose();
interestsController.dispose();
favoriteScentsController.dispose();
dislikedScentsController.dispose();
moodController.dispose();
fragranceDescriptionController.dispose();

super.dispose();
}

// ============================================================
// 📝 Modern Text Field
// ============================================================

Widget _buildTextField({
required TextEditingController controller,
required String label,
required String hint,
required IconData icon,
int maxLines = 4,
}) {
return TextFormField(
controller: controller,
maxLines: maxLines,
textDirection: TextDirection.rtl,
textAlign: TextAlign.right,
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'يرجى كتابة إجابتك';
}

return null;
},
decoration: InputDecoration(
labelText: label,
hintText: hint,
labelStyle: const TextStyle(
color: secondaryText,
fontSize: 13,
),
hintStyle: const TextStyle(
color: Color(0xFFAAA097),
fontSize: 12.5,
height: 1.6,
),
prefixIcon: Padding(
padding: const EdgeInsets.only(
left: 8,
right: 10,
),
child: Icon(
icon,
color: warmBrown,
size: 22,
),
),
filled: true,
fillColor: ivory,
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(19),
borderSide: const BorderSide(
color: softChampagne,
width: 1,
),
),
enabledBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(19),
borderSide: const BorderSide(
color: softChampagne,
width: 1,
),
),
focusedBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(19),
borderSide: const BorderSide(
color: champagne,
width: 1.5,
),
),
errorBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(19),
borderSide: const BorderSide(
color: Color(0xFFD7A9A9),
width: 1,
),
),
focusedErrorBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(19),
borderSide: const BorderSide(
color: Color(0xFFD7A9A9),
width: 1.3,
),
),
contentPadding:
const EdgeInsets.fromLTRB(
18,
18,
18,
18,
),
),
);
}

// ============================================================
// 🏷️ Section Header
// ============================================================

Widget _buildSectionHeader({
required String number,
required String title,
required String subtitle,
required IconData icon,
}) {
return Row(
textDirection: TextDirection.rtl,
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: softBrown,
borderRadius:
BorderRadius.circular(15),
border: Border.all(
color: softChampagne,
),
),
child: Icon(
icon,
color: warmBrown,
size: 22,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Row(
mainAxisAlignment:
MainAxisAlignment.end,
children: [
Text(
title,
textAlign: TextAlign.right,
style: const TextStyle(
color: espresso,
fontSize: 17,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(width: 8),
Text(
number,
style: const TextStyle(
color: champagne,
fontSize: 10,
fontWeight:
FontWeight.w800,
letterSpacing: 1.2,
),
),
],
),
const SizedBox(height: 3),
Text(
subtitle,
textAlign: TextAlign.right,
style: const TextStyle(
color: secondaryText,
fontSize: 11,
height: 1.4,
),
),
],
),
),
],
);
}

// ============================================================
// ✦ Top Journey Indicator
// ============================================================

Widget _buildJourneyIndicator() {
return Row(
children: [
_journeyStep(
'01',
'أنت',
true,
),
Expanded(
child: Container(
height: 1,
color: champagne,
),
),
_journeyStep(
'02',
'تفضيلاتك',
false,
),
Expanded(
child: Container(
height: 1,
color: champagne,
),
),
_journeyStep(
'03',
'هويتك',
false,
),
],
);
}

Widget _journeyStep(
String number,
String title,
bool active,
) {
return Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 36,
height: 36,
decoration: BoxDecoration(
shape: BoxShape.circle,
color:
active ? espresso : ivory,
border: Border.all(
color: active
? espresso
    : champagne,
),
),
child: Center(
child: Text(
number,
style: TextStyle(
color: active
? champagne
    : warmBrown,
fontSize: 10,
fontWeight:
FontWeight.w800,
),
),
),
),
const SizedBox(height: 5),
Text(
title,
style: TextStyle(
color: active
? espresso
    : taupe,
fontSize: 9,
fontWeight: active
? FontWeight.w700
    : FontWeight.w500,
),
),
],
);
}

// ============================================================
// 👤 Gender Selector
// ============================================================

Widget _buildGenderSelector() {
return FormField<String>(
validator: (_) {
if (gender == null) {
return 'يرجى اختيار الجنس';
}

return null;
},
builder: (field) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Container(
padding:
const EdgeInsets.all(6),
decoration: BoxDecoration(
color: ivory,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: field.hasError
? const Color(
0xFFD7A9A9,
)
    : softChampagne,
),
),
child: Row(
children: [
Expanded(
child: _genderOption(
value: 'male',
label: 'ذكر',
icon: Icons
    .person_outline_rounded,
),
),
const SizedBox(width: 6),
Expanded(
child: _genderOption(
value: 'female',
label: 'أنثى',
icon: Icons
    .person_outline_rounded,
),
),
],
),
),
if (field.hasError)
Padding(
padding:
const EdgeInsets.only(
top: 7,
right: 12,
),
child: Text(
field.errorText!,
style: const TextStyle(
color:
Color(0xFFB05F5F),
fontSize: 11,
),
),
),
],
);
},
);
}

Widget _genderOption({
required String value,
required String label,
required IconData icon,
}) {
final bool selected =
gender == value;

return GestureDetector(
onTap: () {
setState(() {
gender = value;
});
},
child: AnimatedContainer(
duration:
const Duration(milliseconds: 220),
height: 54,
decoration: BoxDecoration(
color: selected
? espresso
    : backgroundColor,
borderRadius:
BorderRadius.circular(15),
),
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
icon,
size: 19,
color: selected
? champagne
    : warmBrown,
),
const SizedBox(width: 7),
Text(
label,
style: TextStyle(
color: selected
? Colors.white
    : espresso,
fontSize: 13,
fontWeight:
FontWeight.w700,
),
),
],
),
),
);
}

// ============================================================
// ✨ Intro Card
// ============================================================

Widget _buildIntroCard() {
return Container(
padding:
const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient:
const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFF4A3B52),
Color(0xFF66516D),
],
),
borderRadius:
BorderRadius.circular(26),
boxShadow: [
BoxShadow(
color:
espresso.withOpacity(0.16),
blurRadius: 24,
offset:
const Offset(0, 10),
),
],
),
child: Row(
textDirection:
TextDirection.rtl,
children: [
Container(
width: 58,
height: 58,
decoration:
BoxDecoration(
color:
champagne.withOpacity(0.15),
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color:
champagne.withOpacity(0.35),
),
),
child: const Icon(
Icons
    .local_florist_outlined,
color: champagne,
size: 28,
),
),
const SizedBox(width: 14),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Text(
'لنكتشف عطرك معًا',
textAlign:
TextAlign.right,
style: TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
SizedBox(height: 6),
Text(
'أجب بصراحة وبطريقتك الخاصة. '
'إجاباتك ستُحلّل باستخدام NLP لبناء هويتك العطرية.',
textAlign:
TextAlign.right,
style: TextStyle(
color:
Color(0xFFE4D8CE),
fontSize: 11.5,
height: 1.65,
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
// 💾 Saved Profile Choice
// ============================================================

Widget _buildSavedProfileChoice() {
return SingleChildScrollView(
physics:
const BouncingScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
22,
25,
22,
35,
),
child: Column(
children: [
const SizedBox(height: 20),

Center(
child: Container(
width: 105,
height: 105,
padding:
const EdgeInsets.all(13),
decoration: BoxDecoration(
color: ivory,
shape: BoxShape.circle,
border: Border.all(
color: softChampagne,
),
boxShadow: [
BoxShadow(
color:
champagne.withOpacity(0.22),
blurRadius: 25,
offset:
const Offset(0, 8),
),
],
),
child: const AppLogo(
size: 78,
),
),
),

const SizedBox(height: 25),

const Text(
'وجدنا هويتك العطرية السابقة',
textAlign: TextAlign.center,
style: TextStyle(
color: espresso,
fontSize: 23,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 10),

const Text(
'إجاباتك السابقة محفوظة ويمكنك '
'تعديلها أو إنشاء هوية جديدة من البداية.',
textAlign: TextAlign.center,
style: TextStyle(
color: secondaryText,
fontSize: 13,
height: 1.7,
),
),

const SizedBox(height: 32),

// ======================================================
// ✏️ Edit
// ======================================================

SizedBox(
width: double.infinity,
height: 58,
child: ElevatedButton(
onPressed:
editSavedAnswers,
style:
ElevatedButton.styleFrom(
backgroundColor:
espresso,
foregroundColor:
Colors.white,
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
19,
),
),
),
child: const Row(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
Icon(
Icons
    .edit_outlined,
color: champagne,
size: 21,
),
SizedBox(width: 9),
Text(
'تعديل إجاباتي',
style: TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w800,
),
),
],
),
),
),

const SizedBox(height: 14),

// ======================================================
// 🔄 Start Again
// ======================================================

SizedBox(
width: double.infinity,
height: 58,
child: OutlinedButton(
onPressed:
startFromScratch,
style:
OutlinedButton.styleFrom(
foregroundColor:
espresso,
side:
const BorderSide(
color:
softChampagne,
width: 1.2,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
19,
),
),
),
child: const Row(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
Icon(
Icons
    .refresh_rounded,
color: warmBrown,
size: 21,
),
SizedBox(width: 9),
Text(
'ابدأ من جديد',
style: TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w800,
),
),
],
),
),
),

const SizedBox(height: 25),

// ======================================================
// ℹ️ Info
// ======================================================

Container(
padding:
const EdgeInsets.all(15),
decoration:
BoxDecoration(
color: ivory,
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color:
softChampagne,
),
),
child: const Row(
textDirection:
TextDirection.rtl,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons
    .info_outline_rounded,
color: warmBrown,
size: 20,
),
SizedBox(width: 10),
Expanded(
child: Text(
'عند تعديل إجاباتك، سيتم إعادة تحليلها '
'وتحديث هويتك العطرية ونتائج التوصيات.',
textAlign:
TextAlign.right,
style: TextStyle(
color:
secondaryText,
fontSize: 11,
height: 1.6,
),
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
// 📱 Questions Page
// ============================================================

Widget _buildQuestionsPage(
double horizontalPadding,
) {
return Form(
key: _formKey,
child: SingleChildScrollView(
physics:
const BouncingScrollPhysics(),
padding:
EdgeInsets.fromLTRB(
horizontalPadding,
8,
horizontalPadding,
34,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
_buildJourneyIndicator(),

const SizedBox(height: 26),

Center(
child: Container(
width: 96,
height: 96,
padding:
const EdgeInsets.all(12),
decoration: BoxDecoration(
color: ivory,
shape: BoxShape.circle,
border: Border.all(
color: softChampagne,
),
boxShadow: [
BoxShadow(
color:
champagne.withOpacity(0.22),
blurRadius: 24,
offset:
const Offset(0, 8),
),
],
),
child: const AppLogo(
size: 76,
),
),
),

const SizedBox(height: 18),

const Text(
'ابنِ هويتك العطرية',
textAlign: TextAlign.center,
style: TextStyle(
color: espresso,
fontSize: 27,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 8),

const Text(
'كل إجابة منك تساعدنا على فهم ذوقك '
'واكتشاف الشخصية العطرية الأقرب إليك.',
textAlign: TextAlign.center,
style: TextStyle(
color: secondaryText,
fontSize: 13,
height: 1.7,
),
),

const SizedBox(height: 24),

_buildIntroCard(),

const SizedBox(height: 28),

// ==================================================
// 01 — About You
// ==================================================

_buildSectionHeader(
number: '01',
title: 'من أنت؟',
subtitle:
'معلومات تساعدنا على فهمك بشكل أفضل',
icon:
Icons.person_outline_rounded,
),

const SizedBox(height: 14),

_buildGenderSelector(),

const SizedBox(height: 18),

_buildTextField(
controller:
personalityController,
label:
'كيف تصف شخصيتك؟',
hint:
'مثال: أنا شخص هادئ وأحب الأناقة وأميل إلى البساطة...',
icon:
Icons.psychology_outlined,
),

const SizedBox(height: 18),

_buildTextField(
controller:
lifestyleController,
label:
'حدثنا عن نمط حياتك',
hint:
'مثال: أحب الخروج مع الأصدقاء وأقضي وقتًا في العمل والدراسة...',
icon:
Icons.directions_walk_rounded,
),

const SizedBox(height: 18),

_buildTextField(
controller:
interestsController,
label:
'ما الأشياء التي تحبها؟',
hint:
'مثال: السفر، الموسيقى، الطبيعة، القراءة...',
icon:
Icons.interests_outlined,
),

const SizedBox(height: 30),

// ==================================================
// 02 — Preferences
// ==================================================

_buildSectionHeader(
number: '02',
title: 'عالمك العطري',
subtitle:
'الروائح التي تجذبك والتي تفضل الابتعاد عنها',
icon:
Icons.local_florist_outlined,
),

const SizedBox(height: 14),

_buildTextField(
controller:
favoriteScentsController,
label:
'ما الروائح التي تحبها؟',
hint:
'مثال: أحب الورد والفانيلا والروائح الزهرية والناعمة...',
icon:
Icons.favorite_border_rounded,
),

const SizedBox(height: 18),

_buildTextField(
controller:
dislikedScentsController,
label:
'ما الروائح التي لا تحبها؟',
hint:
'مثال: لا أحب الروائح القوية أو الدخانية...',
icon:
Icons.block_outlined,
),

const SizedBox(height: 30),

// ==================================================
// 03 — Fragrance Identity
// ==================================================

_buildSectionHeader(
number: '03',
title: 'هويتك العطرية',
subtitle:
'كيف تريد أن يشعر الآخرون بعطرك؟',
icon:
Icons.auto_awesome_outlined,
),

const SizedBox(height: 14),

_buildTextField(
controller:
moodController,
label:
'كيف تريد أن يعكس عطرك شخصيتك؟',
hint:
'مثال: أريد أن يعكس عطري الهدوء والأناقة والثقة...',
icon:
Icons.mood_outlined,
),

const SizedBox(height: 18),

_buildTextField(
controller:
fragranceDescriptionController,
label:
'صف لنا عطرك المثالي',
hint:
'اكتب بحرية كل ما تتخيله عن عطرك المثالي...',
icon:
Icons.auto_awesome_outlined,
maxLines: 5,
),

const SizedBox(height: 30),

// ==================================================
// NLP Analysis Card
// ==================================================

Container(
padding:
const EdgeInsets.all(16),
decoration:
BoxDecoration(
color: ivory,
borderRadius:
BorderRadius.circular(
20,
),
border: Border.all(
color:
softChampagne,
),
),
child: Row(
textDirection:
TextDirection.rtl,
children: [
Container(
width: 44,
height: 44,
decoration:
BoxDecoration(
color: softBrown,
borderRadius:
BorderRadius.circular(
14,
),
),
child: const Icon(
Icons
    .text_snippet_outlined,
color: warmBrown,
size: 22,
),
),
const SizedBox(
width: 12,
),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .end,
children: [
Text(
'NLP Analysis',
textAlign:
TextAlign.right,
style:
TextStyle(
color:
espresso,
fontSize: 13,
fontWeight:
FontWeight
    .w800,
),
),
SizedBox(
height: 4,
),
Text(
'سيتم تحليل إجاباتك لاستخراج ملامح '
'شخصيتك وتفضيلاتك العطرية.',
textAlign:
TextAlign.right,
style:
TextStyle(
color:
secondaryText,
fontSize:
10.5,
height: 1.5,
),
),
],
),
),
],
),
),

const SizedBox(height: 18),

// ==================================================
// Analyze Button
// ==================================================

SizedBox(
height: 58,
child: ElevatedButton(
onPressed:
isLoading
? null
    : saveFragranceIdentity,
style:
ElevatedButton.styleFrom(
backgroundColor:
espresso,
disabledBackgroundColor:
warmBrown,
foregroundColor:
Colors.white,
disabledForegroundColor:
Colors.white,
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
19,
),
),
),
child: isLoading
? const Row(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
SizedBox(
width: 23,
height: 23,
child:
CircularProgressIndicator(
strokeWidth:
2.4,
color:
champagne,
),
),
SizedBox(
width: 12,
),
Text(
'جاري تحليل هويتك...',
style:
TextStyle(
fontSize:
14,
fontWeight:
FontWeight
    .w700,
),
),
],
)
    : const Row(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
Icon(
Icons
    .auto_awesome_rounded,
color:
champagne,
size: 21,
),
SizedBox(
width: 9,
),
Text(
'حلّل هويتي العطرية',
style:
TextStyle(
fontSize:
16,
fontWeight:
FontWeight
    .w800,
),
),
],
),
),
),

const SizedBox(height: 14),

const Text(
'Fragrance Identity  •  NLP Powered',
textAlign:
TextAlign.center,
style: TextStyle(
color: taupe,
fontSize: 9,
letterSpacing: 1.1,
fontWeight:
FontWeight.w600,
),
),

const SizedBox(height: 8),
],
),
),
);
}

// ============================================================
// 📱 Main Build
// ============================================================

@override
Widget build(BuildContext context) {
final double width =
MediaQuery.of(context).size.width;

final double horizontalPadding =
width < 360 ? 16 : 22;

return Scaffold(
backgroundColor:
backgroundColor,
appBar: AppBar(
backgroundColor:
backgroundColor,
elevation: 0,
scrolledUnderElevation: 0,
centerTitle: true,
title: const Column(
children: [
Text(
'Fragrance Identity',
style: TextStyle(
color: espresso,
fontWeight:
FontWeight.w800,
fontSize: 17,
letterSpacing: 0.2,
),
),
SizedBox(height: 2),
Text(
'هويتي العطرية',
style: TextStyle(
color: warmBrown,
fontSize: 9,
fontWeight:
FontWeight.w600,
letterSpacing: 1.1,
),
),
],
),
iconTheme:
const IconThemeData(
color: espresso,
),
),
body: SafeArea(
child: isProfileLoading
? const Center(
child:
CircularProgressIndicator(
color: champagne,
),
)
    : showQuestions
? _buildQuestionsPage(
horizontalPadding,
)
    : _buildSavedProfileChoice(),
),
);
}
}
