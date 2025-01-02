import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class JurnalUmum extends StatefulWidget {
  @override
  _JurnalUmumState createState() => _JurnalUmumState();
}

class _JurnalUmumState extends State<JurnalUmum> {
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  bool isLoading = true;
  String? userId;
  DateTime? startDate;
  DateTime? endDate;

  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? id = pref.getString('id_user');
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchTransactions(id);
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> _fetchTransactions(String userId) async {
    final url = Uri.parse('${dotenv.env['url']}/getbukuBesar');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        double saldo = 0.0;
        setState(() {
          transactions = data.map((item) {
            
            return {
              'tanggal': item['tanggal'],
              'nama_akun': item['nama_akun'],
              'debit': item['debit'],
              'kredit': item['kredit'],
              'deskripsi': item['deskripsi'],
            };
          }).toList();

          filteredTransactions =
              transactions; // Initialize filteredTransactions with all data
          isLoading = false;
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          startDateController.text =
              DateFormat('dd MMM yyyy').format(startDate!);
        } else {
          endDate = picked;
          endDateController.text = DateFormat('dd MMM yyyy').format(endDate!);
        }
      });
    }
  }

  void _filterTransactions() {
  if (startDate == null || endDate == null) {
    setState(() {
      filteredTransactions =
          transactions; // Jika tidak ada filter tanggal, tampilkan semua transaksi
    });
    return;
  }

  DateTime startDateNormalized =
      DateTime(startDate!.year, startDate!.month, startDate!.day);
  DateTime endDateNormalized =
      DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59, 999);

  setState(() {
    filteredTransactions = transactions.where((transaction) {
      DateTime transactionDate =
          DateFormat('yyyy-MM-dd').parse(transaction['tanggal']);
      // Pastikan hanya mencakup tanggal mulai hingga tanggal akhir
      return !transactionDate.isBefore(startDateNormalized) &&
          !transactionDate.isAfter(endDateNormalized);
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jurnal Umum",
          style: TextStyle(color: Colors.blue[800]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue[800]),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.blue[800]!),
                      ),
                      child: Center(
                        child: Text(
                          startDate == null
                              ? "Start Date"
                              : DateFormat('dd MMM yyyy').format(startDate!),
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.blue[800]!),
                      ),
                      child: Center(
                        child: Text(
                          endDate == null
                              ? "End Date"
                              : DateFormat('dd MMM yyyy').format(endDate!),
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _filterTransactions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Text(
                    "Cari",
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            DataTable(
                              columns: [
                                DataColumn(
                                  label: Text("Tanggal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800])),
                                ),
                                DataColumn(
                                  label: Text("Nama Akun ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800])),
                                ),
                                DataColumn(
                                  label: Text("Debit",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800])),
                                ),
                                DataColumn(
                                  label: Text("Kredit",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800])),
                                ),
                                DataColumn(
                                  label: Text("Keterangan Transaksi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800])),
                                ),
                               
                              ],
                              rows: filteredTransactions.map((transaction) {
                                return DataRow(cells: [
                                  DataCell(Text(transaction['tanggal'] ?? '',
                                      style: TextStyle(color: Colors.black))),
                                  DataCell(Text(transaction['nama_akun'] ?? '',
                                      style: TextStyle(color: Colors.black))),
                                  DataCell(Text(
                                      transaction['debit'].toString() ?? '',
                                      style: TextStyle(color: Colors.black))),
                                  DataCell(Text(transaction['kredit'].toString() ?? '',
                                      style: TextStyle(color: Colors.black))),
                                  DataCell(Text(
                                      transaction['deskripsi'].toString() ?? '',
                                      style: TextStyle(color: Colors.black))),
                                 
                                ]);
                              }).toList(),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[800],
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: IconButton(
            iconSize: 60,
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
