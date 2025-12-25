import 'package:flutter/material.dart';

class LeaveRequestdetail extends StatefulWidget{
  const LeaveRequestdetail({super.key});

  @override
  State<LeaveRequestdetail> createState()=> _LeaveRequestdetailState();
}

class _LeaveRequestdetailState extends State<LeaveRequestdetail>{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
       child:  Text("Leave detail screen",style: TextStyle(fontSize: 30),),
      )
    );
  }
}