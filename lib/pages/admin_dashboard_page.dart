import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

// ============================================================
// Fragrance Identity — Admin Dashboard
// إدارة العطور من الهاتف
// ============================================================

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);
const Color taupe = Color(0xFF9A8D98);
const Color secondaryText = Color(0xFF817781);
const Color softBrown = Color(0xFFF1E9F0);

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _searchText = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // Search
  // ============================================================

  bool _matchesSearch(Map<String, dynamic> perfume) {
    if (_searchText.isEmpty) return true;

    final name = perfume['name']?.toString().toLowerCase() ?? '';
    final brand = perfume['brand']?.toString().toLowerCase() ?? '';
    final family = perfume['family']?.toString().toLowerCase() ?? '';

    return name.contains(_searchText) ||
        brand.contains(_searchText) ||
        family.contains(_searchText);
  }

  // ============================================================
  // Delete
  // ============================================================

  Future<void> _deletePerfume(
      String documentId,
      String perfumeName,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'حذف العطر',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: espresso,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'هل أنتِ متأكدة من حذف "$perfumeName"؟\n\n'
                'سيتم حذف بيانات العطر من قاعدة البيانات.',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: secondaryText,
              height: 1.6,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: espresso,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _firestore
          .collection('perfumes')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حذف "$perfumeName" بنجاح',
            textAlign: TextAlign.right,
          ),
          backgroundColor: espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('ADMIN DELETE FIREBASE ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase Error: ${e.code}\n${e.message ?? ''}',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('ADMIN DELETE ERROR: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'حدث خطأ أثناء حذف العطر',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // Open Add / Edit Form
  // ============================================================

  Future<void> _openPerfumeForm({
    DocumentSnapshot? document,
  }) async {
    final bool isEditing = document != null;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) {
        return _PerfumeFormSheet(
          document: document,
          firestore: _firestore,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'تم تعديل العطر بنجاح'
                : 'تمت إضافة العطر بنجاح',
            textAlign: TextAlign.right,
          ),
          backgroundColor: espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ============================================================
  // Perfume Card
  // ============================================================

  Widget _buildPerfumeCard(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    final name = data['name']?.toString() ?? 'بدون اسم';
    final brand = data['brand']?.toString() ?? '';
    final family = data['family']?.toString() ?? '';
    final strength = data['strength']?.toString() ?? '';
    final imageName = data['imageUrl']?.toString() ?? '';
    final imageBase64 = data['imageBase64']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: softChampagne,
        ),
        boxShadow: [
          BoxShadow(
            color: espresso.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 100,
              decoration: BoxDecoration(
                color: softBrown,
                borderRadius: BorderRadius.circular(17),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: imageBase64.isNotEmpty
                    ? Image.memory(
                  base64Decode(imageBase64),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.local_florist_outlined,
                      color: warmBrown,
                      size: 35,
                    );
                  },
                )
                    : imageName.isNotEmpty
                    ? Image.asset(
                  'assets/images/$imageName',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.local_florist_outlined,
                      color: warmBrown,
                      size: 35,
                    );
                  },
                )
                    : const Icon(
                  Icons.local_florist_outlined,
                  color: warmBrown,
                  size: 35,
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: espresso,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      brand,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: warmBrown,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      if (family.isNotEmpty) _buildSmallTag(family),
                      if (strength.isNotEmpty)
                        _buildSmallTag(strength),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          _openPerfumeForm(
                            document: document,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: softBrown,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: warmBrown,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'تعديل',
                                style: TextStyle(
                                  color: warmBrown,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 7),

                      InkWell(
                        onTap: () {
                          _deletePerfume(
                            document.id,
                            name,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'حذف',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: softBrown,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: warmBrown,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // Stats
  // ============================================================

  Widget _buildStatsCard(int count) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            espresso,
            Color(0xFF66516D),
            warmBrown,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: espresso.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: champagne,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'إدارة العطور',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count عطر في قاعدة البيانات',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFFE9DDE5),
                    fontSize: 11.5,
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
  // Add Button
  // ============================================================

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          _openPerfumeForm();
        },
        icon: const Icon(
          Icons.add_rounded,
          size: 22,
        ),
        label: const Text(
          'إضافة عطر جديد',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: champagne,
          foregroundColor: espresso,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Search Field
  // ============================================================

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: espresso,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'ابحثي باسم العطر أو البراند...',
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(
            color: taupe,
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: warmBrown,
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: taupe,
              size: 19,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Empty
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: taupe,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            _searchText.isEmpty
                ? 'لا توجد عطور حالياً'
                : 'لم يتم العثور على عطر',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: espresso,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchText.isEmpty
                ? 'يمكنك إضافة أول عطر من الزر أعلاه.'
                : 'جربي البحث باسم آخر أو باسم البراند.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Error
  // ============================================================

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: warmBrown,
              size: 50,
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: espresso,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: espresso,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'لوحة الإدارة',
          style: TextStyle(
            color: espresso,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: espresso,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('perfumes')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(
                'حدث خطأ أثناء تحميل العطور',
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: warmBrown,
                ),
              );
            }

            final documents = snapshot.data?.docs ?? [];

            final filteredDocuments = documents.where((document) {
              final data =
              document.data() as Map<String, dynamic>;

              return _matchesSearch(data);
            }).toList();

            return RefreshIndicator(
              color: warmBrown,
              onRefresh: () async {
                await _firestore
                    .collection('perfumes')
                    .get();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  30,
                ),
                children: [
                  _buildStatsCard(documents.length),

                  const SizedBox(height: 16),

                  _buildAddButton(),

                  const SizedBox(height: 20),

                  _buildSearchField(),

                  const SizedBox(height: 20),

                  if (filteredDocuments.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredDocuments.map(
                          (document) =>
                          _buildPerfumeCard(document),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// PERFUME FORM SHEET
// هذا الجزء مستقل عن StatefulBuilder
// ============================================================

class _PerfumeFormSheet extends StatefulWidget {
  final DocumentSnapshot? document;
  final FirebaseFirestore firestore;

  const _PerfumeFormSheet({
    required this.document,
    required this.firestore,
  });

  @override
  State<_PerfumeFormSheet> createState() =>
      _PerfumeFormSheetState();
}

class _PerfumeFormSheetState extends State<_PerfumeFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _familyController;
  late final TextEditingController _strengthController;
  late final TextEditingController _usageController;
  late final TextEditingController _occasionController;
  late final TextEditingController _seasonController;
  late final TextEditingController _notesController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  String? _selectedImageBase64;

  bool _isSaving = false;

  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();

    final data =
        widget.document?.data() as Map<String, dynamic>? ?? {};

    _nameController = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    _brandController = TextEditingController(
      text: data['brand']?.toString() ?? '',
    );

    _familyController = TextEditingController(
      text: data['family']?.toString() ?? '',
    );

    _strengthController = TextEditingController(
      text: data['strength']?.toString() ?? '',
    );

    _usageController = TextEditingController(
      text: data['usage']?.toString() ?? '',
    );

    _occasionController = TextEditingController(
      text: data['occasion']?.toString() ?? '',
    );

    _seasonController = TextEditingController(
      text: data['season']?.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: data['notes']?.toString() ?? '',
    );

    _descriptionController = TextEditingController(
      text: data['description']?.toString() ?? '',
    );

    _imageController = TextEditingController(
      text: data['imageUrl']?.toString() ?? '',
    );

    final oldBase64 = data['imageBase64']?.toString() ?? '';

    if (oldBase64.isNotEmpty) {
      _selectedImageBase64 = oldBase64;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _familyController.dispose();
    _strengthController.dispose();
    _usageController.dispose();
    _occasionController.dispose();
    _seasonController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();

    super.dispose();
  }

  // ============================================================
  // Pick Image
  // ============================================================

  Future<String?> _pickPerfumeImage() async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 900,
        maxHeight: 900,
      );

      if (picked == null) return null;

      final Uint8List originalBytes =
      await picked.readAsBytes();

      final Uint8List? compressedBytes =
      await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 650,
        minHeight: 650,
        quality: 55,
        format: CompressFormat.jpeg,
      );

      final bytes = compressedBytes ?? originalBytes;

      if (bytes.length > 400 * 1024) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'الصورة ما زالت كبيرة. اختاري صورة أصغر.',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        return null;
      }

      return base64Encode(bytes);
    } catch (e) {
      debugPrint('IMAGE PICK ERROR: $e');

      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر اختيار الصورة: $e',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return null;
    }
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void> _savePerfume() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final perfumeData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'family': _familyController.text.trim(),
      'strength': _strengthController.text.trim(),
      'usage': _usageController.text.trim(),
      'occasion': _occasionController.text.trim(),
      'season': _seasonController.text.trim(),
      'notes': _notesController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageUrl': _imageController.text.trim(),
      'imageBase64': _selectedImageBase64 ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (_isEditing) {
        await widget.firestore
            .collection('perfumes')
            .doc(widget.document!.id)
            .update(perfumeData);
      } else {
        perfumeData['createdAt'] =
            FieldValue.serverTimestamp();

        await widget.firestore
            .collection('perfumes')
            .add(perfumeData);
      }

      // مهم جداً:
      // لا نستخدم setState بعد إغلاق النافذة.
      // فقط نرجع true إلى الصفحة الرئيسية.
      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on FirebaseException catch (e) {
      debugPrint('================================');
      debugPrint('ADMIN SAVE FIREBASE ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('================================');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      String message;

      if (e.code == 'permission-denied') {
        message =
        'ليس لديك صلاحية لإضافة أو تعديل العطر.\n'
            'تأكدي أن isAdmin = true في حساب الأدمن.';
      } else if (e.code == 'resource-exhausted') {
        message =
        'حجم بيانات العطر كبير جداً.\n'
            'اختاري صورة أصغر.';
      } else if (e.code == 'invalid-argument') {
        message = 'بيانات العطر غير صالحة.';
      } else {
        message =
        'خطأ Firebase: ${e.code}\n'
            '${e.message ?? ''}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      debugPrint('ADMIN SAVE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء حفظ بيانات العطر',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // Form Field
  // ============================================================

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: espresso,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          labelStyle: const TextStyle(
            color: warmBrown,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            icon,
            color: warmBrown,
            size: 21,
          ),
          filled: true,
          fillColor: ivory,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: softChampagne,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: softChampagne,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: champagne,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: Colors.red.shade300,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 1.5,
            ),
          ),
        ),
        validator: requiredField
            ? (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'هذا الحقل مطلوب';
          }

          return null;
        }
            : null,
      ),
    );
  }

  // ============================================================
  // Image Picker Section
  // ============================================================

  Widget _buildImagePickerSection() {
    final hasBase64 = _selectedImageBase64 != null &&
        _selectedImageBase64!.trim().isNotEmpty;

    final oldImageName =
    _imageController.text.trim();

    final hasOldLocalImage = oldImageName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'صورة العطر',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: warmBrown,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: ivory,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: softChampagne,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: hasBase64
                ? Image.memory(
              base64Decode(
                _selectedImageBase64!,
              ),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  _imagePlaceholder(),
            )
                : hasOldLocalImage
                ? Image.asset(
              'assets/images/$oldImageName',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  _imagePlaceholder(),
            )
                : _imagePlaceholder(),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                  final picked =
                  await _pickPerfumeImage();

                  if (picked == null) return;

                  if (!mounted) return;

                  setState(() {
                    _selectedImageBase64 =
                        picked;
                    _imageController.clear();
                  });
                },
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 19,
                ),
                label: const Text(
                  'اختيار صورة من الهاتف',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: espresso,
                  side: const BorderSide(
                    color: champagne,
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            if (hasBase64 || hasOldLocalImage) ...[
              const SizedBox(width: 8),

              IconButton(
                onPressed: _isSaving
                    ? null
                    : () {
                  setState(() {
                    _selectedImageBase64 =
                    null;
                    _imageController.clear();
                  });
                },
                tooltip: 'حذف الصورة',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),

        const Text(
          'الصورة تُحفظ داخل Firestore مباشرة، بدون Firebase Storage.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: secondaryText,
            fontSize: 10.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: taupe,
          size: 42,
        ),
        SizedBox(height: 8),
        Text(
          'لم يتم اختيار صورة',
          style: TextStyle(
            color: secondaryText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Build Form Sheet
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // ==================================================
            // Header
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: espresso,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      _isEditing
                          ? 'تعديل بيانات العطر'
                          : 'إضافة عطر جديد',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: espresso,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),
            ),

            Container(
              width: 45,
              height: 4,
              margin:
              const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: champagne,
                borderRadius:
                BorderRadius.circular(20),
              ),
            ),

            // ==================================================
            // Form
            // ==================================================

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    30,
                  ),
                  children: [
                    _buildFormField(
                      controller: _nameController,
                      label: 'اسم العطر',
                      hint: 'مثال: J\'adore',
                      icon:
                      Icons.local_florist_outlined,
                      requiredField: true,
                    ),

                    _buildFormField(
                      controller: _brandController,
                      label: 'العلامة التجارية',
                      hint: 'مثال: Dior',
                      icon: Icons.business_outlined,
                      requiredField: true,
                    ),

                    _buildFormField(
                      controller: _familyController,
                      label: 'العائلة العطرية',
                      hint: 'مثال: زهري',
                      icon: Icons.category_outlined,
                      requiredField: true,
                    ),

                    _buildFormField(
                      controller: _strengthController,
                      label: 'قوة العطر',
                      hint:
                      'مثال: خفيف / متوسط / قوي',
                      icon:
                      Icons.water_drop_outlined,
                    ),

                    _buildFormField(
                      controller: _usageController,
                      label: 'الاستخدام',
                      hint:
                      'مثال: العمل والدراسة',
                      icon:
                      Icons.access_time_rounded,
                    ),

                    _buildFormField(
                      controller: _occasionController,
                      label: 'المناسبة',
                      hint:
                      'مثال: يومي / رسمي / سهرة',
                      icon: Icons.event_outlined,
                    ),

                    _buildFormField(
                      controller: _seasonController,
                      label: 'الموسم',
                      hint:
                      'مثال: الصيف / الشتاء',
                      icon:
                      Icons.wb_sunny_outlined,
                    ),

                    _buildFormField(
                      controller: _notesController,
                      label: 'النوتات العطرية',
                      hint:
                      'مثال: ورد, فانيلا, ياسمين',
                      icon: Icons.spa_outlined,
                      maxLines: 3,
                    ),

                    _buildFormField(
                      controller:
                      _descriptionController,
                      label: 'وصف العطر',
                      hint:
                      'اكتبي وصفاً مختصراً للعطر',
                      icon:
                      Icons.description_outlined,
                      maxLines: 4,
                    ),

                    _buildImagePickerSection(),

                    const SizedBox(height: 20),

                    // ==================================================
                    // Save Button
                    // ==================================================

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                        _isSaving
                            ? null
                            : _savePerfume,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          espresso,
                          foregroundColor:
                          Colors.white,
                          disabledBackgroundColor:
                          espresso.withOpacity(0.65),
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              17,
                            ),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:
                            Colors.white,
                          ),
                        )
                            : Text(
                          _isEditing
                              ? 'حفظ التعديلات'
                              : 'إضافة العطر',
                          style:
                          const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
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
}