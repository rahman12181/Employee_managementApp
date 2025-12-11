import 'package:flutter/material.dart';

class AttendanceRegularization  extends StatefulWidget{
  const AttendanceRegularization({super.key});

   @override
     State<AttendanceRegularization> createState()=>_AttendanceRegularizationState();
}

class _AttendanceRegularizationState  extends State<AttendanceRegularization>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:  Text("Attendance Screen",style: TextStyle(fontSize: 30),),
      ),
    );
  }
}