import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Builder(
        builder: (context) {
          // ผูก callback ตรงนี้ — ให้เข้าถึง AuthProvider ผ่าน context ได้
          ApiClient.onUnauthorized = () {
            context.read<AuthProvider>().forceLogout();
            context.read<NotificationProvider>().disconnect();
          };

          return MaterialApp(
            title: 'MiniMart',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();

    // ถ้ามี session ค้างอยู่ (auto-login สำเร็จ) ให้เชื่อม socket ทันที
    if (authProvider.status == AuthStatus.authenticated &&
        authProvider.token != null) {
      if (!mounted) return;
      context.read<NotificationProvider>().init(
        authProvider.token!,
        context.read<OrderProvider>(),
      );
    }
  }

  @override
  void dispose() {
    context.read<NotificationProvider>().disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    if (status == AuthStatus.unknown) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (status == AuthStatus.authenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}
