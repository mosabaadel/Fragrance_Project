import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'perfume_details_page.dart';

const Color backgroundColor = Color(0xFFFAF7F5);
const Color ivory = Color(0xFFFFFFFF);
const Color espresso = Color(0xFF4A3B52);
const Color warmBrown = Color(0xFF8B7185);
const Color champagne = Color(0xFFD8A9B8);
const Color softChampagne = Color(0xFFEBD7E0);
const Color secondaryText = Color(0xFF817781);
const Color softBrown = Color(0xFFF1E9F0);

class DiscoverPerfumesPage extends StatefulWidget {
  const DiscoverPerfumesPage({super.key});

  @override
  State<DiscoverPerfumesPage> createState() =>
      _DiscoverPerfumesPageState();
}

class _DiscoverPerfumesPageState
    extends State<DiscoverPerfumesPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';
  String _selectedFamily = 'الكل';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getFamilies(List<QueryDocumentSnapshot> docs) {
    final families = <String>{'الكل'};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final family = data['family']?.toString().trim();

      if (family != null && family.isNotEmpty) {
        families.add(family);
      }
    }

    return families.toList();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchText.trim().isEmpty) {
      return true;
    }

    final query = _searchText.trim().toLowerCase();

    final name = data['name']?.toString().toLowerCase() ?? '';
    final brand = data['brand']?.toString().toLowerCase() ?? '';
    final family = data['family']?.toString().toLowerCase() ?? '';
    final notes = data['notes']?.toString().toLowerCase() ?? '';

    return name.contains(query) ||
        brand.contains(query) ||
        family.contains(query) ||
        notes.contains(query);
  }

  bool _matchesFamily(Map<String, dynamic> data) {
    if (_selectedFamily == 'الكل') {
      return true;
    }

    return data['family']?.toString() == _selectedFamily;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'اكتشف العطور',
          style: TextStyle(
            color: espresso,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: espresso,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('perfumes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'حدث خطأ أثناء تحميل العطور',
                style: TextStyle(
                  color: secondaryText,
                ),
              ),
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

          final docs = snapshot.data?.docs ?? [];

          final families = _getFamilies(docs);

          final filteredDocs = docs.where((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            return _matchesSearch(data) &&
                _matchesFamily(data);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن عطر أو براند...',
                    hintStyle: const TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: warmBrown,
                    ),
                    suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: warmBrown,
                      ),
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchText = '';
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: ivory,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: softChampagne,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: softChampagne,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: champagne,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 52,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: families.length,
                  itemBuilder: (context, index) {
                    final family = families[index];
                    final selected =
                        family == _selectedFamily;

                    return Padding(
                      padding:
                      const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(family),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFamily = family;
                          });
                        },
                        selectedColor: espresso,
                        backgroundColor: ivory,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : warmBrown,
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 11,
                        ),
                        side: const BorderSide(
                          color: softChampagne,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: filteredDocs.isEmpty
                    ? const Center(
                  child: Text(
                    'لا توجد عطور مطابقة للبحث',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                )
                    : GridView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    25,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PerfumeDetailsPage(
                              perfumeId: filteredDocs[index].id,
                              perfumeData: data,
                            ),
                          ),
                        );
                      },
                      child: _buildPerfumeCard(data),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPerfumeCard(
      Map<String, dynamic> data) {
    final name =
        data['name']?.toString() ?? 'عطر';
    final brand =
        data['brand']?.toString() ?? '';
    final family =
        data['family']?.toString() ?? '';
    final strength =
        data['strength']?.toString() ?? '';

    final imageUrl =
        data['imageUrl']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: softChampagne,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: softBrown,
                  borderRadius:
                  BorderRadius.circular(17),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.asset(
                  'assets/images/$imageUrl',
                  fit: BoxFit.contain,
                  errorBuilder:
                      (_, __, ___) {
                    return const Icon(
                      Icons.local_florist_outlined,
                      color: warmBrown,
                      size: 45,
                    );
                  },
                )
                    : const Icon(
                  Icons.local_florist_outlined,
                  color: warmBrown,
                  size: 45,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: espresso,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: warmBrown,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 7),

            Row(
              textDirection: TextDirection.rtl,
              children: [
                if (family.isNotEmpty)
                  _smallTag(family),

                const SizedBox(width: 5),

                if (strength.isNotEmpty)
                  _smallTag(strength),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTag(String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: softBrown,
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: warmBrown,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}