import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import 'routes.dart';
import '../screens/details_screen.dart';
import '../screens/home_shell.dart';
import '../data/auth.dart';

const protectedRoutes = {
  AppRoutes.profile,
  // Add more protected routes here
};

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  refreshListenable: authState,
  redirect: (context, state) {
    final loggedIn = authState.value;
    final goingToProtected = protectedRoutes.contains(state.matchedLocation);
    final onLoginPage = state.matchedLocation == AppRoutes.login;
    if (goingToProtected && !loggedIn) {
      return '${AppRoutes.login}?from=${state.matchedLocation}';
    }
    if (onLoginPage && loggedIn) {
      return AppRoutes.home;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: AppRoutes.detailPattern,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) {
        final from = state.uri.queryParameters['from'];
        return LoginScreen(from: from);
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);
