import 'package:flutter/material.dart';
import 'package:management_app/model/leave_approved_model.dart';
import '../services/leave_approved_service.dart';
import 'leave_detail_screen.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  late Future<List<LeaveApprovedModel>> approvedLeaveFuture;

  @override
  void initState() {
    super.initState();
    approvedLeaveFuture =
        LeaveApprovedService.fetchApprovedLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Application"),
        centerTitle: true,
        leading: const BackButton(),
      ),

      /// ➕ Button (future use)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: FutureBuilder<List<LeaveApprovedModel>>(
              future: approvedLeaveFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Approved Leave Found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final leaves = snapshot.data!;

                return ListView.builder(
                  itemCount: leaves.length,
                  itemBuilder: (context, index) {
                    return _leaveCard(leaves[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Search UI only
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Find Leave Application",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 📄 Leave Card UI
  Widget _leaveCard(LeaveApprovedModel leave) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name + Status
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Employee Name",
                        style:
                            TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leave.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  /// Approved Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LeaveDetailScreen(
                                  leave: leave),
                        ),
                      );
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Approved",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 22),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _info("Leave Type",
                      leave.leaveType),
                  _info("From Date",
                      leave.fromDate),
                  _info("To Date",
                      leave.toDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
