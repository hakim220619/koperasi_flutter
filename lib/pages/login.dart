import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:koperasi/pages/dashboard.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static final _client = http.Client();
  static final _loginUrl = Uri.parse('${dotenv.env['url']}/login');

  Future<void> _login(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      EasyLoading.showError('Username dan Password harus diisi');
      return;
    }

    EasyLoading.show(status: 'Loading...');
    try {
      final response = await _client.post(
        _loginUrl,
        body: {"username": username, "password": password},
      );
      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);
        print(userData['user']);
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("username", username);
        await pref.setString("id_user", userData['user']['id_user'].toString());
        await pref.setString("full_name", userData['user']['full_name'].toString());
        await pref.setString("tlp", userData['user']['tlp'].toString());
        await pref.setString("pekerjaan", userData['user']['pekerjaan'].toString());
        await pref.setString("jabatan", userData['user']['jabatan'].toString());
        await pref.setString("alamat", userData['user']['alamat'].toString());
        await pref.setString("image", userData['user']['image'].toString());
        await pref.setString("is_active", userData['user']['is_active'].toString());
        await pref.setBool("is_login", true);
        EasyLoading.dismiss();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
          (route) => false,
        );
      } else {
        EasyLoading.showError('Login Gagal');
      }
    } catch (e) {
      EasyLoading.showError('Terjadi kesalahan');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bagian header dengan warna background
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 0, 112, 240),
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Text(
                        "Koperasi\nKonsumen",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Polbeng",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.yellow[700],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Form input untuk Username
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Form input untuk Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Tombol Login
                ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.blue[800],
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Teks untuk registrasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum Punya akun? "),
                    GestureDetector(
                      onTap: () {
                        // Aksi ketika teks 'Register' ditekan
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
