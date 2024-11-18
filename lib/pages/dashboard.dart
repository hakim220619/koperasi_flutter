import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png', // Ganti dengan path logo yang sesuai
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
              // Memanggil fungsi logout untuk menghapus data SharedPreferences dan pindah ke halaman Login
              await _logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.blue[800],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconOption("Riwayat\nTransaksi", Icons.receipt, onTap: () {
                          Navigator.pushNamed(context, '/riwayat_transaksi');
                        }),
                        _buildIconOption("Simpanan", Icons.account_balance_wallet, onTap: () {
                          Navigator.pushNamed(context, '/simpanan'); // Navigasi ke halaman Simpanan
                        }),
                        _buildIconOption("Laporan\nKeuangan", Icons.pie_chart, onTap: () {
                          Navigator.pushNamed(context, '/LaporanKeuangan');
                        }),
                        _buildIconOption("Sisa Hasil\nUsaha", Icons.bar_chart, onTap: () {
                          // Aksi ketika Sisa Hasil Usaha diklik
                        }),
                      ],
                    ),
                  ),
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
          Center(
            child: Column(
              children: [
                Icon(Icons.person, color: const Color.fromARGB(255, 243, 243, 243), size: 40),
                SizedBox(height: 8),
                Text("Profile", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          SizedBox(height: 16), // Jarak dari bawah layar
        ],
      ),
    );
  }

  Widget _buildIconOption(String title, IconData icon, {required VoidCallback onTap}) {
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
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ElevatedButton(
          onPressed: () {},
          child: Text("Cari"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      color: Colors.blue[50],
      child: Center(
        child: Text("Grafik Data Placeholder"),
        // Tambahkan chart library seperti `fl_chart` untuk membuat grafik sebenarnya
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFinancialRow("Keuntungan", "Rp 10.000.000"),
        _buildFinancialRow("Pemasukan", "Rp 2.500.000"),
        _buildFinancialRow("Pengeluaran", "Rp 5.000.000"),
        Divider(),
        _buildFinancialRow("Aset", "Rp 30.000.000", isBold: true),
        _buildFinancialRow("Kewajiban", "Rp 10.000.000", isBold: true),
        _buildFinancialRow("Modal", "Rp 20.000.000", isBold: true),
      ],
    );
  }

  Widget _buildFinancialRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.white
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,color: Colors.white
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus data SharedPreferences dan pindah ke halaman Login
  Future<void> _logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("username");
    await pref.remove("id");
    await pref.remove("full_name");
    await pref.remove("is_login");

    // Navigasi ke halaman Login
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
