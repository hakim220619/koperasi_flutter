import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpananScreen extends StatefulWidget {
  @override
  _SimpananScreenState createState() => _SimpananScreenState();
}

class _SimpananScreenState extends State<SimpananScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  // Fetch data from API
  Future<void> fetchData() async {
    // Get the user ID from SharedPreferences
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userId = pref.getString('id_user');
    if (userId == null) {
      print('User ID not found in SharedPreferences');
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
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Simpanan Anggota",
            style: TextStyle(color: const Color.fromARGB(255, 254, 255, 255)),
          ),
          backgroundColor: Colors.blue[800],
          iconTheme:
              IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.blue[200],
            tabs: [
              Tab(text: "Rincian"),
              Tab(text: "Setoran"),
              Tab(text: "Penarikan"),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTabContent(
                    _data['rincian'],
                    'Total Saldo',
                    'Rp ${_data['total_saldo']}',
                  ),
                  _buildTabContent(
                    _data['setoran'],
                    'Total Setoran',
                    'Rp ${_data['total_setoran']}',
                  ),
                  _buildTabContent(
                    _data['penarikan'],
                    'Penarikan',
                    'Rp ${_data['pengeluaran']}',
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
      ),
    );
  }

  Widget _buildTabContent(
      List<dynamic> items, String totalBalanceTitle, String totalBalance) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Display each deposit in the tab
          ...items.map<Widget>((item) {
            return _buildDepositCard(item['title'], "Rp ${item['amount']}");
          }).toList(),
          // Wrap the total balance with an Expanded widget to keep it at the bottom
          Expanded(
            child: Container(),
          ),
          _buildTotalBalance(totalBalanceTitle, totalBalance),
        ],
      ),
    );
  }

  Widget _buildDepositCard(String title, String amount) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 16, color: Colors.blue[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalance(String title, String amount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, color: Colors.white),
          SizedBox(width: 8),
          Column(
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                amount,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
