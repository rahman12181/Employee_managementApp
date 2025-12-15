import 'package:flutter/material.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "poppins"),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - kToolbarHeight,
          child: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final user = provider.profileData;

              return Column(
                children: [
                  SizedBox(height: screenHeight * 0.08),

                  Center(
                    child: Hero(
                      tag: 'profile-hero',
                      child: Container(
                        width: screenWidth * 0.6,
                        height: screenHeight * 0.32,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(120),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image:
                                (user != null &&
                                    user['user_image'] != null &&
                                    user['user_image'] != "")
                                ? NetworkImage(
                                    "https://ppecon.erpnext.com${user['user_image']}",
                                  )
                                : const AssetImage("assets/images/app_icon.png")
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.06),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        user != null && user['full_name'] != null
                            ? user['full_name']
                            : "Loading...",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user != null && user['email'] != null
                            ? user['email']
                            : "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
