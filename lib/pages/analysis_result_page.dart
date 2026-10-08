import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import 'recommendations_page.dart';
// ============================================================
// 🎨 Fragrance Identity — Pink & Dark Purple Unisex Theme
// ============================================================

const Color backgroundColor = Color(0xFFFCF8FA);
const Color ivory = Color(0xFFFFFCFE);

// البنفسجي الغامق الأساسي
const Color espresso = Color(0xFF302431);
const Color warmBrown = Color(0xFF4A304F);

// الوردي الفاتح
const Color champagne = Color(0xFFD9A9BD);
const Color softChampagne = Color(0xFFEED6E1);

// نصوص
const Color taupe = Color(0xFF9B8795);
const Color secondaryText = Color(0xFF756270);

// خلفيات وردية فاتحة
const Color softBrown = Color(0xFFF5E8EF);
const Color softRose = Color(0xFFF8EDF2);

// ============================================================
// صفحة نتيجة تحليل الهوية العطرية
// ============================================================
//
// Flutter
//    ↓
// FastAPI /analyze
//    ↓
// NLP
//    ↓
// Firestore
//    ↓
// هذه الصفحة
//
// هذه الصفحة تعرض النتائج المحفوظة فقط.
// ============================================================

class AnalysisResultPage extends StatefulWidget {
  const AnalysisResultPage({super.key});

  @override
  State<AnalysisResultPage> createState() =>
      _AnalysisResultPageState();
}

class _AnalysisResultPageState
    extends State<AnalysisResultPage> {
  bool isLoading = true;

  String personalityResult = '';
  String moodResult = '';
  String lifestyleResult = '';

  String fragranceFamilyResult = '';
  String strengthResult = '';
  String usageResult = '';
  String seasonResult = '';

  List<String> interests = [];
  List<String> preferredNotes = [];
  List<String> dislikedNotes = [];

  String originalText = '';
  String cleanedText = '';

  Map<String, dynamic> fragranceProfile = {};

  String? errorMessage;

  // ==========================================================
  // البداية
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadNLPResult();
  }

  // ==========================================================
  // تحميل نتيجة التحليل من Firestore
  // ==========================================================

  Future<void> _loadNLPResult() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'يجب تسجيل الدخول أولاً.';
      });

      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
          'لم يتم العثور على بيانات الهوية العطرية.';
        });

        return;
      }

      final data =
      Map<String, dynamic>.from(doc.data() ?? {});

      // ========================================================
      // التأكد من اكتمال التحليل
      // ========================================================

      final status =
      _stringValue(data['nlpAnalysisStatus']);

      if (status != 'completed') {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
          'لم يكتمل تحليل هويتك العطرية بعد.\n'
              'حالة التحليل: $status';
        });

        return;
      }

      // ========================================================
      // قراءة النتائج
      // ========================================================

      final personality =
      _readStringOrList(data['personality']);

      final mood =
      _readStringOrList(
        data['analysisMood'] ?? data['mood'],
      );

      final lifestyle =
      _readStringOrList(
        data['lifestyleProfile'] ?? data['lifestyle'],
      );

      final family =
      _stringValue(
        data['fragranceFamily'] ??
            data['family'],
      );

      final strength =
      _stringValue(
        data['fragranceStrength'] ??
            data['strength'],
      );

      final usage =
      _stringValue(
        data['fragranceUsage'] ??
            data['usage'],
      );

      final season =
      _stringValue(data['season']);

      final interestsResult =
      _toStringList(data['interests']);

      final preferred =
      _toStringList(
        data['preferredNotes'],
      );

      final disliked =
      _toStringList(
        data['dislikedNotes'],
      );

      final profile =
      _readMap(data['fragranceProfile']);

      final original =
      _stringValue(
        data['nlpOriginalText'],
      );

      final cleaned =
      _stringValue(
        data['nlpCleanedText'],
      );

      if (!mounted) return;

      setState(() {
        personalityResult = personality;
        moodResult = mood;
        lifestyleResult = lifestyle;

        fragranceFamilyResult = family;
        strengthResult = strength;
        usageResult = usage;
        seasonResult = season;

        interests = interestsResult;
        preferredNotes = preferred;
        dislikedNotes = disliked;

        originalText = original;
        cleanedText = cleaned;

        fragranceProfile = profile;

        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Load NLP Result Error: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'حدث خطأ أثناء قراءة نتيجة التحليل.';
      });
    }
  }

  // ==========================================================
  // Helpers
  // ==========================================================

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  String _readStringOrList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where(
            (item) => item.trim().isNotEmpty,
      )
          .join(' • ');
    }

    return _stringValue(value);
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map(
            (item) => item.toString().trim(),
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();
    }

    if (value is String &&
        value.trim().isNotEmpty) {
      return [value.trim()];
    }

    return [];
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  String _profileSummary() {
    final summary =
    _stringValue(
      fragranceProfile['profileSummary'],
    );

    if (summary.isNotEmpty) {
      return summary;
    }

    return '';
  }

  // ==========================================================
  // ✨ Header
  // ==========================================================

  Widget _buildPageHeader() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ivory,
            shape: BoxShape.circle,
            border: Border.all(
              color: softChampagne,
            ),
            boxShadow: [
              BoxShadow(
                color:
                champagne.withOpacity(0.20),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const AppLogo(
            size: 72,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'اكتملت هويتك العطرية',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: espresso,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'اكتشف ملامح شخصيتك العطرية والتفضيلات '
              'الأقرب إلى ذوقك.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: secondaryText,
            fontSize: 13,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // 🌿 Intro Result Card
  // ==========================================================

  Widget _buildIntroResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3F2945),
            Color(0xFF5A3D61),
          ],

        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:
            espresso.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
              champagne.withOpacity(0.14),
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color:
                champagne.withOpacity(0.35),
              ),
            ),
            child: const Icon(
              Icons.local_florist_outlined,
              color: champagne,
              size: 26,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  'هذه هويتك العطرية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'تم تحليل إجاباتك لاكتشاف ملامح '
                      'شخصيتك وتفضيلاتك العطرية، '
                      'ومنها تم بناء ملفك العطري.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFFE4D8CE),
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

  // ==========================================================
  // 📝 Result Card
  // ==========================================================

  Widget _buildResultCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: softChampagne,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
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
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection:
                  TextDirection.rtl,
                  textAlign:
                  TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  textDirection:
                  TextDirection.rtl,
                  textAlign:
                  TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
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

  // ==========================================================
  // 🏷️ Notes / Lists Card
  // ==========================================================

  Widget _buildNotesCard({
    required String title,
    required List<String> notes,
    required IconData icon,
  }) {
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),
      padding:
      const EdgeInsets.all(18),
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
            mainAxisAlignment:
            MainAxisAlignment.end,
            children: [
              Text(
                title,
                textDirection:
                TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: espresso,
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                icon,
                color: warmBrown,
                size: 21,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: notes.map(
                  (note) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: softBrown,
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color: softChampagne,
                    ),
                  ),
                  child: Text(
                    note,
                    textDirection:
                    TextDirection.rtl,
                    style: const TextStyle(
                      color: espresso,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 🌸 Fragrance Profile
  // ==========================================================

  Widget _buildProfileCard() {
    final summary = _profileSummary();

    if (summary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(bottom: 14),
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5E5ED),
            Color(0xFFF1E5F3),
          ],
        ),
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color:
          champagne.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.end,
            children: [
              const Text(
                'ملفك العطري',
                textDirection:
                TextDirection.rtl,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: espresso,
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.auto_awesome_outlined,
                color: warmBrown,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'ملخص يجمع أبرز ملامح شخصيتك وتفضيلاتك العطرية.',
            textDirection:
            TextDirection.rtl,
            textAlign:
            TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              color: taupe,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            summary,
            textDirection:
            TextDirection.rtl,
            textAlign:
            TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 🧠 معلومات عن طريقة التحليل
  // ==========================================================

  // ==========================================================
// 🧾 معلومات عن النتيجة
// ==========================================================

  Widget _buildNLPInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: softBrown,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: warmBrown,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'كيف تم بناء هويتك؟',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: espresso,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'تمت قراءة إجاباتك واستخراج أبرز ملامح '
                      'شخصيتك وتفضيلاتك العطرية، ثم جمعها '
                      'في ملف عطري يعكس ذوقك واحتياجاتك.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
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

  // ==========================================================
  // ❌ Error View
  // ==========================================================

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: softBrown,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: warmBrown,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              errorMessage ??
                  'لم يتم العثور على نتيجة التحليل.',
              textDirection:
              TextDirection.rtl,
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: espresso,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed:
              _loadNLPResult,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
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
                  BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // الصفحة
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Column(
          children: [
            Text(
              'Fragrance Identity',
              style: TextStyle(
                color: espresso,
                fontWeight: FontWeight.w800,
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
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(
          color: warmBrown,
        ),
      )
          : errorMessage != null
          ? _buildErrorView()
          : RefreshIndicator(
        color: warmBrown,
        onRefresh:
        _loadNLPResult,
        child:
        SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            34,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // Header
              // ==================================================

              _buildPageHeader(),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // Intro
              // ==================================================

              _buildIntroResultCard(),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // Section title
              // ==================================================

              Row(
                textDirection:
                TextDirection.rtl,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration:
                    BoxDecoration(
                      color:
                      softBrown,
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                      border:
                      Border.all(
                        color:
                        softChampagne,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .person_outline_rounded,
                      color:
                      warmBrown,
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                      children: [
                        Text(
                          'ملامح هويتك',
                          textDirection:
                          TextDirection
                              .rtl,
                          textAlign:
                          TextAlign
                              .right,
                          style:
                          TextStyle(
                            color:
                            espresso,
                            fontSize:
                            18,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          'أبرز النتائج المستخرجة من إجاباتك',
                          textDirection:
                          TextDirection
                              .rtl,
                          textAlign:
                          TextAlign
                              .right,
                          style:
                          TextStyle(
                            color:
                            secondaryText,
                            fontSize:
                            10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // Results
              // ==================================================

              _buildResultCard(
                icon: Icons
                    .psychology_outlined,
                title:
                'ملامح شخصيتك',
                value:
                personalityResult,
              ),

              _buildResultCard(
                icon: Icons
                    .mood_outlined,
                title:
                'المزاج الذي يعكسه عطرك',
                value:
                moodResult,
              ),

              _buildResultCard(
                icon: Icons
                    .emoji_people_outlined,
                title:
                'نمط حياتك',
                value:
                lifestyleResult,
              ),

              _buildResultCard(
                icon: Icons
                    .local_florist_outlined,
                title:
                'العائلة العطرية الأقرب إليك',
                value:
                fragranceFamilyResult,
              ),

              _buildResultCard(
                icon: Icons
                    .water_drop_outlined,
                title:
                'قوة العطر المناسبة',
                value:
                strengthResult,
              ),

              _buildResultCard(
                icon: Icons
                    .calendar_month_outlined,
                title:
                'الاستخدام المناسب',
                value:
                usageResult,
              ),

              _buildResultCard(
                icon: Icons
                    .wb_sunny_outlined,
                title:
                'الموسم المناسب',
                value:
                seasonResult,
              ),

              // ==================================================
              // Interests
              // ==================================================

              _buildNotesCard(
                title:
                'اهتماماتك',
                notes:
                interests,
                icon: Icons
                    .interests_outlined,
              ),

              // ==================================================
              // Preferred Notes
              // ==================================================

              _buildNotesCard(
                title:
                'الروائح التي تناسب ذوقك',
                notes:
                preferredNotes,
                icon: Icons
                    .favorite_border_rounded,
              ),

              // ==================================================
              // Disliked Notes
              // ==================================================

              _buildNotesCard(
                title:
                'الروائح التي تفضل تجنبها',
                notes:
                dislikedNotes,
                icon: Icons
                    .block_outlined,
              ),

              // ==================================================
              // Fragrance Profile
              // ==================================================

              _buildProfileCard(),

              // ==================================================
              // NLP Info
              // ==================================================

              _buildNLPInfoCard(),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // Recommendations
              // ==================================================

              Container(
                padding:
                const EdgeInsets.all(
                  18,
                ),
                decoration:
                BoxDecoration(
                  color: ivory,
                  borderRadius:
                  BorderRadius
                      .circular(
                    22,
                  ),
                  border:
                  Border.all(
                    color:
                    softChampagne,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration:
                      BoxDecoration(
                        color:
                        softBrown,
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons
                            .local_florist_outlined,
                        color:
                        warmBrown,
                        size: 27,
                      ),
                    ),

                    const SizedBox(
                      height: 11,
                    ),

                    const Text(
                      'جاهز لاكتشاف عطرك؟',
                      textDirection:
                      TextDirection
                          .rtl,
                      textAlign:
                      TextAlign.center,
                      style:
                      TextStyle(
                        color:
                        espresso,
                        fontSize:
                        17,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Text(
                      'سنستخدم هويتك العطرية للعثور على '
                          'العطور الأكثر توافقًا مع ذوقك.',
                      textDirection:
                      TextDirection
                          .rtl,
                      textAlign:
                      TextAlign.center,
                      style:
                      TextStyle(
                        color:
                        secondaryText,
                        fontSize:
                        11,
                        height:
                        1.5,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      height: 54,
                      child:
                      ElevatedButton
                          .icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                              const RecommendationsPage(),
                            ),
                          );
                        },
                        icon:
                        const Icon(
                          Icons
                              .arrow_back_rounded,
                          size: 20,
                        ),
                        label:
                        const Text(
                          'اكتشف عطرك المثالي',
                          style:
                          TextStyle(
                            fontSize:
                            15,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          espresso,
                          foregroundColor:
                          Colors.white,
                          elevation:
                          0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // Edit
              // ==================================================

              TextButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                icon:
                const Icon(
                  Icons
                      .edit_outlined,
                  color:
                  warmBrown,
                  size: 18,
                ),
                label:
                const Text(
                  'تعديل إجاباتي',
                  style:
                  TextStyle(
                    color:
                    warmBrown,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Fragrance Identity  •  Personalized Profile',
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  color: taupe,
                  fontSize: 9,
                  letterSpacing:
                  1.0,
                  fontWeight:
                  FontWeight
                      .w600,
                ),
              ),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}