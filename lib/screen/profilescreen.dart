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
    double screeWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "poppins"),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  final user = provider.profileData;

                  return Column(
                    children: [
                      Container(
                        width: screeWidth * 0.6,
                        height: screenHeight * 0.15,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                (user != null &&user['user_image'] != null && user['user_image'] != "")
                                ? NetworkImage(
                                    "https://ppecon.erpnext.com${user['user_image']}",
                                  )
                                : const AssetImage("assets/images/app_icon.png")
                                      as ImageProvider,
                            fit: BoxFit.cover, 
                          ),
                        ),
                      ),
                        SizedBox(height: screenHeight * 0.02),
                          Text(
                            user != null && user['full_name'] != null
                                ? user['full_name']
                                : "Loading...",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            user != null && user['email'] != null
                                ? user['email']
                                : "",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                  
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
