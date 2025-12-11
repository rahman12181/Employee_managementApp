import 'package:flutter/material.dart';

class Leaverequest extends StatefulWidget{
  const Leaverequest({super.key});

  @override
  State<Leaverequest> createState()=> _LeaverequestState();
}

class _LeaverequestState extends State<Leaverequest>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Leave Request Screen",style: TextStyle(fontSize: 30),),
    );
  }
}