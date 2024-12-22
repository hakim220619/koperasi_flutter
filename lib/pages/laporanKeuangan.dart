import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // Importing http package
import 'dart:convert'; // Importing dart:convert for JSON decoding
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanKeuangan extends StatefulWidget {
  @override
  _LaporanKeuanganState createState() => _LaporanKeuanganState();
}

class _LaporanKeuanganState extends State<LaporanKeuangan> {
  String selectedTab = 'Laba Rugi';

  Future<List<List<String>>> fetchData() async {
    final response =
        await http.get(Uri.parse('${dotenv.env['url']}/getbukuBesarKredit'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      Map<String, List<List<String>>> groupedData = {};
      Map<String, double> subtotals = {};

      for (var item in jsonData) {
        String kelompok = item['kelompok'];
        // Only process items with 'kelompok' of 'Pendapatan' or 'Beban'
        if (kelompok == "Pendapatan" || kelompok == "Beban") {
          double kredit = double.parse(item['kredit'].toString());
          if (!groupedData.containsKey(kelompok)) {
            groupedData[kelompok] = [];
            subtotals[kelompok] = 0.0; // Initialize subtotal for this group
          }
          groupedData[kelompok]!.add(
              [kelompok, item['deskripsi'], 'Rp ${kredit.toStringAsFixed(2)}']);
          subtotals[kelompok] =
              subtotals[kelompok]! + kredit; // Sum up the credits
        }
      }

      List<List<String>> tableData = [
        ['Kelompok', 'Deskripsi', 'Jumlah']
      ];
      groupedData.forEach((kelompok, rows) {
        tableData.addAll(rows);
        tableData.add([
          '',
          'Total $kelompok',
          'Rp ${subtotals[kelompok]!.toStringAsFixed(2)}'
        ]);
      });

      return tableData;
    } else {
      throw Exception('Failed to load data');
    }
  }

 Future<List<List<String>>> fetchPosisiKeuanganData() async {
  final response = await http.get(Uri.parse('${dotenv.env['url']}/getbukuBesar'));
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    if (jsonData != null) {
      Map<String, List<List<String>>> groupedData = {};
      Map<String, double> subtotals = {};

      for (var item in jsonData) {
        String category = item['kelompok'] ?? 'Uncategorized'; // Default to 'Uncategorized' if null

        // Filter to only include 'Pendapatan' or 'Beban'
        if (category == "Pendapatan" || category == "Beban") {
          continue; // Skip this iteration if category is not what we want
        }

        double amount = double.tryParse(item['debit']?.toString() ?? '0') ?? 0; // Safely parse and handle null and non-existent 'amount'

        if (!groupedData.containsKey(category)) {
          groupedData[category] = [];
          subtotals[category] = 0.0;
        }
        groupedData[category]?.add([
          category,
          item['deskripsi'] ?? 'No description',
          'Rp ${amount.toStringAsFixed(2)}'
        ]);
        subtotals[category] = subtotals[category]! + amount; // Safely add to subtotal, assuming it's already initialized
      }

      List<List<String>> tableData = [['Kategori', 'Deskripsi', 'Jumlah']];
      groupedData.forEach((category, rows) {
        tableData.addAll(rows);
        tableData.add(['', 'Total $category', 'Rp ${subtotals[category]!.toStringAsFixed(2)}']); // Force-unwrapping is safe here
      });

      return tableData;
    } else {
      throw Exception('JSON data is null');
    }
  } else {
    throw Exception('Failed to load data with status code: ${response.statusCode}');
  }
}

Future<void> printPdf() async {
    final pdf = pw.Document();
    final data = selectedTab == 'Laba Rugi'
        ? await fetchData()
        : await fetchPosisiKeuanganData();

    pdf.addPage(pw.MultiPage(
        build: (context) => [
              pw.Table.fromTextArray(
                  context: context,
                  data: data,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                  }),
            ]));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    fetchPosisiKeuanganData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan Keuangan",
          style: TextStyle(color: Colors.blue[800]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue[800]),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.blue[800],
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedTab = 'Laba Rugi';
                      });
                    },
                    child: Text(
                      'Laporan Laba Rugi',
                      style: TextStyle(
                        color: selectedTab == 'Laba Rugi'
                            ? Colors.yellow
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedTab = 'Posisi Keuangan';
                      });
                    },
                    child: Text(
                      'Laporan Posisi Keuangan',
                      style: TextStyle(
                        color: selectedTab == 'Posisi Keuangan'
                            ? Colors.yellow
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Koperasi Konsumen Polbeng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (selectedTab == 'Laba Rugi')
                      buildSection('Laporan Laba Rugi'),
                    if (selectedTab == 'Laba Rugi')
                      FutureBuilder<List<List<String>>>(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return buildTable(snapshot.data!);
                          }
                        },
                      ),
                    if (selectedTab == 'Posisi Keuangan')
                      buildSection('Laporan Posisi Keuangan'),
                    if (selectedTab == 'Posisi Keuangan')
                      FutureBuilder<List<List<String>>>(
                        future: fetchPosisiKeuanganData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return buildTable(snapshot.data!);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
              printPdf();
              },
              child: Text('Cetak'),
            ),
          ),
          // Bottom Profile Icon
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.person, size: 40, color: Colors.grey[600]),
                onPressed: () {
                  // Aksi pada ikon profil
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
Widget buildTable(List<List<String>> rows) {
  return Container(
    color: Colors.white, // Ensures the table background is white
    padding: EdgeInsets.all(8.0), // Adds padding around the table
    child: Table(
      border: TableBorder.all(color: Colors.grey),
      children: rows.map((List<String> row) {
        return TableRow(
          children: List<Widget>.generate(
            3,
            (index) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              alignment: index == 2 ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                index < row.length ? row[index] : '', // Fill missing entries with empty strings
                style: TextStyle(
                  color: Colors.black, // Ensures text color is black for contrast
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

  // Method to fetch data from API
}
