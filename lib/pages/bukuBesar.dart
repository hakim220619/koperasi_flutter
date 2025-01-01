import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class BukuBesar extends StatefulWidget {
  @override
  _BukuBesarState createState() => _BukuBesarState();
}

class _BukuBesarState extends State<BukuBesar> {
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
      _fetchTransactions(id, startDate: startDate, endDate: endDate);
    }
  }

  Future<void> _fetchTransactions(String userId,
      {DateTime? startDate, DateTime? endDate}) async {
    final url = Uri.parse('${dotenv.env['url']}/getbukuBesar');

    final queryParams = {
      if (startDate != null)
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      if (endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(endDate),
    };

    final uri = Uri.parse('${dotenv.env['url']}/getbukuBesar')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        final groupedData = groupBy(data, (item) => item['nama_akun']);
        double saldo = 0.0;

        setState(() {
          transactions = groupedData.entries.map((entry) {
            final accountName = entry.key;
            final accountTransactions = entry.value;

            return {
              'nama_akun': accountName,
              'transaksi': accountTransactions.map((item) {
                saldo += (item['debit'] != null
                        ? double.parse(item['debit'].toString())
                        : 0.0) -
                    (item['kredit'] != null
                        ? double.parse(item['kredit'].toString())
                        : 0.0);

                return {
                  'tanggal': item['tanggal'],
                  'deskripsi': item['deskripsi'],
                  'debit': item['debit'] != null
                      ? double.parse(item['debit'].toString())
                      : 0.0,
                  'kredit': item['kredit'] != null
                      ? double.parse(item['kredit'].toString())
                      : 0.0,
                  'saldo': saldo,
                };
              }).toList(),
            };
          }).toList();
          filteredTransactions = transactions;
          print(filteredTransactions);
          isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
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
          "Buku Besar",
          style: TextStyle(color: Colors.blue[800]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue[800]),
        elevation: 0,
      ),
      body: Column(children: [
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
                onPressed: () {
                  if (userId != null) {
                    _fetchTransactions(
                      userId!,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  }
                },
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
                  padding: const EdgeInsets.all(8.0), // Mengurangi padding
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildGroupedTransactions(),
                        SizedBox(
                            height:
                                16), // Memberi spasi antar bagian jika diperlukan
                      ],
                    ),
                  ),
                ),
              )
      ]),
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

  Widget _buildGroupedTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredTransactions.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header untuk nama akun
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Text(
                '[${group['nama_akun']}]',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            // Tabel untuk transaksi
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                columnWidths: {
                  0: FixedColumnWidth(100.0),
                  1: FixedColumnWidth(160.0),
                  2: FixedColumnWidth(120.0),
                  3: FixedColumnWidth(120.0),
                  4: FixedColumnWidth(120.0),
                },
                border: TableBorder.all(color: Colors.grey, width: 0.7),
                children: [
                  // Baris header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'TANGGAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'NAMA & TRANSAKSI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'DEBIT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'KREDIT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'SALDO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Baris data transaksi
                  ...group['transaksi'].map<TableRow>((transaction) {
                    return TableRow(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            transaction['tanggal'],
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            transaction['deskripsi'],
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction['debit'])}',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction['kredit'])}',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction['saldo'])}',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[400]),
          ],
        );
      }).toList(),
    );
  }
}
