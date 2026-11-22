import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/shared_prefs_helper.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

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

/// Bridges BLoC Stream to GoRouter's Listenable for reactive navigation.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(
    AuthBloc authBloc,
    SharedPrefsHelper sharedPrefsHelper,
  ) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final currentLocation = state.matchedLocation;

        final isSplash = currentLocation == AppRoutes.splash;
        final isAuthRoute = currentLocation == AppRoutes.login ||
            currentLocation == AppRoutes.register ||
            currentLocation == AppRoutes.forgotPassword;
        final isOnboarding = currentLocation == AppRoutes.onboarding;

        // While on splash screen, let the splash animation run its course
        if (isSplash) {
          return null;
        }

        // 1. Authenticated: redirect away from auth & onboarding screens to Home
        if (authState is Authenticated) {
          if (isAuthRoute || isOnboarding) {
            return AppRoutes.home;
          }
          return null;
        }

        // 2. Unauthenticated: protect private routes (Home, Profile, etc.)
        if (authState is Unauthenticated || authState is AuthError) {
          final isProtectedRoute = currentLocation == AppRoutes.home ||
              currentLocation == AppRoutes.profile ||
              currentLocation == AppRoutes.editProfile;

          if (isProtectedRoute) {
            final hasSeenOnboarding = sharedPrefsHelper.getHasSeenOnboarding();
            return hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding;
          }
          return null;
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
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
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
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person, color: Color(0xFFFFC107)),
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.movie_creation_outlined, color: Color(0xFFFFC107), size: 80),
              const SizedBox(height: 16),
              const Text(
                'Home — Movies',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Movie discovery feature is developed by another team member.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.profile),
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('View User Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
