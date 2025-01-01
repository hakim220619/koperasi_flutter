import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Pastikan dotenv digunakan untuk environment variables

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> profileData = {
    'Nama': '',
    'ID Anggota': '',
    'Jabatan': '',
    'Anggota Aktif': '',
    'Pekerjaan': '',
    'Telepon': '',
    'Alamat': '',
    'image': '',
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      profileData['Nama'] = pref.getString("full_name") ?? "N/A";
      profileData['ID Anggota'] = pref.getString("id_user") ?? "N/A";
      profileData['Jabatan'] = pref.getString("jabatan") ?? "N/A";
      profileData['Anggota Aktif'] =
          (pref.getString("is_active") == "Y") ? "Aktif" : "Tidak Aktif";
      profileData['Pekerjaan'] = pref.getString("pekerjaan") ?? "N/A";
      profileData['Telepon'] = pref.getString("tlp") ?? "N/A";
      profileData['Alamat'] = pref.getString("alamat") ?? "N/A";
      profileData['image'] = pref.getString("image") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = profileData['image']!.isEmpty
        ? 'https://via.placeholder.com/150'
        : '${dotenv.env['urlImage']}/assets/foto/user/${profileData['image']}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Kembali'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(height: 10),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: profileData.entries.map((entry) {
                return ProfileInfoRow(label: entry.key, value: entry.value);
              }).toList(),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _logout(context);
                  },
                  child: Text(
                    'Keluar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
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

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
