import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/pages/login_screen.dart';
import 'package:pharm/pages/setting.dart';
import 'package:pharm/pages/user/add_user_screen.dart';
import 'package:pharm/pages/user/view_user_screen.dart';

import '../pages/splash.dart';

// ignore: non_constant_identifier_names
final LOGIN = '/login';
// ignore: non_constant_identifier_names
final ADD_USER = '/add_user';
// ignore: non_constant_identifier_names
final VIEW_USER = '/view_user';
// ignore: non_constant_identifier_names
final ADMIN_SETTINGS = '/admin-settings';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashHome(),
      ),

      GoRoute(
        path: LOGIN,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: ADD_USER,
        builder: (context, state) => const AddUserScreen(),
      ),

      GoRoute(
        path: VIEW_USER,
        builder: (context, state) => const ViewUserScreen(),
      ),

      GoRoute(
        path: ADMIN_SETTINGS,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
