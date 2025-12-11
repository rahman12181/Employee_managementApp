import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget{
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState()=> _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{
   bool _isLoading=false;

  final List<String> bannerImages = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
    'assets/images/banner4.png',
    'assets/images/banner5.png',
    'assets/images/banner6.png',
    'assets/images/banner7.png',
  ];

  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Leave Request',
      'subtitle': 'Manage your request',
      'image': 'assets/images/leaverequest.png',
      'type': 'Leave_Request'
    },
    {
      'title': 'Leave Request Detail',
      'subtitle': 'about leave..',
      'image': 'assets/images/leaverequestdetail.png',
      'type': 'Leave_requestDetail'
    },
    {
      'title': 'Leave Approval',
      'subtitle': 'Admin..',
      'image': 'assets/images/leaveapproved.png',
      'type': 'Leave_Approval'
    },
    {
      'title': 'Attendance Regularization',
      'subtitle': 'your logs..',
      'image': 'assets/images/attendanceicon.png',
      'type': 'Attendance_Redularization'
    },
    {
      'title': 'Regularization Approval',
      'subtitle': 'Check your Approval',
      'image': 'assets/images/regapproval.png',
      'type': 'Regularization_Approval'
    },
    {
      'title': 'Regularization Listing',
      'subtitle': 'Reg..list',
      'image': 'assets/images/regularizationlisting.png',
      'type': 'Regularization_Listing'
    },
    {
      'title': 'More',
      'subtitle': 'check more info..',
      'image': 'assets/images/more.png',
      'type': 'Check_More'
    },
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 7));
      if (!mounted) return false;

      setState(() {
        currentIndex = (currentIndex + 1) % bannerImages.length;
      });

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/settingScreen");
              },
              child:Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage("assets/images/profilepic.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ),

            Row(
              children: [
                Image.asset("assets/images/app_icon.png", width: 40),
                SizedBox(width: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "PIONEER\n",
                        style: TextStyle(
                          height: 1,
                          fontFamily: "poppins",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "TECH",
                        style: TextStyle(
                          fontFamily: "poppins",
                          height: 1,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  Navigator.pushNamed(context, "/notificationScreen");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_none,size: 30, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      body:_isLoading ? Center(
        child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,),
      )
      :SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  width:screenWidth * 0.90,
                  height: screenHeight*0.20,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 1500 ),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,

                    child: Image.asset(
                      bannerImages[currentIndex],
                      key: ValueKey(currentIndex),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),

                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                  ),
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return GestureDetector(
                      onTap:  () {
                        setState(() {
                          _isLoading=true;
                        });
                        if (module['type']=='Leave_Request') {
                          Navigator.pushNamed(context, "/leaveRequest").then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        }else if(module['type']=='Leave_requestDetail'){
                          Navigator.pushNamed(context, '/leaveRequestDetail').then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        } else if (module['type']=='Leave_Approval') {
                          Navigator.pushNamed(context, "/leaveApproval").then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        }else if (module['type']=='Attendance_Redularization') {
                          Navigator.pushNamed(context, "/attendanceRegularization").then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        }
                        else if (module['type']=='Regularization_Approval') {
                          Navigator.pushNamed(context, "/regularizationApproval").then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        }
                        else if (module['type']=='Regularization_Listing') {
                          Navigator.pushNamed(context, "/regularizationListing").then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        }else if (module['type']=='Check_More') {
                          Navigator.pushNamed(context, "/checkMore").then((_){
                            setState(() {
                              _isLoading=false;
                            });
                          });
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("internal issue",style: TextStyle(fontFamily: "poppins",fontSize: 15),),
                            duration: Duration(microseconds: 1500),
                            )
                          );
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadowColor: const Color.fromARGB(255, 220, 210, 209),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  module['image'],
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                module['title'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "poppins",
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                module['subtitle'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontFamily: "poppins",
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}