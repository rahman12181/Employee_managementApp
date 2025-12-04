import 'package:flutter/material.dart';
import 'package:management_app/utils/checkuser_util.dart';
import 'package:management_app/utils/systembars_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  }
  
  class _SplashScreenState extends State<SplashScreen> 
  with SingleTickerProviderStateMixin {

    String fullText = "Management_App";
    String displayedText = "";
    int index = 0;

    late AnimationController controller;
    late Animation<double> positionAnimation;
    late Animation<double> opacityAnimation;
      
    @override
    void initState(){
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_){
        SystembarUtil.setSystemBar(context);
      });

      controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 2),
        );

        positionAnimation = Tween<double>(
          begin: 1,
          end: 0.4)
          .animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );

        opacityAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeIn),
        );
        controller.forward();

        controller.addStatusListener((status) {
         if (status == AnimationStatus.completed) {
           startTyping();
           WidgetsBinding.instance.addPostFrameCallback((_){
            if(!mounted) return;
           // Navigator.pushReplacementNamed(context, '/loginScreen');
           // CheckuserUtils.checkUser(context);
           });    // typing animation starts after logo stops
         }
       });


    }
     Future<void> startTyping() async {
       for (int i = 0; i < fullText.length; i++) {
         await Future.delayed(const Duration(milliseconds: 50));
         
          if (!mounted) return;
          setState(() {
             displayedText = fullText.substring(0, i + 1);
            });
       }
       Navigator.pushReplacementNamed(context, '/loginScreen');
     }


    @override
    void dispose(){
      controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;


    return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: AnimatedBuilder(
      animation: controller,
      builder: (context , child){
        return Stack(
          children: [
              Positioned(
              top: screenHeight * positionAnimation.value,
              left: screenWidth * 0.35,
              child: SizedBox(
                width: screenWidth *0.3,
                  child: ClipOval(
                  child: Image.asset("assets/images/app_icon.png",fit: BoxFit.cover,),
                ),
              ),
            ),
          
            Positioned(
             top: (screenHeight * positionAnimation.value) + (screenWidth * 0.3) + 20,
             left: 0,
             right: 0,
             child: Opacity(
               opacity: opacityAnimation.value,
                child: Center(
                child:  Text(
                  displayedText, 
                  textAlign: TextAlign.center,// typing wala text
                   style: TextStyle(
                   fontFamily: "Poppins",
                   fontSize: screenHeight * 0.02,
                   fontWeight: FontWeight.bold,
                   color: Colors.black,
                 ),
               ),
              )
             ),
            ),
          ],
        );
      }),
    ),
   );
  }
}