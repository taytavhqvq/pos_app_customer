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
import 'screens/splash/splash_screen.dart';

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
  // เพิ่มบรรทัดนี้ — เก็บ reference ไว้ตั้งแต่ตอน context ยังปลอดภัย
  late final NotificationProvider _notificationProvider;
  bool _minSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    // เก็บ reference ตรงนี้ (context ยังใช้ได้ปกติ)
    _notificationProvider = context.read<NotificationProvider>();
    _init();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _minSplashElapsed = true);
    });
  }

  Future<void> _init() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();

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
    // ใช้ reference ที่เก็บไว้ ไม่ lookup context ใหม่
    _notificationProvider.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    if (status == AuthStatus.unknown || !_minSplashElapsed) {
      return const SplashScreen();
    }
    if (status == AuthStatus.authenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}
