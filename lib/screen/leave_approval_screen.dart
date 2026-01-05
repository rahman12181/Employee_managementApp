import 'package:flutter/material.dart';
import 'package:management_app/model/leave_approved_model.dart';
import '../services/leave_approved_service.dart';
import 'leave_detail_screen.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() =>
      _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState
    extends State<LeaveApprovalScreen> {
  late Future<List<LeaveApprovedModel>> leaveFuture;

  @override
  void initState() {
    super.initState();
    leaveFuture = LeaveApprovedService.fetchLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Application"),
        centerTitle: true,
        leading: const BackButton(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: FutureBuilder<List<LeaveApprovedModel>>(
              future: leaveFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No Leave Found"),
                  );
                }

                final leaves = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      leaveFuture =
                          LeaveApprovedService.fetchLeaves();
                    });
                  },
                  child: ListView.builder(
                    itemCount: leaves.length,
                    itemBuilder: (context, index) {
                      return _leaveCard(leaves[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _leaveCard(LeaveApprovedModel leave) {
    final statusColor = _statusColor(leave.status);
    final statusText = leave.status;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text(
                        leave.employeeName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

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
                        color: statusColor.withAlpha(15),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
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

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}