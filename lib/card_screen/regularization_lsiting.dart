import 'package:flutter/material.dart';

class RegularizationLsiting  extends StatefulWidget{
  const RegularizationLsiting({super.key});

  @override
  State<RegularizationLsiting> createState()=> _RegularizationLsitingState();
}

class _RegularizationLsitingState extends State<RegularizationLsiting>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:  Center(
        child: Text("Approval listing",style: TextStyle(fontSize: 30),)
       ),
    );
  }

}