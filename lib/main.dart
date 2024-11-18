import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koperasi/pages/RiwayatTransaksi.dart';
import 'package:koperasi/pages/Simpanan.dart';
import 'package:koperasi/pages/dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koperasi/pages/laporanKeuangan.dart';
import 'package:koperasi/pages/login.dart'; // Pastikan file LoginScreen sudah ada

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Koperasi App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          initialRoute: "/login", // Mengarahkan ke login screen
          onGenerateRoute: _onGenerateRoute,
          builder: EasyLoading.init(),
        );
      },
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => Dashboard());
      case '/simpanan':
        return MaterialPageRoute(builder: (_) => SimpananScreen());
      case '/riwayat_transaksi':
        return MaterialPageRoute(builder: (_) => RiwayatTransaksiScreen());
      case '/LaporanKeuangan':
        return MaterialPageRoute(builder: (_) => LaporanKeuangan());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
