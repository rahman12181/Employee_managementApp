import 'package:flutter/material.dart';

class AttendenceScreen extends StatefulWidget{
  const AttendenceScreen({super.key});

  @override
  State<AttendenceScreen> createState() => _AttendenceScreenState();
}

class _AttendenceScreenState extends State<AttendenceScreen> {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
     child:  Text("This is our Attendance Screen"),
    ),
  );
  }
  
}