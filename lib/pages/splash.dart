import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/provider/router_provider.dart';

class SplashHome extends StatelessWidget {
  const SplashHome({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        GoRouter.of(context).go(LOGIN);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'PHARM',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
