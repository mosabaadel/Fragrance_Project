import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() =>
      _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Map<String, dynamic>? userData;

  Map<String, dynamic> fragranceProfile = {};

  List<Map<String, dynamic>> recommendations = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  // ============================================================
  // تحميل البيانات وبناء التوصية
  // ============================================================

  Future<void> _loadRecommendations() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage = 'لم يتم العثور على المستخدم.';
        });

        return;
      }

      // ==========================================================
      // 1. قراءة بيانات المستخدم من Firestore
      // ==========================================================

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
          'لم يتم العثور على بيانات هويتك العطرية.';
        });

        return;
      }

      final currentUserData =
      Map<String, dynamic>.from(
        userDoc.data() ?? {},
      );

      // ==========================================================
      // 2. بناء Fragrance Profile
      // ==========================================================

      final profile =
      _buildFragranceProfile(currentUserData);

      // ==========================================================
      // 3. قراءة تفاعلات المستخدم
      // ==========================================================

      final interactionsSnapshot =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('interactions')
          .get();

      final Map<String, String> previousInteractions = {};

      for (final doc in interactionsSnapshot.docs) {
        final data = doc.data();

        final action =
        _stringValue(data['action']);

        if (action.isNotEmpty) {
          previousInteractions[doc.id] = action;
        }
      }

      // ==========================================================
      // 4. قراءة جميع العطور من Firestore
      // ==========================================================

      final perfumesSnapshot =
      await _firestore
          .collection('perfumes')
          .get();

      if (perfumesSnapshot.docs.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
          'لا توجد عطور في قاعدة البيانات الرئيسية.';
        });

        return;
      }

      // ==========================================================
      // 5. حساب Compatibility Score لكل العطور
      // ==========================================================

      final List<Map<String, dynamic>>
      calculatedRecommendations = [];

      for (final doc in perfumesSnapshot.docs) {
        final perfume =
        Map<String, dynamic>.from(
          doc.data(),
        );

        perfume['documentId'] = doc.id;

        // --------------------------------------------------------
        // حساب الدرجة الأساسية
        // --------------------------------------------------------

        final breakdown =
        _calculateCompatibilityBreakdown(
          profile,
          currentUserData,
          perfume,
        );

        final baseScore =
        breakdown['total'] as double;

        // --------------------------------------------------------
        // Interaction Adjustment
        // liked     +5
        // favorite  +7
        // purchased +8
        // disliked  -10
        // --------------------------------------------------------

        final interaction =
        previousInteractions[doc.id];

        final adjustment =
        _interactionAdjustment(
          interaction,
        );

        final finalScore =
        (baseScore + adjustment)
            .clamp(0, 100)
            .toDouble();

        perfume['compatibilityScore'] =
            finalScore;

        perfume['baseScore'] =
            baseScore;

        perfume['interactionAdjustment'] =
            adjustment;

        perfume['scoreBreakdown'] =
            breakdown;

        calculatedRecommendations.add(
          perfume,
        );
      }

      // ==========================================================
      // 6. ترتيب جميع العطور من الأعلى إلى الأقل
      // ==========================================================

      calculatedRecommendations.sort(
            (a, b) {
          final scoreA =
          _toDouble(
            a['compatibilityScore'],
          );

          final scoreB =
          _toDouble(
            b['compatibilityScore'],
          );

          return scoreB.compareTo(scoreA);
        },
      );

      // ==========================================================
      // 7. اختيار عدة عطور مرتبة حسب درجة التوافق
      // ==========================================================


      const int recommendationLimit = 5;

      final List<Map<String, dynamic>>
      selectedRecommendation =
      calculatedRecommendations
          .take(recommendationLimit)
          .toList();

      // ==========================================================
      // 8. حفظ سجل التوصية
      // ==========================================================

      await _saveRecommendationHistory(
        user.uid,
        selectedRecommendation,
        profile,
      );

      if (!mounted) return;

      setState(() {
        userData = currentUserData;

        fragranceProfile = profile;

        recommendations =
            selectedRecommendation;

        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Recommendations Error: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'حدث خطأ أثناء تحليل العطور.';
      });
    }
  }

  // ============================================================
  // بناء Fragrance Profile
  // ============================================================

  Map<String, dynamic> _buildFragranceProfile(
      Map<String, dynamic> user) {
    final personality =
    _analyzePersonality(user);

    final mood =
    _analyzeMood(user);

    final lifestyle =
    _analyzeLifestyle(user);

    final interests =
    _analyzeInterests(user);

    final preferredNotes =
    _getPreferredNotes(user);

    final dislikedNotes =
    _getDislikedNotes(user);

    final family =
    _stringValue(
      user['fragranceFamily'],
    );

    final strength =
    _stringValue(
      user['fragranceStrength'],
    );

    final usage =
    _stringValue(
      user['fragranceUsage'],
    );

    final occasions =
    _getUserOccasion(user);

    final seasons =
    _getUserSeason(user);

    // دعم نتائج NLP المستقبلية
    final nlpTraits =
    _getStringList(
      user['nlpTraits'],
    );

    final extractedTraits =
    _getStringList(
      user['extractedTraits'],
    );

    final personalityTraits =
    _getStringList(
      user['personalityTraits'],
    );

    final detectedTraits =
    _getStringList(
      user['detectedTraits'],
    );

    final nlpMoods =
    _getStringList(
      user['nlpMoods'],
    );

    final extractedMoods =
    _getStringList(
      user['extractedMoods'],
    );

    final nlpNotes =
    _getStringList(
      user['nlpNotes'],
    );

    return {
      'personality': _mergeLists([
        personality,
        nlpTraits,
        extractedTraits,
        personalityTraits,
        detectedTraits,
      ]),
      'mood': _mergeLists([
        mood,
        nlpMoods,
        extractedMoods,
      ]),
      'lifestyle': lifestyle,
      'interests': interests,
      'family': family,
      'strength': strength,
      'usage': usage,
      'preferredNotes': _mergeLists([
        preferredNotes,
        nlpNotes,
      ]),
      'dislikedNotes': dislikedNotes,
      'occasions': occasions,
      'seasons': seasons,
    };
  }

  // ============================================================
  // تحليل الشخصية
  // ============================================================

  List<String> _analyzePersonality(
      Map<String, dynamic> user) {
    final text =
    _normalizeText(
      [
        user['personality'],
        user['personalityText'],
      ]
          .where(
            (value) =>
        value != null &&
            value.toString().trim().isNotEmpty,
      )
          .map(
            (value) => value.toString(),
      )
          .join(' '),
    );

    final traits = <String>[];

    final groups =
    <String, List<String>>{
      'هادئة': [
        'هادئ',
        'هادئة',
        'هدوء',
        'calm',
        'peaceful',
      ],
      'ناعمة': [
        'ناعم',
        'ناعمة',
        'رقيق',
        'رقيقة',
        'soft',
        'gentle',
      ],
      'أنيقة': [
        'أنيق',
        'أنيقة',
        'راقي',
        'راقية',
        'elegant',
        'classy',
      ],
      'اجتماعية': [
        'اجتماعي',
        'اجتماعية',
        'social',
        'friends',
      ],
      'مرحة': [
        'مرح',
        'مرحة',
        'مبهج',
        'happy',
        'cheerful',
        'fun',
      ],
      'جريئة': [
        'جريء',
        'جريئة',
        'bold',
        'confident',
      ],
      'عملية': [
        'عملي',
        'عملية',
        'practical',
      ],
      'رومانسية': [
        'رومانسي',
        'رومانسية',
        'romantic',
      ],
    };

    groups.forEach(
          (trait, keywords) {
        if (_containsAnyKeyword(
          text,
          keywords,
        )) {
          traits.add(trait);
        }
      },
    );

    return traits;
  }

  // ============================================================
  // تحليل المزاج
  // ============================================================

  List<String> _analyzeMood(
      Map<String, dynamic> user) {
    final text =
    _normalizeText(
      [
        user['moodText'],
        user['fragranceDescriptionText'],
      ]
          .where(
            (value) =>
        value != null &&
            value.toString().trim().isNotEmpty,
      )
          .map(
            (value) => value.toString(),
      )
          .join(' '),
    );

    final moods = <String>[];

    final groups =
    <String, List<String>>{
      'هدوء': [
        'هادئ',
        'هادئة',
        'هدوء',
        'راحة',
        'مريح',
        'calm',
        'relax',
        'peaceful',
      ],
      'انتعاش': [
        'منعش',
        'انتعاش',
        'بارد',
        'fresh',
        'cool',
        'refreshing',
      ],
      'دفء': [
        'دافئ',
        'دفء',
        'warm',
        'cozy',
      ],
      'رومانسية': [
        'رومانسي',
        'رومانسية',
        'حب',
        'romantic',
        'love',
      ],
      'فخامة': [
        'فاخر',
        'فخامة',
        'راقي',
        'luxury',
        'luxurious',
      ],
      'حيوية': [
        'حيوي',
        'حيوية',
        'نشاط',
        'نشطة',
        'energetic',
        'active',
      ],
    };

    groups.forEach(
          (mood, keywords) {
        if (_containsAnyKeyword(
          text,
          keywords,
        )) {
          moods.add(mood);
        }
      },
    );

    return moods;
  }

  // ============================================================
  // تحليل نمط الحياة
  // ============================================================

  List<String> _analyzeLifestyle(
      Map<String, dynamic> user) {
    final text =
    _normalizeText(
      [
        user['lifestyleText'],
        user['fragranceUsage'],
        user['fragranceDescriptionText'],
      ]
          .where(
            (value) =>
        value != null &&
            value.toString().trim().isNotEmpty,
      )
          .map(
            (value) => value.toString(),
      )
          .join(' '),
    );

    final lifestyle = <String>[];

    final groups =
    <String, List<String>>{
      'الدراسة': [
        'دراسة',
        'دراسه',
        'جامعة',
        'جامعه',
        'مدرسة',
        'school',
        'study',
      ],
      'العمل': [
        'عمل',
        'العمل',
        'وظيفة',
        'وظيفه',
        'office',
        'work',
      ],
      'الطلعات': [
        'طلعات',
        'طلعة',
        'خروج',
        'خروجات',
        'outing',
        'casual',
      ],
      'الاستخدام اليومي': [
        'يومي',
        'يومية',
        'يوميه',
        'daily',
        'everyday',
      ],
      'المناسبات': [
        'حفلة',
        'حفلات',
        'سهرة',
        'مناسبة',
        'party',
        'event',
      ],
    };

    groups.forEach(
          (category, keywords) {
        if (_containsAnyKeyword(
          text,
          keywords,
        )) {
          lifestyle.add(category);
        }
      },
    );

    return lifestyle;
  }

  // ============================================================
  // تحليل الاهتمامات
  // ============================================================

  List<String> _analyzeInterests(
      Map<String, dynamic> user) {
    final text =
    _normalizeText(
      _stringValue(
        user['interestsText'],
      ),
    );

    if (text.isEmpty) {
      return [];
    }

    final interests = <String>[];

    final groups =
    <String, List<String>>{
      'القراءة': [
        'قراءة',
        'قراءه',
        'كتب',
        'كتاب',
        'reading',
        'books',
      ],
      'الموسيقى': [
        'موسيقى',
        'اغاني',
        'أغاني',
        'music',
        'songs',
      ],
      'السفر': [
        'سفر',
        'سياحة',
        'رحلات',
        'travel',
      ],
      'التصوير': [
        'تصوير',
        'صور',
        'photography',
      ],
      'الرياضة': [
        'رياضة',
        'رياضه',
        'sport',
        'fitness',
      ],
      'الفن': [
        'فن',
        'رسم',
        'art',
        'drawing',
      ],
    };

    groups.forEach(
          (interest, keywords) {
        if (_containsAnyKeyword(
          text,
          keywords,
        )) {
          interests.add(interest);
        }
      },
    );

    return interests;
  }

  // ============================================================
  // حساب Compatibility Breakdown
  // ============================================================

  Map<String, dynamic>
  _calculateCompatibilityBreakdown(
      Map<String, dynamic> profile,
      Map<String, dynamic> user,
      Map<String, dynamic> perfume,
      ) {
    // ------------------------------------------------------------
    // العائلة 20%
    // ------------------------------------------------------------

    final familyScore =
    _familyCompatibility(
      _stringValue(profile['family']),
      _stringValue(perfume['family']),
    );

    // ------------------------------------------------------------
    // النوتات 20%
    // ------------------------------------------------------------

    final preferredNotes =
    List<String>.from(
      profile['preferredNotes'] ?? [],
    );

    final perfumeNotes =
    _getNotesList(
      perfume['notes'],
    );

    final noteScore =
    _noteCompatibility(
      preferredNotes,
      perfumeNotes,
    );

    // ------------------------------------------------------------
    // القوة 15%
    // ------------------------------------------------------------

    final strengthScore =
    _strengthCompatibility(
      _stringValue(profile['strength']),
      _stringValue(perfume['strength']),
    );

    // ------------------------------------------------------------
    // الاستخدام 10%
    // ------------------------------------------------------------

    final usageScore =
    _usageCompatibility(
      _stringValue(profile['usage']),
      _stringValue(perfume['usage']),
    );

    // ------------------------------------------------------------
    // المناسبة 10%
    // ------------------------------------------------------------

    final occasionScore =
    _occasionCompatibility(
      List<String>.from(
        profile['occasions'] ?? [],
      ),
      _getStringList(
        perfume['occasion'],
      ),
    );

    // ------------------------------------------------------------
    // الموسم 5%
    // ------------------------------------------------------------

    final seasonScore =
    _seasonCompatibility(
      List<String>.from(
        profile['seasons'] ?? [],
      ),
      _getStringList(
        perfume['season'],
      ),
    );

    // ------------------------------------------------------------
    // الشخصية / المزاج / نمط الحياة / الاهتمامات 20%
    // ------------------------------------------------------------

    final profileScore =
    _profileCompatibility(
      profile,
      user,
      perfume,
    );

    // ------------------------------------------------------------
    // النوتات غير المرغوبة
    // ------------------------------------------------------------

    final dislikedNotes =
    List<String>.from(
      profile['dislikedNotes'] ?? [],
    );

    final dislikedMatches =
    _countNoteMatches(
      dislikedNotes,
      perfumeNotes,
    );

    final dislikedPenalty =
    dislikedMatches > 0
        ? (dislikedMatches * 8)
        .clamp(0, 20)
        .toDouble()
        : 0.0;

    // ------------------------------------------------------------
    // المجموع
    // ------------------------------------------------------------

    final total =
    (familyScore +
        noteScore +
        strengthScore +
        usageScore +
        occasionScore +
        seasonScore +
        profileScore -
        dislikedPenalty)
        .clamp(0, 100)
        .toDouble();

    return {
      'family': familyScore,
      'notes': noteScore,
      'strength': strengthScore,
      'usage': usageScore,
      'occasion': occasionScore,
      'season': seasonScore,
      'profile': profileScore,
      'dislikedPenalty': dislikedPenalty,
      'total': total,
    };
  }

  // ============================================================
  // توافق العائلة
  // ============================================================

  double _familyCompatibility(
      String userFamily,
      String perfumeFamily,
      ) {
    if (userFamily.trim().isEmpty ||
        perfumeFamily.trim().isEmpty) {
      return 0;
    }

    final user =
    _normalizeText(userFamily);

    final perfume =
    _normalizeText(perfumeFamily);

    final families =
    <List<String>>[
      [
        'زهري',
        'floral',
        'ورد',
        'rose',
      ],
      [
        'شرقي',
        'oriental',
        'amber',
        'عنبر',
      ],
      [
        'خشبي',
        'woody',
        'خشب',
      ],
      [
        'حمضي',
        'حمضيات',
        'citrus',
      ],
      [
        'فواكه',
        'فواكهي',
        'fruity',
      ],
      [
        'منعش',
        'fresh',
      ],
      [
        'مسكي',
        'musk',
        'مسك',
      ],
      [
        'حلو',
        'sweet',
        'gourmand',
      ],
    ];

    for (final family in families) {
      final userHas =
      family.any(
            (word) => user.contains(
          _normalizeText(word),
        ),
      );

      final perfumeHas =
      family.any(
            (word) => perfume.contains(
          _normalizeText(word),
        ),
      );

      if (userHas && perfumeHas) {
        return 20;
      }
    }

    if (_containsSimilarWord(
      user,
      perfume,
    )) {
      return 12;
    }

    return 0;
  }

  // ============================================================
  // توافق النوتات
  // ============================================================

  double _noteCompatibility(
      List<String> preferredNotes,
      List<String> perfumeNotes,
      ) {
    if (preferredNotes.isEmpty ||
        perfumeNotes.isEmpty) {
      return 0;
    }

    final matches =
    _countNoteMatches(
      preferredNotes,
      perfumeNotes,
    );

    if (matches == 0) {
      return 0;
    }

    final ratio =
        matches / preferredNotes.length;

    return (ratio * 20)
        .clamp(0, 20)
        .toDouble();
  }

  // ============================================================
  // توافق القوة
  // ============================================================

  double _strengthCompatibility(
      String userStrength,
      String perfumeStrength,
      ) {
    if (userStrength.trim().isEmpty ||
        perfumeStrength.trim().isEmpty) {
      return 0;
    }

    final user =
    _normalizeText(userStrength);

    final perfume =
    _normalizeText(perfumeStrength);

    final userLight =
        user.contains('خفيف') ||
            user.contains('ناعم') ||
            user.contains('soft') ||
            user.contains('light');

    final perfumeLight =
        perfume.contains('خفيف') ||
            perfume.contains('ناعم') ||
            perfume.contains('soft') ||
            perfume.contains('light');

    if (userLight && perfumeLight) {
      return 15;
    }

    final userMedium =
        user.contains('متوسط') ||
            user.contains('medium');

    final perfumeMedium =
        perfume.contains('متوسط') ||
            perfume.contains('medium');

    if (userMedium && perfumeMedium) {
      return 15;
    }

    final userStrong =
        user.contains('قوي') ||
            user.contains('فواح') ||
            user.contains('strong') ||
            user.contains('intense');

    final perfumeStrong =
        perfume.contains('قوي') ||
            perfume.contains('فواح') ||
            perfume.contains('strong') ||
            perfume.contains('intense');

    if (userStrong && perfumeStrong) {
      return 15;
    }

    // توافق جزئي
    if ((userLight && perfumeMedium) ||
        (userMedium && perfumeLight)) {
      return 7;
    }

    if ((userStrong && perfumeMedium) ||
        (userMedium && perfumeStrong)) {
      return 7;
    }

    return 0;
  }

  // ============================================================
  // توافق الاستخدام
  // ============================================================

  double _usageCompatibility(
      String userUsage,
      String perfumeUsage,
      ) {
    if (userUsage.trim().isEmpty ||
        perfumeUsage.trim().isEmpty) {
      return 0;
    }

    final user =
    _normalizeText(userUsage);

    final perfume =
    _normalizeText(perfumeUsage);

    final userDay =
        user.contains('عمل') ||
            user.contains('دراسة') ||
            user.contains('يومي') ||
            user.contains('يومية') ||
            user.contains('daily') ||
            user.contains('work');

    final perfumeDay =
        perfume.contains('عمل') ||
            perfume.contains('دراسة') ||
            perfume.contains('يومي') ||
            perfume.contains('يومية') ||
            perfume.contains('daily') ||
            perfume.contains('work');

    if (userDay && perfumeDay) {
      return 10;
    }

    final userEvening =
        user.contains('مساء') ||
            user.contains('سهرة') ||
            user.contains('ليل') ||
            user.contains('evening') ||
            user.contains('night');

    final perfumeEvening =
        perfume.contains('مساء') ||
            perfume.contains('سهرة') ||
            perfume.contains('ليل') ||
            perfume.contains('evening') ||
            perfume.contains('night');

    if (userEvening && perfumeEvening) {
      return 10;
    }

    return 0;
  }

  // ============================================================
  // توافق المناسبة
  // ============================================================

  double _occasionCompatibility(
      List<String> userOccasions,
      List<String> perfumeOccasions,
      ) {
    if (userOccasions.isEmpty ||
        perfumeOccasions.isEmpty) {
      return 0;
    }

    final userText =
    _normalizeText(
      userOccasions.join(' '),
    );

    final perfumeText =
    _normalizeText(
      perfumeOccasions.join(' '),
    );

    final groups =
    <List<String>>[
      [
        'عمل',
        'دراسة',
        'daily',
        'work',
        'يومي',
      ],
      [
        'طلعات',
        'خروج',
        'casual',
      ],
      [
        'سهرة',
        'حفلة',
        'party',
        'evening',
      ],
      [
        'رومانسي',
        'موعد',
        'date',
        'romantic',
      ],
      [
        'رسمي',
        'formal',
      ],
    ];

    for (final group in groups) {
      final userHas =
      group.any(
            (word) => userText.contains(
          _normalizeText(word),
        ),
      );

      final perfumeHas =
      group.any(
            (word) => perfumeText.contains(
          _normalizeText(word),
        ),
      );

      if (userHas && perfumeHas) {
        return 10;
      }
    }

    return 0;
  }

  // ============================================================
  // توافق الموسم
  // ============================================================

  double _seasonCompatibility(
      List<String> userSeasons,
      List<String> perfumeSeasons,
      ) {
    if (userSeasons.isEmpty ||
        perfumeSeasons.isEmpty) {
      return 0;
    }

    final userText =
    _normalizeText(
      userSeasons.join(' '),
    );

    final perfumeText =
    _normalizeText(
      perfumeSeasons.join(' '),
    );

    final groups =
    <List<String>>[
      [
        'صيف',
        'summer',
        'حار',
      ],
      [
        'شتاء',
        'winter',
        'بارد',
      ],
      [
        'ربيع',
        'spring',
      ],
      [
        'خريف',
        'autumn',
        'fall',
      ],
    ];

    for (final group in groups) {
      final userHas =
      group.any(
            (word) => userText.contains(
          _normalizeText(word),
        ),
      );

      final perfumeHas =
      group.any(
            (word) => perfumeText.contains(
          _normalizeText(word),
        ),
      );

      if (userHas && perfumeHas) {
        return 5;
      }
    }

    return 0;
  }

  // ============================================================
  // Fragrance Profile = 20%
  //
  // الشخصية 5%
  // المزاج 5%
  // نمط الحياة 5%
  // الاهتمامات 5%
  // ============================================================

  double _profileCompatibility(
      Map<String, dynamic> profile,
      Map<String, dynamic> user,
      Map<String, dynamic> perfume,
      ) {
    final perfumeText =
    _normalizeText(
      [
        perfume['name'],
        perfume['brand'],
        perfume['description'],
        perfume['notes'],
        perfume['family'],
        perfume['strength'],
        perfume['usage'],
        perfume['occasion'],
        perfume['season'],
      ]
          .where(
            (value) =>
        value != null &&
            value.toString().trim().isNotEmpty,
      )
          .map(
            (value) => value.toString(),
      )
          .join(' '),
    );

    if (perfumeText.isEmpty) {
      return 0;
    }

    double score = 0;

    // الشخصية
    final personality =
    List<String>.from(
      profile['personality'] ?? [],
    );

    if (_profileConceptMatch(
      personality,
      perfumeText,
    )) {
      score += 5;
    }

    // المزاج
    final mood =
    List<String>.from(
      profile['mood'] ?? [],
    );

    if (_profileConceptMatch(
      mood,
      perfumeText,
    )) {
      score += 5;
    }

    // نمط الحياة
    final lifestyle =
    List<String>.from(
      profile['lifestyle'] ?? [],
    );

    if (_profileConceptMatch(
      lifestyle,
      perfumeText,
    )) {
      score += 5;
    }

    // الاهتمامات
    final interests =
    List<String>.from(
      profile['interests'] ?? [],
    );

    if (_profileConceptMatch(
      interests,
      perfumeText,
    )) {
      score += 5;
    }

    return score.clamp(0, 20).toDouble();
  }

  // ============================================================
  // مطابقة مفهوم Profile
  // ============================================================

  bool _profileConceptMatch(
      List<String> profileValues,
      String perfumeText,
      ) {
    if (profileValues.isEmpty ||
        perfumeText.isEmpty) {
      return false;
    }

    final profileText =
    _normalizeText(
      profileValues.join(' '),
    );

    final conceptGroups =
    <List<String>>[
      [
        'هادئ',
        'هدوء',
        'ناعم',
        'رقيق',
        'soft',
        'calm',
        'gentle',
        'peaceful',
      ],
      [
        'أنيق',
        'انيق',
        'راقي',
        'فخم',
        'elegant',
        'classy',
        'luxury',
      ],
      [
        'منعش',
        'انتعاش',
        'بارد',
        'fresh',
        'cool',
        'refreshing',
      ],
      [
        'رومانسي',
        'رومانسية',
        'حب',
        'romantic',
        'love',
      ],
      [
        'دافئ',
        'دفء',
        'warm',
        'cozy',
      ],
      [
        'حلو',
        'حلوة',
        'فانيلا',
        'فانيليا',
        'vanilla',
        'sweet',
      ],
      [
        'زهري',
        'ورد',
        'ياسمين',
        'floral',
        'rose',
        'jasmine',
      ],
      [
        'نظيف',
        'نظافة',
        'clean',
      ],
      [
        'دراسة',
        'عمل',
        'يومي',
        'daily',
        'work',
        'study',
      ],
      [
        'طلعات',
        'خروج',
        'outing',
        'casual',
      ],
    ];

    for (final group in conceptGroups) {
      final profileHas =
      group.any(
            (word) => profileText.contains(
          _normalizeText(word),
        ),
      );

      final perfumeHas =
      group.any(
            (word) => perfumeText.contains(
          _normalizeText(word),
        ),
      );

      if (profileHas && perfumeHas) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // استخراج النوتات المفضلة
  // ============================================================

  List<String> _getPreferredNotes(
      Map<String, dynamic> user) {
    final result = <String>[];

    result.addAll(
      _getStringList(
        user['preferredNotes'],
      ),
    );

    result.addAll(
      _getStringList(
        user['nlpNotes'],
      ),
    );

    final favoriteText =
    _stringValue(
      user['favoriteScentsText'],
    );

    if (favoriteText.isNotEmpty) {
      result.addAll(
        _extractKnownNotes(
          favoriteText,
        ),
      );
    }

    return result
        .where(
          (item) =>
      item.trim().isNotEmpty,
    )
        .toSet()
        .toList();
  }

  // ============================================================
  // استخراج النوتات غير المرغوبة
  // ============================================================

  List<String> _getDislikedNotes(
      Map<String, dynamic> user) {
    final result = <String>[];

    result.addAll(
      _getStringList(
        user['dislikedNotes'],
      ),
    );

    final dislikedText =
    _stringValue(
      user['dislikedScentsText'],
    );

    if (dislikedText.isNotEmpty) {
      result.addAll(
        _extractKnownNotes(
          dislikedText,
        ),
      );

      final normalized =
      _normalizeText(
        dislikedText,
      );

      if (_containsAnyKeyword(
        normalized,
        [
          'قوي',
          'فواح',
          'strong',
          'intense',
        ],
      )) {
        result.add('قوي');
      }
    }

    return result
        .where(
          (item) =>
      item.trim().isNotEmpty,
    )
        .toSet()
        .toList();
  }

  // ============================================================
  // استخراج النوتات من النص
  // ============================================================

  List<String> _extractKnownNotes(
      String text) {
    final normalized =
    _normalizeText(text);

    const knownNotes = <String>[
      'ورد',
      'rose',
      'فانيلا',
      'فانيليا',
      'vanilla',
      'ياسمين',
      'jasmine',
      'فراولة',
      'strawberry',
      'مسك',
      'musk',
      'بنفسج',
      'violet',
      'حمضيات',
      'citrus',
      'ليمون',
      'lemon',
      'برتقال',
      'orange',
      'لافندر',
      'lavender',
      'عود',
      'oud',
      'عنبر',
      'amber',
      'باتشولي',
      'patchouli',
      'خشب',
      'woody',
      'جوز الهند',
      'coconut',
      'تونكا',
      'tonka',
      'كراميل',
      'caramel',
      'قهوة',
      'coffee',
      'تفاح',
      'apple',
      'كمثرى',
      'pear',
      'برغموت',
      'bergamot',
      'مانجو',
      'mango',
      'خوخ',
      'peach',
    ];

    final result = <String>[];

    for (final note in knownNotes) {
      if (normalized.contains(
        _normalizeText(note),
      )) {
        result.add(note);
      }
    }

    return result;
  }

  // ============================================================
  // استخراج المناسبة من بيانات المستخدم
  // ============================================================

  List<String> _getUserOccasion(
      Map<String, dynamic> user) {
    final result = <String>[];

    result.addAll(
      _getStringList(
        user['occasion'],
      ),
    );

    result.addAll(
      _getStringList(
        user['occasions'],
      ),
    );

    final usage =
    _stringValue(
      user['fragranceUsage'],
    );

    if (usage.isNotEmpty) {
      result.add(usage);
    }

    final description =
    _stringValue(
      user['fragranceDescriptionText'],
    );

    if (description.isNotEmpty) {
      result.add(description);
    }

    return result;
  }

  // ============================================================
  // استخراج الموسم
  // ============================================================

  List<String> _getUserSeason(
      Map<String, dynamic> user) {
    final result = <String>[];

    result.addAll(
      _getStringList(
        user['season'],
      ),
    );

    result.addAll(
      _getStringList(
        user['seasons'],
      ),
    );

    final description =
    _stringValue(
      user['fragranceDescriptionText'],
    );

    if (description.isNotEmpty) {
      final text =
      _normalizeText(
        description,
      );

      if (_containsAnyKeyword(
        text,
        [
          'شتاء',
          'winter',
          'بارد',
        ],
      )) {
        result.add('الشتاء');
      }

      if (_containsAnyKeyword(
        text,
        [
          'صيف',
          'summer',
          'حار',
        ],
      )) {
        result.add('الصيف');
      }

      if (_containsAnyKeyword(
        text,
        [
          'ربيع',
          'spring',
        ],
      )) {
        result.add('الربيع');
      }

      if (_containsAnyKeyword(
        text,
        [
          'خريف',
          'autumn',
          'fall',
        ],
      )) {
        result.add('الخريف');
      }
    }

    return result
        .where(
          (item) => item.trim().isNotEmpty,
    )
        .toSet()
        .toList();
  }

  // ============================================================
  // قراءة List من Firestore
  // ============================================================

  List<String> _getStringList(
      dynamic value) {
    if (value is List) {
      return value
          .map(
            (item) =>
            item.toString().trim(),
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();
    }

    if (value is String &&
        value.trim().isNotEmpty) {
      return value
          .split(
        RegExp(r'[,،•|]'),
      )
          .map(
            (item) => item.trim(),
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();
    }

    return [];
  }

  // ============================================================
  // قراءة Notes
  // ============================================================

  List<String> _getNotesList(
      dynamic notes) {
    if (notes is List) {
      return notes
          .map(
            (item) =>
            item.toString().trim(),
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();
    }

    if (notes is String &&
        notes.trim().isNotEmpty) {
      return notes
          .split(
        RegExp(r'[,،•|]'),
      )
          .map(
            (item) => item.trim(),
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();
    }

    return [];
  }

  // ============================================================
  // مقارنة النوتات
  // ============================================================

  int _countNoteMatches(
      List<String> preferred,
      List<String> perfumeNotes,
      ) {
    int matches = 0;

    for (final wanted in preferred) {
      final wantedWords =
      _getNoteKeywords(wanted);

      bool foundMatch = false;

      for (final note in perfumeNotes) {
        final perfumeWords =
        _getNoteKeywords(note);

        if (wantedWords.any(
          perfumeWords.contains,
        )) {
          foundMatch = true;
          break;
        }
      }

      if (foundMatch) {
        matches++;
      }
    }

    return matches;
  }

  // ============================================================
  // كلمات النوتات
  // ============================================================

  List<String> _getNoteKeywords(
      String value) {
    final normalized =
    _normalizeNote(value);

    if (normalized.isEmpty) {
      return [];
    }

    final keywords =
    <String>{normalized};

    void addKeywords(
        List<String> words,
        String arabic,
        String english,
        ) {
      if (words.any(
            (word) =>
            normalized.contains(
              _normalizeNote(word),
            ),
      )) {
        keywords.add(arabic);
        keywords.add(english);
      }
    }

    addKeywords(
      [
        'ورد',
        'rose',
        'rosa',
      ],
      'ورد',
      'rose',
    );

    addKeywords(
      [
        'فانيلا',
        'فانيليا',
        'vanilla',
      ],
      'فانيلا',
      'vanilla',
    );

    addKeywords(
      [
        'ياسمين',
        'jasmine',
      ],
      'ياسمين',
      'jasmine',
    );

    addKeywords(
      [
        'فراولة',
        'strawberry',
      ],
      'فراولة',
      'strawberry',
    );

    addKeywords(
      [
        'مسك',
        'musk',
      ],
      'مسك',
      'musk',
    );

    addKeywords(
      [
        'بنفسج',
        'violet',
      ],
      'بنفسج',
      'violet',
    );

    addKeywords(
      [
        'حمضيات',
        'حمضي',
        'citrus',
      ],
      'حمضيات',
      'citrus',
    );

    addKeywords(
      [
        'ليمون',
        'lemon',
      ],
      'ليمون',
      'lemon',
    );

    addKeywords(
      [
        'برتقال',
        'orange',
      ],
      'برتقال',
      'orange',
    );

    addKeywords(
      [
        'لافندر',
        'lavender',
      ],
      'لافندر',
      'lavender',
    );

    addKeywords(
      [
        'عود',
        'oud',
      ],
      'عود',
      'oud',
    );

    addKeywords(
      [
        'عنبر',
        'amber',
      ],
      'عنبر',
      'amber',
    );

    addKeywords(
      [
        'جوز الهند',
        'coconut',
      ],
      'جوز الهند',
      'coconut',
    );

    addKeywords(
      [
        'باتشولي',
        'patchouli',
      ],
      'باتشولي',
      'patchouli',
    );

    addKeywords(
      [
        'تونكا',
        'tonka',
      ],
      'تونكا',
      'tonka',
    );

    addKeywords(
      [
        'كراميل',
        'caramel',
      ],
      'كراميل',
      'caramel',
    );

    addKeywords(
      [
        'قهوة',
        'coffee',
      ],
      'قهوة',
      'coffee',
    );

    addKeywords(
      [
        'تفاح',
        'apple',
      ],
      'تفاح',
      'apple',
    );

    addKeywords(
      [
        'كمثرى',
        'pear',
      ],
      'كمثرى',
      'pear',
    );

    addKeywords(
      [
        'برغموت',
        'bergamot',
      ],
      'برغموت',
      'bergamot',
    );

    return keywords.toList();
  }

  // ============================================================
  // التحقق من كلمة
  // ============================================================

  bool _containsAnyKeyword(
      String text,
      List<String> keywords,
      ) {
    for (final keyword in keywords) {
      final normalizedKeyword =
      _normalizeText(keyword);

      if (normalizedKeyword.isNotEmpty &&
          text.contains(
            normalizedKeyword,
          )) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // توحيد النوتة
  // ============================================================

  String _normalizeNote(
      String value) {
    return value
        .toLowerCase()
        .replaceAll(
      RegExp(
        r'[🌹🍦🌿🌸🍓✨💧☕]',
      ),
      ' ',
    )
        .replaceAll('،', ' ')
        .replaceAll(',', ' ')
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }

  // ============================================================
  // توحيد النص
  // ============================================================

  String _normalizeText(
      String value) {
    return value
        .toLowerCase()
        .replaceAll(
      RegExp(
        r'[🌹🍦🌿🌸🍓✨💧📚☕❤️]',
      ),
      ' ',
    )
        .replaceAll('،', ' ')
        .replaceAll(',', ' ')
        .replaceAll('.', ' ')
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }

  // ============================================================
  // كلمات متشابهة
  // ============================================================

  bool _containsSimilarWord(
      String first,
      String second,
      ) {
    final firstWords =
    first.split(
      RegExp(r'\s+'),
    );

    final secondWords =
    second.split(
      RegExp(r'\s+'),
    );

    for (final word1 in firstWords) {
      for (final word2 in secondWords) {
        if (word1.length >= 3 &&
            word2.length >= 3 &&
            (word1.contains(word2) ||
                word2.contains(word1))) {
          return true;
        }
      }
    }

    return false;
  }

  // ============================================================
  // Interaction Adjustment
  // ============================================================

  double _interactionAdjustment(
      String? action) {
    switch (action) {
      case 'liked':
        return 5;

      case 'favorite':
        return 7;

      case 'purchased':
        return 8;

      case 'disliked':
        return -10;

      default:
        return 0;
    }
  }

  // ============================================================
  // حفظ سجل التوصية
  // ============================================================

  Future<void> _saveRecommendationHistory(
      String userId,
      List<Map<String, dynamic>> perfumes,
      Map<String, dynamic> profile,
      ) async {
    try {
      if (perfumes.isEmpty) {
        return;
      }

      final perfume =
          perfumes.first;

      final recommendationRef =
      _firestore
          .collection('recommendations')
          .doc();

      await recommendationRef.set({
        'userId': userId,

        // عطر واحد فقط
        'recommendedPerfume': {
          'perfumeId':
          _stringValue(
            perfume['documentId'],
          ),
          'name':
          _stringValue(
            perfume['name'],
          ),
          'brand':
          _stringValue(
            perfume['brand'],
          ),
          'score':
          _toDouble(
            perfume['compatibilityScore'],
          ),
        },

        'fragranceProfile': {
          'personality':
          profile['personality'],
          'mood':
          profile['mood'],
          'lifestyle':
          profile['lifestyle'],
          'interests':
          profile['interests'],
          'family':
          profile['family'],
          'strength':
          profile['strength'],
          'usage':
          profile['usage'],
          'preferredNotes':
          profile['preferredNotes'],
          'dislikedNotes':
          profile['dislikedNotes'],
          'occasions':
          profile['occasions'],
          'seasons':
          profile['seasons'],
        },

        'createdAt':
        FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint(
        'Save Recommendation Error: $e',
      );
    }
  }

  // ============================================================
  // حفظ تفاعل المستخدم
  // ============================================================

  Future<void> _saveInteraction(
      Map<String, dynamic> perfume,
      String action,
      ) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    final perfumeId =
    _stringValue(
      perfume['documentId'],
    );

    if (perfumeId.isEmpty) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('interactions')
          .doc(perfumeId)
          .set(
        {
          'perfumeId': perfumeId,
          'perfumeName':
          _stringValue(
            perfume['name'],
          ),
          'action': action,
          'perfumeFamily':
          _stringValue(
            perfume['family'],
          ),
          'perfumeNotes':
          _getNotesList(
            perfume['notes'],
          ),
          'perfumeStrength':
          _stringValue(
            perfume['strength'],
          ),
          'updatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            action == 'liked'
                ? '❤️ تم حفظ إعجابك بالعطر'
                : '👎 تم تسجيل أن العطر لا يناسبك',
          ),
          duration:
          const Duration(
            seconds: 2,
          ),
        ),
      );

      await _loadRecommendations();
    } catch (e) {
      debugPrint(
        'Interaction Error: $e',
      );
    }
  }

  // ============================================================
  // أسباب التوصية
  // ============================================================

  List<String> _getRecommendationReasons(
      Map<String, dynamic> perfume,
      ) {
    final profile =
        fragranceProfile;

    final reasons =
    <String>[];

    final breakdown =
    Map<String, dynamic>.from(
      perfume['scoreBreakdown'] ??
          {},
    );

    // ----------------------------------------------------------
    // العائلة
    // ----------------------------------------------------------

    final familyScore =
    _toDouble(
      breakdown['family'],
    );

    final userFamily =
    _stringValue(
      profile['family'],
    );

    final perfumeFamily =
    _stringValue(
      perfume['family'],
    );

    if (familyScore >= 20) {
      reasons.add(
        '🌸 العائلة العطرية "$perfumeFamily" '
            'متطابقة مع العائلة "$userFamily" '
            'في Fragrance Profile (+20%).',
      );
    } else if (familyScore > 0) {
      reasons.add(
        '🌸 توجد مطابقة جزئية بين العائلة '
            '"$userFamily" والعائلة "$perfumeFamily".',
      );
    }

    // ----------------------------------------------------------
    // النوتات
    // ----------------------------------------------------------

    final preferredNotes =
    List<String>.from(
      profile['preferredNotes'] ?? [],
    );

    final perfumeNotes =
    _getNotesList(
      perfume['notes'],
    );

    final matchedNotes =
    <String>[];

    for (final preferred
    in preferredNotes) {
      final wantedWords =
      _getNoteKeywords(
        preferred,
      );

      for (final note
      in perfumeNotes) {
        final noteWords =
        _getNoteKeywords(
          note,
        );

        if (wantedWords.any(
          noteWords.contains,
        )) {
          matchedNotes.add(note);
          break;
        }
      }
    }

    final uniqueMatchedNotes =
    matchedNotes.toSet().toList();

    final noteScore =
    _toDouble(
      breakdown['notes'],
    );

    if (noteScore > 0 &&
        uniqueMatchedNotes.isNotEmpty) {
      reasons.add(
        '🌹 يحتوي العطر على النوتات '
            'المتوافقة مع تفضيلاتك: '
            '${uniqueMatchedNotes.join('، ')} '
            '(+${noteScore.round()}%).',
      );
    }

    // ----------------------------------------------------------
    // القوة
    // ----------------------------------------------------------

    final strengthScore =
    _toDouble(
      breakdown['strength'],
    );

    final userStrength =
    _stringValue(
      profile['strength'],
    );

    final perfumeStrength =
    _stringValue(
      perfume['strength'],
    );

    if (strengthScore >= 15) {
      reasons.add(
        '💧 قوة العطر "$perfumeStrength" '
            'مطابقة للقوة "$userStrength" '
            'في Fragrance Profile (+15%).',
      );
    } else if (strengthScore > 0) {
      reasons.add(
        '💧 قوة العطر "$perfumeStrength" '
            'مناسبة بشكل جزئي لتفضيلك '
            '"$userStrength".',
      );
    }

    // ----------------------------------------------------------
    // الاستخدام
    // ----------------------------------------------------------

    final usageScore =
    _toDouble(
      breakdown['usage'],
    );

    final userUsage =
    _stringValue(
      profile['usage'],
    );

    final perfumeUsage =
    _stringValue(
      perfume['usage'],
    );

    if (usageScore >= 10) {
      reasons.add(
        '📚 استخدام العطر "$perfumeUsage" '
            'متوافق مع استخدامك '
            '"$userUsage" (+10%).',
      );
    } else if (usageScore > 0) {
      reasons.add(
        '📚 استخدام العطر مناسب جزئيًا '
            'لاستخدامك.',
      );
    }

    // ----------------------------------------------------------
    // المناسبة
    // ----------------------------------------------------------

    final occasionScore =
    _toDouble(
      breakdown['occasion'],
    );

    final perfumeOccasions =
    _getStringList(
      perfume['occasion'],
    );

    if (occasionScore > 0) {
      reasons.add(
        '✨ مناسبة العطر '
            '"${perfumeOccasions.join('، ')}" '
            'تتوافق مع احتياجاتك (+${occasionScore.round()}%).',
      );
    }

    // ----------------------------------------------------------
    // الموسم
    // ----------------------------------------------------------

    final seasonScore =
    _toDouble(
      breakdown['season'],
    );

    final perfumeSeasons =
    _getStringList(
      perfume['season'],
    );

    if (seasonScore > 0) {
      reasons.add(
        '🌿 موسم العطر '
            '"${perfumeSeasons.join('، ')}" '
            'متوافق مع الموسم المستخرج من بياناتك '
            '(+${seasonScore.round()}%).',
      );
    }

    // ----------------------------------------------------------
    // Fragrance Profile
    // ----------------------------------------------------------

    final profileScore =
    _toDouble(
      breakdown['profile'],
    );

    final personality =
    List<String>.from(
      profile['personality'] ?? [],
    );

    final mood =
    List<String>.from(
      profile['mood'] ?? [],
    );

    final lifestyle =
    List<String>.from(
      profile['lifestyle'] ?? [],
    );

    final interests =
    List<String>.from(
      profile['interests'] ?? [],
    );

    if (profileScore > 0) {
      final matchedProfileParts =
      <String>[];

      final perfumeText =
      _normalizeText(
        [
          perfume['name'],
          perfume['brand'],
          perfume['description'],
          perfume['notes'],
          perfume['family'],
          perfume['strength'],
          perfume['usage'],
          perfume['occasion'],
          perfume['season'],
        ]
            .where(
              (value) =>
          value != null,
        )
            .map(
              (value) =>
              value.toString(),
        )
            .join(' '),
      );

      if (_profileConceptMatch(
        personality,
        perfumeText,
      )) {
        matchedProfileParts.add(
          'الشخصية',
        );
      }

      if (_profileConceptMatch(
        mood,
        perfumeText,
      )) {
        matchedProfileParts.add(
          'المزاج',
        );
      }

      if (_profileConceptMatch(
        lifestyle,
        perfumeText,
      )) {
        matchedProfileParts.add(
          'نمط الحياة',
        );
      }

      if (_profileConceptMatch(
        interests,
        perfumeText,
      )) {
        matchedProfileParts.add(
          'الاهتمامات',
        );
      }

      if (matchedProfileParts.isNotEmpty) {
        reasons.add(
          '✨ توجد مطابقة مع '
              '${matchedProfileParts.join('، ')} '
              'ضمن Fragrance Profile '
              '(+${profileScore.round()}%).',
        );
      }
    }

    // ----------------------------------------------------------
    // الروائح غير المرغوبة
    // ----------------------------------------------------------

    final dislikedPenalty =
    _toDouble(
      breakdown['dislikedPenalty'],
    );

    final dislikedNotes =
    List<String>.from(
      profile['dislikedNotes'] ?? [],
    );

    final dislikedMatches =
    _countNoteMatches(
      dislikedNotes,
      perfumeNotes,
    );

    if (dislikedMatches > 0) {
      reasons.add(
        '⚠️ يحتوي العطر على '
            '$dislikedMatches من الروائح '
            'التي لا تفضلينها، لذلك تم خصم '
            '${dislikedPenalty.round()} نقطة.',
      );
    } else if (dislikedNotes.isNotEmpty) {
      reasons.add(
        '✓ لا توجد نوتات غير مرغوبة '
            'مطابقة ضمن نوتات العطر.',
      );
    }

    // ----------------------------------------------------------
    // النتيجة النهائية
    // ----------------------------------------------------------

    if (reasons.isEmpty) {
      reasons.add(
        '✨ تم اختيار هذا العطر لأنه حقق '
            'أعلى Compatibility Score عند '
            'مقارنته بجميع العطور الموجودة '
            'في Firestore.',
      );
    }

    return reasons;
  }

  // ============================================================
  // Header
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        24,
      ),
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(0xFF4A3B52),
            Color(0xFF8B7185),
          ],
        ),
        borderRadius:
        BorderRadius.only(
          bottomLeft:
          Radius.circular(32),
          bottomRight:
          Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const AppLogo(
            size: 65,
          ),
          const SizedBox(
            height: 14,
          ),
          const Text(
            'توصيتك العطرية',
            style:
            TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            'تم اختيار عدة عطور فقط بناءً على أعلى Compatibility Score',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              color:
              Colors.white
                  .withOpacity(0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Profile Summary
  // ============================================================

  Widget _buildProfileSummary() {
    final personality =
    List<String>.from(
      fragranceProfile[
      'personality'] ??
          [],
    );

    final mood =
    List<String>.from(
      fragranceProfile[
      'mood'] ??
          [],
    );

    final lifestyle =
    List<String>.from(
      fragranceProfile[
      'lifestyle'] ??
          [],
    );

    final notes =
    List<String>.from(
      fragranceProfile[
      'preferredNotes'] ??
          [],
    );

    final family =
    _stringValue(
      fragranceProfile[
      'family'],
    );

    final strength =
    _stringValue(
      fragranceProfile[
      'strength'],
    );

    final usage =
    _stringValue(
      fragranceProfile[
      'usage'],
    );

    return Container(
      margin:
      const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        12,
      ),
      padding:
      const EdgeInsets.all(
        18,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          22,
        ),
        boxShadow: [
          BoxShadow(
            color:
            const Color(
              0xFF4A3B52,
            ).withOpacity(0.06),
            blurRadius: 15,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Fragrance Profile ✨',
            style:
            TextStyle(
              color:
              Color(0xFF4A3B52),
              fontSize: 19,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          if (family.isNotEmpty)
            _buildProfileRow(
              Icons.local_florist_outlined,
              'العائلة',
              family,
            ),
          if (strength.isNotEmpty)
            _buildProfileRow(
              Icons.water_drop_outlined,
              'القوة',
              strength,
            ),
          if (usage.isNotEmpty)
            _buildProfileRow(
              Icons.access_time_rounded,
              'الاستخدام',
              usage,
            ),
          if (personality.isNotEmpty)
            _buildProfileRow(
              Icons.person_outline,
              'الشخصية',
              personality.join('، '),
            ),
          if (mood.isNotEmpty)
            _buildProfileRow(
              Icons.mood_outlined,
              'المزاج',
              mood.join('، '),
            ),
          if (lifestyle.isNotEmpty)
            _buildProfileRow(
              Icons.auto_awesome_outlined,
              'نمط الحياة',
              lifestyle.join('، '),
            ),
          if (notes.isNotEmpty)
            _buildProfileRow(
              Icons.spa_outlined,
              'النوتات المفضلة',
              notes.join('، '),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Profile Row
  // ============================================================

  Widget _buildProfileRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
            const Color(
              0xFF8B7185,
            ),
            size: 20,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: RichText(
              text:
              TextSpan(
                children: [
                  TextSpan(
                    text:
                    '$title: ',
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8B7185,
                      ),
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF4A3B52,
                      ),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // صورة افتراضية
  // ============================================================

  Widget _buildPlaceholder() {
    return Container(
      width:
      double.infinity,
      height: 220,
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(0xFFF6EAF0),
            Color(0xFFEADCE6),
          ],
        ),
      ),
      child:
      const Center(
        child: Icon(
          Icons.local_florist_rounded,
          size: 75,
          color:
          Color(0xFF8B7185),
        ),
      ),
    );
  }

  // ============================================================
  // صورة العطر
  // ============================================================
  Widget _buildPerfumeImage(
      String imageUrl,
      ) {
    final fileName = imageUrl.trim();

    if (fileName.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8EEF3),
            Color(0xFFEDE1E8),
          ],
        ),
      ),
      child: Image.asset(
        'assets/images/$fileName',
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          debugPrint(
            'Perfume image not found: assets/images/$fileName',
          );

          return _buildPlaceholder();
        },
      ),
    );
  }

  // ============================================================
  // بطاقة العطر ضمن قائمة التوصيات
  // ============================================================

  Widget _buildPerfumeCard(
      Map<String, dynamic> perfume,
      int rank,
      ) {
    final name =
    _stringValue(
      perfume['name'],
    ).isEmpty
        ? 'عطر مميز'
        : _stringValue(
      perfume['name'],
    );

    final brand =
    _stringValue(
      perfume['brand'],
    );

    final family =
    _stringValue(
      perfume['family'],
    );

    final strength =
    _stringValue(
      perfume['strength'],
    );

    final usage =
    _stringValue(
      perfume['usage'],
    );

    final occasion =
    _getStringList(
      perfume['occasion'],
    ).join(' • ');

    final season =
    _getStringList(
      perfume['season'],
    ).join(' • ');

    final description =
    _stringValue(
      perfume['description'],
    );

    final notes =
    _getNotesList(
      perfume['notes'],
    ).join(' • ');

    final imageUrl =
    _stringValue(
      perfume['imageUrl'],
    );

    final score =
    _toDouble(
      perfume['compatibilityScore'],
    );

    final baseScore =
    _toDouble(
      perfume['baseScore'],
    );

    final adjustment =
    _toDouble(
      perfume[
      'interactionAdjustment'],
    );

    final reasons =
    _getRecommendationReasons(
      perfume,
    );

    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          28,
        ),
        boxShadow: [
          BoxShadow(
            color:
            const Color(
              0xFF4A3B52,
            ).withOpacity(0.09),
            blurRadius: 20,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior:
      Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildPerfumeImage(
            imageUrl,
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              22,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // =================================================
                // ترتيب التوصية
                // =================================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E9F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'التوصية رقم $rank',
                    style: const TextStyle(
                      color: Color(0xFF4A3B52),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =================================================
                // اسم العطر
                // =================================================

                Text(
                  name,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 25,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                if (brand.isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    brand,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8B7185,
                      ),
                      fontSize: 16,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 18,
                ),

                // =================================================
                // درجة التوافق
                // =================================================

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF1E9F0,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Compatibility Score',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF4A3B52,
                          ),
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${score.round()}%',
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF4A3B52,
                          ),
                          fontSize: 38,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'درجة توافق هذا العطر مع هويتك العطرية',
                        textAlign:
                        TextAlign.center,
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF8B7185,
                          ),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                // =================================================
                // تفصيل الدرجة
                // =================================================

                const Text(
                  'تفصيل Compatibility Score',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                _buildScoreBreakdown(
                  perfume,
                ),

                const SizedBox(
                  height: 22,
                ),

                // =================================================
                // لماذا هذا العطر؟
                // =================================================

                const Text(
                  'لماذا تم اختيار هذا العطر؟ ✨',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFAF7F5,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children:
                    reasons.map(
                          (reason) {
                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 9,
                          ),
                          child: Text(
                            reason,
                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF817781,
                              ),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // =================================================
                // بيانات العطر
                // =================================================

                const Text(
                  'تفاصيل العطر',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                _buildInfoRow(
                  Icons.category_outlined,
                  'العائلة العطرية',
                  family.isEmpty
                      ? 'غير محددة'
                      : family,
                ),

                _buildInfoRow(
                  Icons.water_drop_outlined,
                  'قوة العطر',
                  strength.isEmpty
                      ? 'غير محددة'
                      : strength,
                ),

                _buildInfoRow(
                  Icons.access_time_rounded,
                  'الاستخدام',
                  usage.isEmpty
                      ? 'غير محدد'
                      : usage,
                ),

                if (occasion.isNotEmpty)
                  _buildInfoRow(
                    Icons.event_outlined,
                    'المناسبة',
                    occasion,
                  ),

                if (season.isNotEmpty)
                  _buildInfoRow(
                    Icons.wb_sunny_outlined,
                    'الفصل المناسب',
                    season,
                  ),

                _buildInfoRow(
                  Icons.spa_outlined,
                  'النوتات',
                  notes.isEmpty
                      ? 'غير محددة'
                      : notes,
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'عن العطر',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  description.isEmpty
                      ? 'عطر تم اختياره ليتناسب مع هويتك العطرية.'
                      : description,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF817781,
                    ),
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                // =================================================
                // التفاعل
                // =================================================

                const Text(
                  'ما رأيك في هذا العطر؟',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                      ElevatedButton.icon(
                        onPressed: () =>
                            _saveInteraction(
                              perfume,
                              'liked',
                            ),
                        icon:
                        const Icon(
                          Icons.favorite_border,
                        ),
                        label:
                        const Text(
                          'أعجبني ❤️',
                        ),
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF4A3B52,
                          ),
                          foregroundColor:
                          Colors.white,
                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 13,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                      OutlinedButton.icon(
                        onPressed: () =>
                            _saveInteraction(
                              perfume,
                              'disliked',
                            ),
                        icon:
                        const Icon(
                          Icons
                              .thumb_down_outlined,
                        ),
                        label:
                        const Text(
                          'لا يناسبني',
                        ),
                        style:
                        OutlinedButton
                            .styleFrom(
                          foregroundColor:
                          const Color(
                            0xFF4A3B52,
                          ),
                          side:
                          const BorderSide(
                            color:
                            Color(
                              0xFF4A3B52,
                            ),
                          ),
                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 13,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'الدرجة الأساسية: ${baseScore.round()}%'
                      '${adjustment != 0 ? '  •  تعديل التفاعل: ${adjustment > 0 ? '+' : ''}${adjustment.round()}' : ''}',
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF8B7185,
                    ),
                    fontSize: 12,
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
  // تفصيل الدرجات
  // ============================================================

  Widget _buildScoreBreakdown(
      Map<String, dynamic> perfume) {
    final breakdown =
    Map<String, dynamic>.from(
      perfume['scoreBreakdown'] ??
          {},
    );

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFFAF7F5,
        ),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          _buildScoreRow(
            'العائلة العطرية',
            _toDouble(
              breakdown['family'],
            ),
            20,
          ),
          _buildScoreRow(
            'النوتات',
            _toDouble(
              breakdown['notes'],
            ),
            20,
          ),
          _buildScoreRow(
            'قوة العطر',
            _toDouble(
              breakdown['strength'],
            ),
            15,
          ),
          _buildScoreRow(
            'الاستخدام',
            _toDouble(
              breakdown['usage'],
            ),
            10,
          ),
          _buildScoreRow(
            'المناسبة',
            _toDouble(
              breakdown['occasion'],
            ),
            10,
          ),
          _buildScoreRow(
            'الموسم',
            _toDouble(
              breakdown['season'],
            ),
            5,
          ),
          _buildScoreRow(
            'Fragrance Profile',
            _toDouble(
              breakdown['profile'],
            ),
            20,
          ),
          if (_toDouble(
            breakdown[
            'dislikedPenalty'],
          ) >
              0)
            _buildPenaltyRow(
              'خصم الروائح غير المرغوبة',
              _toDouble(
                breakdown[
                'dislikedPenalty'],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // صف الدرجة
  // ============================================================

  Widget _buildScoreRow(
      String title,
      double score,
      double maxScore,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF817781,
                ),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '${score.round()} / ${maxScore.round()}',
            style:
            const TextStyle(
              color:
              Color(
                0xFF4A3B52,
              ),
              fontSize: 13,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // صف الخصم
  // ============================================================

  Widget _buildPenaltyRow(
      String title,
      double value,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
            const TextStyle(
              color:
              Color(
                0xFF8B7185,
              ),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '-${value.round()}',
          style:
          const TextStyle(
            color:
            Color(
              0xFF9A6B83,
            ),
            fontSize: 13,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // صف المعلومات
  // ============================================================

  Widget _buildInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFF1E9F0,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
              const Color(
                0xFF8B7185,
              ),
              size: 20,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF8B7185,
                    ),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF4A3B52,
                    ),
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
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
  // حالة الخطأ
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .sentiment_dissatisfied_outlined,
              size: 70,
              color:
              Color(0xFF8B7185),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              errorMessage ??
                  'حدث خطأ غير متوقع.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF4A3B52,
                ),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed:
              _loadRecommendations,
              icon:
              const Icon(
                Icons.refresh,
              ),
              label:
              const Text(
                'إعادة المحاولة',
              ),
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                const Color(
                  0xFF4A3B52,
                ),
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFFFAF7F5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: isLoading
                  ? const Center(
                child:
                CircularProgressIndicator(
                  color:
                  Color(
                    0xFF4A3B52,
                  ),
                ),
              )
                  : errorMessage != null
                  ? _buildErrorState()
                  : RefreshIndicator(
                color:
                const Color(
                  0xFF4A3B52,
                ),
                onRefresh:
                _loadRecommendations,
                child:
                recommendations
                    .isEmpty
                    ? ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height:
                      120,
                    ),
                    Center(
                      child:
                      Text(
                        'لا توجد توصية متاحة حاليًا.',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF4A3B52,
                          ),
                          fontSize:
                          16,
                        ),
                      ),
                    ),
                  ],
                )
                    : ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.only(
                    top: 22,
                    bottom: 35,
                  ),
                  children: [
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        24,
                      ),
                      child:
                      Text(
                        'توصيات العطور المناسبة لك ✨',
                        textAlign:
                        TextAlign.center,
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF4A3B52,
                          ),
                          fontSize:
                          22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        30,
                      ),
                      child:
                      Text(
                        'تم تحليل جميع العطور في Firestore وترتيبها حسب درجة توافقها مع هويتك العطرية.',
                        textAlign:
                        TextAlign.center,
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF8B7185,
                          ),
                          fontSize:
                          13,
                          height:
                          1.5,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    if (fragranceProfile
                        .isNotEmpty)
                      _buildProfileSummary(),

                    // =================================================
                    // عدة عطور مرتبة حسب درجة التوافق
                    // =================================================
                    ...recommendations.asMap().entries.map(
                          (entry) => _buildPerfumeCard(
                        entry.value,
                        entry.key + 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // دمج القوائم
  // ============================================================

  List<String> _mergeLists(
      List<List<String>> lists,
      ) {
    final result =
    <String>[];

    for (final list in lists) {
      result.addAll(list);
    }

    return result
        .where(
          (item) =>
      item.trim().isNotEmpty,
    )
        .toSet()
        .toList();
  }

  // ============================================================
  // تحويل آمن إلى String
  // ============================================================

  String _stringValue(
      dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ============================================================
  // تحويل آمن إلى double
  // ============================================================

  double _toDouble(
      dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}