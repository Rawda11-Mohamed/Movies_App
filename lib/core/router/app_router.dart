import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
}

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.onboarding ||
            state.matchedLocation == AppRoutes.forgotPassword ||
            state.matchedLocation == AppRoutes.splash;

        if (authState is Authenticated && isAuthRoute) {
          return AppRoutes.home;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const _HomeShellPlaceholder(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const _ProfilePlaceholder(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const _ProfilePlaceholder(),
        ),
      ],
    );
  }
}

/// Placeholder for profile screen — will be integrated by the profile feature teammate.
class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile feature placeholder', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// Placeholder for home screen — will be replaced by the teammate who owns the home feature.
class _HomeShellPlaceholder extends StatelessWidget {
  const _HomeShellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.movie_creation_outlined, color: Color(0xFFFFC107), size: 80),
            SizedBox(height: 16),
            Text(
              'Home — Coming Soon',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'This screen is owned by another team member.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
