import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
// ignore: library_prefixes
import 'package:intl/intl.dart' as Date;
import 'package:shimmer/shimmer.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/models/post_model.dart';
import 'package:urms_ulab/provider/firebase_provider.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel model;
  final bool isMySelf;

  const PostCard({
    super.key,
    required this.model,
    this.isMySelf = false,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool isExpanded = false;

  late Future<dynamic> postCreatorfuture;

  @override
  void initState() {
    super.initState();
    postCreatorfuture =
        ref.read(firebaseProvider).getProfileById(widget.model.postCreatorID);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ref.read(firebaseProvider).getPostByPostID(widget.model.postId),
        builder: (context, postShot) {
          return FutureBuilder(
              future: postCreatorfuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 80,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Appcolor.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(
                              snapshot.data!.profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Appcolor.fillColor,
                                  child: Icon(
                                    Icons.person,
                                    size: 25,
                                    color: Appcolor.primaryColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        isThreeLine: true,
                        title: Text(
                          snapshot.data!.name,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Row(
                          spacing: 10,
                          children: [
                            Text(
                              snapshot.data!.department,
                              style: TextStyle(
                                fontSize: 11,
                                color: Appcolor.greyLabelColor,
                              ),
                            ),
                            Text(
                              snapshot.data!.studentId,
                              style: TextStyle(
                                fontSize: 11,
                                color: Appcolor.greyLabelColor,
                              ),
                            ),
                            Spacer(),
                            Text(
                              Date.DateFormat("dd MMM yyyy hh:mm a")
                                  .format(widget.model.postCreatedAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Appcolor.greyLabelColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: (widget.isMySelf)
                            ? IconButton(
                                onPressed: () async {
                                  {
                                    await ref.read(firebaseProvider).deletePost(
                                          postID: widget.model.postId,
                                        );
                                  }
                                },
                                icon: Icon(
                                  Iconsax.trash,
                                  size: 20,
                                  color: Appcolor.redColor,
                                ),
                              )
                            : null,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Check if the text exceeds 3 lines
                          final textSpan = TextSpan(
                            text: widget.model.postDescription,
                            style: TextStyle(fontSize: 13),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            maxLines: isExpanded ? null : 3,
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: constraints.maxWidth);

                          final bool exceedsMaxLines =
                              textPainter.didExceedMaxLines;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  isExpanded = false;
                                  setState(() {});
                                },
                                child: Text(
                                  widget.model.postDescription,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(fontSize: 13),
                                  maxLines: isExpanded ? null : 3,
                                  overflow: isExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),
                              ),
                              if (exceedsMaxLines)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      isExpanded ? "See less" : "See more",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              if ((postShot.data?.postReactorIDs ?? [])
                                  .contains(
                                      ref.read(sharedPrefProvider).studentID)) {
                                (postShot.data?.postReactorIDs ?? []).remove(
                                    ref.read(sharedPrefProvider).studentID);
                              } else {
                                (postShot.data?.postReactorIDs ?? []).add(
                                    ref.read(sharedPrefProvider).studentID!);
                              }
                              (postShot.data?.postReactorIDs ?? []).contains(
                                      ref.read(sharedPrefProvider).studentID)
                                  ? await ref.read(firebaseProvider).updatePost(
                                        postID: widget.model.postId,
                                        updatedData: widget.model.copyWith(
                                          postReactorIDs:
                                              (postShot.data?.postReactorIDs ??
                                                  []),
                                        ),
                                      )
                                  : await ref.read(firebaseProvider).updatePost(
                                        postID: widget.model.postId,
                                        updatedData: widget.model.copyWith(
                                          postReactorIDs:
                                              (postShot.data?.postReactorIDs ??
                                                  []),
                                        ),
                                      );
                              setState(() {});
                            },
                            icon: Icon(
                              (postShot.data?.postReactorIDs ?? []).contains(
                                      ref.read(sharedPrefProvider).studentID)
                                  ? Iconsax.heart5
                                  : Iconsax.heart,
                              color: (postShot.data?.postReactorIDs ?? [])
                                      .contains(ref
                                          .read(sharedPrefProvider)
                                          .studentID)
                                  ? Colors.red
                                  : Colors.grey,
                              size: 20,
                            ),
                          ),
                          Text(
                            '${(postShot.data?.postReactorIDs ?? []).length} likes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Appcolor.greyLabelColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
        });
  }
}
