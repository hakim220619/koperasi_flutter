import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from API
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userId = pref.getString('id_user');
    if (userId == null) {
      print('User ID not found in SharedPreferences');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${dotenv.env['url']}/detail_simpanan/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load data: $e');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          "Koperasi Konsumen Polbeng",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _data.isEmpty
                ? Center(child: Text("Tidak ada data yang tersedia"))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTitle("Grafik Tahun 2023"),
                              SizedBox(height: 8),
                              _buildChart(),
                              SizedBox(height: 16),
                              _buildFinancialSummary(),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
      ),
       bottomNavigationBar: BottomAppBar(
        color: Colors.blue[800],
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: IconButton(
            iconSize: 60,
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
               Navigator.pushNamed(context, '/profile');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.blue[800],
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconOption("Jurnal\nUmum", Icons.receipt, onTap: () {
            Navigator.pushNamed(context, '/jurnalUmum');
          }),
          _buildIconOption("Simpanan", Icons.account_balance_wallet, onTap: () {
            Navigator.pushNamed(context, '/simpanan');
          }),
          _buildIconOption("Laporan\nKeuangan", Icons.pie_chart, onTap: () {
            Navigator.pushNamed(context, '/LaporanKeuangan');
          }),
          _buildIconOption("Buku Besar", Icons.bar_chart, onTap: () {
             Navigator.pushNamed(context, '/bukuBesar');
          }),
        ],
      ),
    );
  }

  Widget _buildIconOption(String title, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }

  Widget _buildChart() {
    final List<BarChartGroupData> barGroups = [
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: _data['total_saldo'] != null
                ? double.parse(_data['total_saldo'].replaceAll('.', '')) /
                    1000000
                : 0,
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: _data['total_setoran'] != null
                ? double.parse(_data['total_setoran'].replaceAll('.', '')) /
                    1000000
                : 0,
            color: Colors.green,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: _data['pengeluaran'] != null
                ? double.parse(_data['pengeluaran'].replaceAll('.', '')) /
                    1000000
                : 0,
            color: Colors.red,
            width: 20,
          ),
        ],
      ),
    ];

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()} JT');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text;
                  switch (value.toInt()) {
                    case 1:
                      text = 'Saldo';
                      break;
                    case 2:
                      text = 'Setoran';
                      break;
                    case 3:
                      text = 'Pengeluaran';
                      break;
                    default:
                      text = '';
                  }
                  return Text(text);
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFinancialRow("Keuntungan", _data['total_saldo']),
        _buildFinancialRow("Pemasukan", _data['total_setoran']),
        _buildFinancialRow("Pengeluaran", _data['pengeluaran']),
      ],
    );
  }

  Widget _buildFinancialRow(String title, String? value,
      {bool isBold = false}) {
    double parsedValue = 0.0;

    if (value != null && value.isNotEmpty) {
      try {
        // Hapus semua tanda pemisah ribuan
        parsedValue = double.parse(value.replaceAll('.', ''));
      } catch (e) {
        print('Error parsing value: $value, error: $e');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Text(
            parsedValue.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    Navigator.of(context).pushReplacementNamed('/login');
  }
}
