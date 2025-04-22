import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/features/homepage/create_post.dart';
import 'package:urms_ulab/features/homepage/post_card.dart';
import 'package:urms_ulab/models/post_model.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Pagination variables
  final int postsPerPage = 10;
  final Map<String, PostModel> postsMap = {}; // Use map to track posts by ID
  bool isLoading = false;
  bool hasMorePosts = true;
  DocumentSnapshot? lastDocument;
  ScrollController scrollController = ScrollController();
  Stream<QuerySnapshot>? postsStream;

  @override
  void initState() {
    super.initState();
    _initPostsStream();
    _loadInitialPosts();
    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  // Initialize stream for real-time updates
  void _initPostsStream() {
    // This will listen to updates to the most recent posts
    postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('postCreatedAt', descending: true)
        .limit(50) // Limit to a reasonable number to avoid excessive updates
        .snapshots();

    // Add listener to handle stream changes including deletions
    postsStream?.listen((snapshot) {
      if (!mounted) return;

      // Handle changes
      for (var change in snapshot.docChanges) {
        final id = change.doc.id;

        if (change.type == DocumentChangeType.removed) {
          // Handle deletion - remove from our posts map
          setState(() {
            postsMap.remove(id);
          });
        } else if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          // Update existing posts or add if we don't have enough posts yet
          if (postsMap.containsKey(id) || postsMap.length < postsPerPage) {
            setState(() {
              postsMap[id] =
                  PostModel.fromMap(change.doc.data() as Map<String, dynamic>);
            });
          }
        }
      }
    });
  }

  // Scroll listener to detect when to load more posts
  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMorePosts) {
      _loadMorePosts();
    }
  }

  // Load initial posts
  Future<void> _loadInitialPosts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('postCreatedAt', descending: true)
          .limit(postsPerPage)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            // Clear existing posts
            postsMap.clear();

            // Add new posts to map
            for (var doc in querySnapshot.docs) {
              final post =
                  PostModel.fromMap(doc.data() as Map<String, dynamic>);
              postsMap[doc.id] = post;
            }

            lastDocument = querySnapshot.docs.last;
            hasMorePosts = querySnapshot.docs.length == postsPerPage;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            postsMap.clear();
            hasMorePosts = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial posts: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Load more posts for pagination
  Future<void> _loadMorePosts() async {
    if (isLoading || !hasMorePosts || lastDocument == null) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('postCreatedAt', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(postsPerPage)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            // Add new posts to map
            for (var doc in querySnapshot.docs) {
              final post =
                  PostModel.fromMap(doc.data() as Map<String, dynamic>);
              postsMap[doc.id] = post;
            }

            lastDocument = querySnapshot.docs.last;
            hasMorePosts = querySnapshot.docs.length == postsPerPage;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            hasMorePosts = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading more posts: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Pull to refresh functionality
  Future<void> _refreshPosts() async {
    if (mounted) {
      setState(() {
        lastDocument = null;
        hasMorePosts = true;
      });
    }

    return _loadInitialPosts();
  }

  // Convert posts map to sorted list
  List<PostModel> get sortedPosts {
    final posts = postsMap.values.toList();
    posts.sort((a, b) => b.postCreatedAt.compareTo(a.postCreatedAt));
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Appcolor.buttonBackgroundColor,
        backgroundColor: Colors.white,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: _refreshPosts,
        child: ListView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(),
                  ),
                ).then((_) => _refreshPosts());
              },
              child: Container(
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Appcolor.fillColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.keyboard,
                      color: Appcolor.greyLabelColor,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Write your thought",
                      style: TextStyle(
                        fontSize: 15,
                        color: Appcolor.greyLabelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),

            // Show empty state if no posts and not loading
            if (sortedPosts.isEmpty && !isLoading)
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(child: Text("No posts available")),
              ),

            // Posts list
            ...sortedPosts.map((post) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: PostCard(model: post),
                )),

            // Loading indicator
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Appcolor.buttonBackgroundColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),

            // End of posts message
            if (!hasMorePosts && sortedPosts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text("No more posts")),
              ),

            // Bottom padding
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
