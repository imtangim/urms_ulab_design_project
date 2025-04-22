import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/features/teacher/search_delegates.dart';
import 'package:urms_ulab/features/teacher/widget/teacher_card.dart';
import 'package:urms_ulab/provider/teacher_provider.dart';

class TeacherScreen extends ConsumerStatefulWidget {
  const TeacherScreen({super.key});

  @override
  ConsumerState<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends ConsumerState<TeacherScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final teachersNotifier = ref.read(teachersProvider.notifier);
      if (teachersNotifier.hasMoreData) {
        teachersNotifier.loadMoreTeachers();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachersState = ref.watch(teachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TeacherSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: teachersState.when(
        loading: () => Center(
            child: CircularProgressIndicator(
          color: Appcolor.primaryColor,
          strokeCap: StrokeCap.round,
        )),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
        data: (teachers) {
          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found'));
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.read(teachersProvider.notifier).loadInitialTeachers();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: teachers.length + 1, // +1 for the loading indicator
              itemBuilder: (context, index) {
                if (index == teachers.length) {
                  // Show loading indicator at the bottom
                  return ref.read(teachersProvider.notifier).hasMoreData
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Appcolor.primaryColor,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }

                final teacher = teachers[index];
                return TeacherCard(teacher: teacher);
              },
            ),
          );
        },
      ),
    );
  }
}
