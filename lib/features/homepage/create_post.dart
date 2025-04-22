import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/models/post_model.dart';
import 'package:urms_ulab/models/profile_model.dart';
import 'package:urms_ulab/provider/firebase_provider.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  TextEditingController postController = TextEditingController();

  bool isloading = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Create your post",
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  maximumSize: Size(double.maxFinite, 45),
                  minimumSize: Size(double.maxFinite, 45),
                  backgroundColor: Appcolor.buttonBackgroundColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isloading = true;
                    });
                    // Assuming you have a method to create a post
                    await ref.read(firebaseProvider).createpost(
                          post: PostModel(
                            postDescription: postController.text,
                            postCreatorID: ((await Scapper.fetchData(
                              title: "Profile",
                              designatedurl:
                                  "https://urms-online.ulab.edu.bd/profile.php",
                              cookie: ref.read(sharedPrefProvider).token!,
                            ) as FetchSuccess)
                                    .data as Profile)
                                .studentId,
                          ),
                        );
                    setState(() {
                      isloading = false;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text("Post"),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        cursorColor: Appcolor.textColor,
                        controller: postController,
                        minLines: 2,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: "Write or share with us",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Appcolor.fillColor,
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isloading)
          Container(
            color: Colors.white.withOpacity(0.4),
            child: Center(
              child: CircularProgressIndicator(
                color: Appcolor.buttonBackgroundColor,
                strokeCap: StrokeCap.round,
              ),
            ),
          )
      ],
    );
  }
}
