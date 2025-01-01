import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:jupiter_academy/core/services/firebase_api.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late String selectedValue;
  List<Map<String, dynamic>> shiftsToEdit = [];

  Future<Map<String, dynamic>> _fetchInitialData() async {
    try {
      // 1. جلب الأشهر المتاحة من فايربيز
      QuerySnapshot snapshot = await FirebaseApi.getMonthsforRequests();

      List<String> months = snapshot.docs.map((doc) => doc.id).toList();
      months.sort((a, b) => a.compareTo(b)); // ترتيب من الأقدم للأحدث

      if (months.isNotEmpty) {
        selectedValue = months.last; // اختيار أحدث شهر

        // 2. جلب الطلبات للشهر الأحدث
        QuerySnapshot requestsSnapshot =
            await FirebaseApi.getRequestsForMonth(selectedValue);

        List<Map<String, dynamic>> shifts = requestsSnapshot.docs.map((doc) {
          return {
            'name': doc.id,
            'requestType': doc['requestType'] ?? 'N/A',
            'date': doc['requestDetails']['date'] ?? 'N/A',
            'checkIn': doc['requestDetails']['checkIn'] ?? 'N/A',
            'checkOut': doc['requestDetails']['checkOut'] ?? 'N/A',
          };
        }).toList();

        return {'months': months, 'shifts': shifts};
      }
    } catch (e) {
      print('Error: $e');
    }

    return {'months': [], 'shifts': []};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchInitialData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading data.'));
          }

          final months = (snapshot.data!['months'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();

          shiftsToEdit = (snapshot.data!['shifts'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          selectedValue = months.isNotEmpty ? selectedValue : '';

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  items: months
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (String? value) async {
                    if (value != null) {
                      setState(() {
                        selectedValue = value;
                      });
                      // تحديث البيانات حسب الشهر المحدد
                      QuerySnapshot requestsSnapshot =
                          await FirebaseApi.getRequestsForMonth(value);

                      setState(() {
                        shiftsToEdit = requestsSnapshot.docs.map((doc) {
                          return {
                            'requestType': doc['requestType'] ?? 'N/A',
                            'date': doc['requestDetails']['date'] ?? 'N/A',
                            'checkIn':
                                doc['requestDetails']['checkIn'] ?? 'N/A',
                            'checkOut':
                                doc['requestDetails']['checkOut'] ?? 'N/A',
                          };
                        }).toList();
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: shiftsToEdit.isEmpty
                    ? const Center(child: Text('No shifts available'))
                    : ListView.builder(
                        itemCount: shiftsToEdit.length,
                        itemBuilder: (context, index) {
                          final shift = shiftsToEdit[index];
                          return Card(
                            child: ListTile(
                              title: Text('Date: ${shift['date']}'),
                              subtitle: Text(
                                  'Check-in: ${shift['checkIn']} | Check-out: ${shift['checkOut']}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
