import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/pages/bill/billing_page.dart';
import 'package:pharm/pages/bill/view_bill_page.dart';
import 'package:pharm/pages/login_screen.dart';
import 'package:pharm/pages/setting.dart';
import 'package:pharm/pages/stock/add_stock.dart';
import 'package:pharm/pages/stock/list_stock.dart';
import 'package:pharm/pages/user/add_user_screen.dart';
import 'package:pharm/pages/user/user_list_page.dart';

import '../pages/splash.dart';
// ignore_for_file: non_constant_identifier_names
final LOGIN = '/login';
final ADD_USER = '/add_user';
final VIEW_USER = '/view_user';
final ADMIN_SETTINGS = '/admin-settings';
final ADD_STOCK = '/add-stock';
final VIEW_STOCK = '/view-stock';
final BILLING_PAGE = '/billing-page';
final VIEW_BILLING_PAGE = '/view-billing-page';


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
        builder: (context, state) =>  AddUserPage(),
      ),

      GoRoute(
        path: VIEW_USER,
        builder: (context, state) =>  UserListPage(),
      ),

      GoRoute(
        path: ADMIN_SETTINGS,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
          path: ADD_STOCK,
          builder: (context, state) => AddStockPage(),
      ),

      GoRoute(
        path: VIEW_STOCK,
        builder: (context, state) => const ListStockPage(),
      ),
      GoRoute(
        path: BILLING_PAGE,
        builder: (context, state) =>  BillingPage(),
      ),
      GoRoute(path: VIEW_BILLING_PAGE, builder: (context, state) => const BillTable()),
    ],
  );
});
