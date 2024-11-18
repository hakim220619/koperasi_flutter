import 'package:flutter/material.dart';

class LaporanKeuangan extends StatefulWidget {
  @override
  _LaporanKeuanganState createState() => _LaporanKeuanganState();
}

class _LaporanKeuanganState extends State<LaporanKeuangan> {
  String selectedTab = 'Laba Rugi';

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
                      buildTable([
                        ['Pendapatan', 'Keterangan', 'Jumlah'],
                        ['Penjualan Produk', 'Total Penjualan', '200.000.000'],
                        ['Pendapatan Lain', 'Pendapatan Sewa', '10.000.000'],
                        ['Total Pendapatan', '', '210.000.000'],
                        ['Beban', '', ''],
                        ['Beban Gaji', 'Biaya Karyawan', '50.000.000'],
                        ['Beban Sewa', 'Sewa tempat', '15.000.000'],
                        ['Total Beban', '', '65.000.000'],
                        ['Laba Bersih', '', '145.000.000'],
                      ]),
                    if (selectedTab == 'Posisi Keuangan')
                      buildSection('Laporan Posisi Keuangan'),
                    if (selectedTab == 'Posisi Keuangan')
                      buildTable([
                        ['Aktiva', 'Keterangan', 'Jumlah'],
                        ['Kas di Bank', 'Saldo Kas di rek', '50.000.000'],
                        ['Kas di Tangan', 'Uang Tunai dimiliki', '5.000.000'],
                        ['Piutang Usaha', 'Utang Anggota', '20.000.000'],
                        ['Persediaan', 'Barang belum terjual', '30.000.000'],
                        ['Total Aktiva Lancar', '', '105.000.000'],
                        ['Aktiva Tetap', '', ''],
                        ['Tanah dan Bangunan', 'Lokasi Koperasi', '200.000.000'],
                        ['Peralatan Dapur', 'Peralatan Kulkas dll', '50.000.000'],
                        ['Peralatan Kantor', 'Printer dll', '30.000.000'],
                        ['Perlengkapan Kantin', 'Meja dll', '20.000.000'],
                        ['Akumulasi Penyusutan', 'Penyusutan aset tetap', '-30.000.000'],
                        ['Nilai Buku Aktiva Tetap', '', '370.000.000'],
                        ['Total Aktiva', '', '475.000.000'],
                      ]),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Aksi cetak
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
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
      },
      children: rows.map((row) {
        return TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[100], // Warna latar belakang lebih rapi
          ),
          children: row.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
