import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../ widgets/controller_bottom_nav.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class OfficialExamsScreen
    extends StatefulWidget {
  final String initialFilter;

  const OfficialExamsScreen({
    super.key,
    this.initialFilter = 'all',
  });

  @override
  State<OfficialExamsScreen> createState() =>
      _OfficialExamsScreenState();
}

class _OfficialExamsScreenState
    extends State<OfficialExamsScreen> {
  final FirestoreService _firestore =
  FirestoreService();

  late String _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      bottomNavigationBar:
      const ControllerBottomNav(
        currentIndex: 1,
      ),

      body: SafeArea(
        child: Column(
          children: [
            _header(),

            _filters(),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                stream:
                _firestore.officialExamsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load official exams.',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        AppColors.controller,
                      ),
                    );
                  }

                  var docs =
                      snapshot.data!.docs;

                  docs = docs.where((doc) {
                    if (_filter == 'all') {
                      return true;
                    }

                    return doc
                        .data()['status']
                        ?.toString()
                        .toLowerCase() ==
                        _filter;
                  }).toList();

                  docs.sort((a, b) {
                    final aTime =
                    a.data()['createdAt'];

                    final bTime =
                    b.data()['createdAt'];

                    if (aTime is Timestamp &&
                        bTime is Timestamp) {
                      return bTime
                          .compareTo(aTime);
                    }

                    return 0;
                  });

                  if (docs.isEmpty) {
                    return _empty();
                  }

                  return ListView.separated(
                    padding:
                    const EdgeInsets.all(14),
                    itemCount: docs.length,
                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      height: 10,
                    ),
                    itemBuilder:
                        (context, index) {
                      final doc =
                      docs[index];

                      return _ExamCard(
                        id: doc.id,
                        data: doc.data(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding:
      const EdgeInsets.all(17),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Official Exams',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Review and manage official examinations',
            style: TextStyle(
              color:
              Color(0xFFAAB6CA),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    const filters = [
      'all',
      'pending_approval',
      'published',
      'locked',
      'results_released',
      'rejected',
    ];

    return SizedBox(
      height: 53,
      child: ListView.separated(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(width: 6),
        itemBuilder:
            (context, index) {
          final value = filters[index];

          return ChoiceChip(
            selected:
            _filter == value,
            selectedColor:
            AppColors.controller,
            label: Text(
              value
                  .replaceAll('_', ' ')
                  .toUpperCase(),
            ),
            labelStyle: TextStyle(
              fontSize: 8,
              color:
              _filter == value
                  ? Colors.white
                  : AppColors
                  .textPrimary,
            ),
            onSelected: (_) {
              setState(() {
                _filter = value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 55,
            color:
            Color(0xFF9CA8B9),
          ),
          SizedBox(height: 10),
          Text(
            'No official exams found',
            style: TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;

  const _ExamCard({
    required this.id,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        data['status']?.toString() ??
            'pending_approval';

    final questions =
        List.from(
          data['questionIds'] ?? [],
        ).length;

    final duration =
        data['durationMinutes'] ?? 0;

    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(14),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(14),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.examManagement,
            arguments: id,
          );
        },
        child: Container(
          padding:
          const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color:
              const Color(0xFFE3E8EF),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data['title']
                          ?.toString() ??
                          'Untitled Exam',
                      style:
                      const TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                '${data['subject'] ?? 'General'} • ${data['classBatch'] ?? 'No batch'}',
                style:
                const TextStyle(
                  color: AppColors
                      .textSecondary,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$questions Qs',
                    style:
                    const TextStyle(
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$duration min',
                    style:
                    const TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'published':
        color = Colors.blue;
        break;
      case 'locked':
        color = Colors.orange;
        break;
      case 'results_released':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color =
            AppColors.controller;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(alpha: 0.1),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        status
            .replaceAll('_', ' ')
            .toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }
}