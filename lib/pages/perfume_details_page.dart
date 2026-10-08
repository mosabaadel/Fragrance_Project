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

class PerfumeDetailsPage extends StatefulWidget {
  final String perfumeId;
  final Map<String, dynamic> perfumeData;

  const PerfumeDetailsPage({
    super.key,
    required this.perfumeId,
    required this.perfumeData,
  });

  @override
  State<PerfumeDetailsPage> createState() => _PerfumeDetailsPageState();
}

class _PerfumeDetailsPageState extends State<PerfumeDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
    _loadLikesCount();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkLikeStatus() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('perfumes')
          .doc(widget.perfumeId)
          .collection('likes')
          .doc(user!.uid)
          .get();
      if (mounted) {
        setState(() {
          isLiked = doc.exists;
        });
      }
    } catch (e) {
      debugPrint('Error checking like status: $e');
    }
  }

  Future<void> _loadLikesCount() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('perfumes')
          .doc(widget.perfumeId)
          .get();
      if (mounted) {
        setState(() {
          likesCount = doc.data()?['likesCount'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading likes count: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً', textDirection: TextDirection.rtl)),
      );
      return;
    }

    final perfumeRef = FirebaseFirestore.instance.collection('perfumes').doc(widget.perfumeId);
    final likeRef = perfumeRef.collection('likes').doc(user!.uid);

    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final perfumeDoc = await transaction.get(perfumeRef);
        int currentLikes = perfumeDoc.data()?['likesCount'] ?? 0;
        
        if (isLiked) {
          transaction.set(likeRef, {
            'uid': user!.uid,
            'name': user!.displayName ?? 'مستخدم',
            'timestamp': FieldValue.serverTimestamp(),
          });
          transaction.update(perfumeRef, {'likesCount': currentLikes + 1});
        } else {
          transaction.delete(likeRef);
          transaction.update(perfumeRef, {'likesCount': (currentLikes > 0 ? currentLikes - 1 : 0)});
        }
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      setState(() {
        isLiked = !isLiked;
        likesCount += isLiked ? 1 : -1;
      });
    }
  }

  Future<void> _addComment() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً', textDirection: TextDirection.rtl)),
      );
      return;
    }
    
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      await FirebaseFirestore.instance
          .collection('perfumes')
          .doc(widget.perfumeId)
          .collection('comments')
          .add({
        'uid': user!.uid,
        'name': user!.displayName ?? 'مستخدم',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.perfumeData['name']?.toString() ?? 'عطر';
    final brand = widget.perfumeData['brand']?.toString() ?? '';
    final family = widget.perfumeData['family']?.toString() ?? '';
    final notes = widget.perfumeData['notes']?.toString() ?? '';
    final imageUrl = widget.perfumeData['imageUrl']?.toString() ?? '';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: espresso),
        title: const Text(
          'تفاصيل العطر',
          style: TextStyle(
            color: espresso,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // صورة العطر والمعلومات
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ivory,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: softChampagne),
                        boxShadow: [
                          BoxShadow(
                            color: espresso.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: softBrown,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: imageUrl.isNotEmpty
                                ? Image.asset(
                                    'assets/images/$imageUrl',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.local_florist_outlined,
                                        color: warmBrown, size: 60),
                                  )
                                : const Icon(Icons.local_florist_outlined,
                                    color: warmBrown, size: 60),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: champagne,
                                      size: 32,
                                    ),
                                    onPressed: _toggleLike,
                                  ),
                                  Text(
                                    '$likesCount إعجاب',
                                    style: const TextStyle(
                                      color: warmBrown,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      name,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: espresso,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (brand.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        brand,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: warmBrown,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    if (family.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: softBrown,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          family,
                                          style: const TextStyle(color: warmBrown, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    if (notes.isNotEmpty)
                                      Text(
                                        notes,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // التعليقات
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Text(
                        'التعليقات والآراء',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: espresso,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('perfumes')
                          .doc(widget.perfumeId)
                          .collection('comments')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: champagne));
                        }
                        final comments = snapshot.data?.docs ?? [];
                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                              child: Text(
                                'كن أول من يكتب رأيه عن هذا العطر!',
                                style: TextStyle(color: secondaryText),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final comment = comments[index].data() as Map<String, dynamic>;
                            return Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: ivory,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: softChampagne),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        comment['name'] ?? 'مستخدم',
                                        style: const TextStyle(
                                          color: espresso,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const CircleAvatar(
                                        backgroundColor: softBrown,
                                        radius: 14,
                                        child: Icon(Icons.person, size: 16, color: warmBrown),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment['text'] ?? '',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: secondaryText,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80), // مساحة للـ TextField السفلي
                  ],
                ),
              ),
            ),
            // كتابة تعليق
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: ivory,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send_rounded, color: champagne, size: 28),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'اكتب رأيك في العطر...',
                          hintStyle: const TextStyle(color: secondaryText, fontSize: 13),
                          filled: true,
                          fillColor: softBrown,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
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
