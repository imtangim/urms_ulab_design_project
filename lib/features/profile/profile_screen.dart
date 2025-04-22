import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/features/auth/login.dart';
import 'package:urms_ulab/features/homepage/post_card.dart';
import 'package:urms_ulab/models/profile_model.dart';
import 'package:urms_ulab/provider/firebase_provider.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<dynamic> profileFuture;

  @override
  void initState() {
    super.initState();

    profileFuture = Scapper.fetchData(
        title: "Profile",
        designatedurl: "https://urms-online.ulab.edu.bd/profile.php",
        cookie: ref.read(sharedPrefProvider).token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Appcolor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          "Student Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Appcolor.white,
                  title: const Text("Logout"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Appcolor.primaryColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(sharedPrefProvider).singout();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false);
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Appcolor.redColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: Appcolor.buttonBackgroundColor,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.data is FetchFailure) {
              return Center(
                child: Text(
                  'Error: ${(snapshot.data as FetchFailure).message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(
                    profile: (snapshot.data as FetchSuccess).data as Profile,
                  ),
                  const SizedBox(height: 16),
                  _buildStatusSection(
                    profile: (snapshot.data as FetchSuccess).data as Profile,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    "Academic Information",
                    profile: (snapshot.data as FetchSuccess).data as Profile,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    "Contact Information",
                    profile: (snapshot.data as FetchSuccess).data as Profile,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    "Address",
                    profile: (snapshot.data as FetchSuccess).data as Profile,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    "Adviser Information",
                    profile: (snapshot.data as FetchSuccess).data as Profile,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder(
                    stream: ref.read(firebaseProvider).getAllPostbyProfileID(
                          profileID:
                              ((snapshot.data as FetchSuccess).data as Profile)
                                  .studentId,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            color: Appcolor.buttonBackgroundColor,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No posts available"),
                        );
                      }
                      return Column(
                        spacing: 10,
                        children: List.generate(
                          snapshot.data!.length,
                          (index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: PostCard(
                                isMySelf:
                                    ref.read(sharedPrefProvider).studentID ==
                                        snapshot.data![index].postCreatorID,
                                model: snapshot.data![index],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildProfileHeader({required Profile profile}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Appcolor.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _buildProfileImage(profile: profile),
            const SizedBox(height: 16),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${profile.studentId} ${profile.department}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${profile.semesterName} (${profile.semester})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage({required Profile profile}) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          profile.profileImageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              color: Appcolor.fillColor,
              child: Icon(
                Icons.person,
                size: 50,
                color: Appcolor.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusSection({required Profile profile}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusCard("Active Status", profile.activeStatus,
              profile.activeStatus == "Active" ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          _buildStatusCard("Payment", profile.paymentStatus,
              profile.paymentStatus == "Ok" ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          _buildStatusCard(
              "Registration",
              profile.registrationStatus,
              profile.registrationStatus == "Completed"
                  ? Colors.green
                  : Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, Color statusColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Appcolor.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Appcolor.greyLabelColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String sectionTitle, {required Profile profile}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Appcolor.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: _buildSectionContent(sectionTitle, profile: profile),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(String sectionTitle, {required Profile profile}) {
    switch (sectionTitle) {
      case "Academic Information":
        return Column(
          children: [
            _buildInfoItem("Department", profile.department, Icons.school),
            const Divider(height: 1),
            _buildInfoItem(
                "Semester",
                "${profile.semesterName} (${profile.semester})",
                Icons.calendar_today),
          ],
        );
      case "Contact Information":
        return Column(
          children: [
            _buildInfoItem("Phone", profile.phoneNumber, Icons.phone),
            const Divider(height: 1),
            _buildInfoItem("ULAB Email", profile.ulabMail, Icons.email),
            const Divider(height: 1),
            _buildInfoItem(
                "Personal Email", profile.personalMail, Icons.alternate_email),
          ],
        );
      case "Address":
        return _buildInfoItem(
            "Present Address", profile.presentAddress, Icons.home,
            isMultiline: true);
      case "Adviser Information":
        return Column(
          children: [
            _buildInfoItem("Adviser Name", profile.adviserName, Icons.person),
            const Divider(height: 1),
            _buildInfoItem("Adviser Email", profile.adviserEmail, Icons.email),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Appcolor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Appcolor.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Appcolor.greyLabelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Appcolor.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildLogoutButton(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: SizedBox(
  //       width: double.infinity,
  //       child: ElevatedButton.icon(
  //         onPressed: () {
  //           showDialog(
  //             context: context,
  //             builder: (context) => AlertDialog(
  //               backgroundColor: Appcolor.white,
  //               title: const Text("Logout"),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               content: const Text("Are you sure you want to logout?"),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   child: Text(
  //                     "Cancel",
  //                     style: TextStyle(
  //                       color: Appcolor.primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     ref.read(sharedPrefProvider).singout();
  //                     Navigator.pushAndRemoveUntil(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => const LoginScreen(),
  //                         ),
  //                         (route) => false);
  //                   },
  //                   child: Text(
  //                     "Logout",
  //                     style: TextStyle(color: Appcolor.redColor),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //         icon: const Icon(Icons.logout, color: Colors.white),
  //         label: const Text(
  //           "Logout",
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.white,
  //           ),
  //         ),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Appcolor.redColor,
  //           padding: const EdgeInsets.symmetric(vertical: 16),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
