import 'package:burnrate/presentation/providers/credential_providers.dart';
import 'package:burnrate/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:burnrate/presentation/screens/onboarding/credential_input_screen.dart';
import 'package:burnrate/presentation/screens/onboarding/service_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding/select',
    redirect: (context, state) {
      final onboardingDone = ref.read(onboardingCompleteProvider);
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');

      if (onboardingDone && isOnboarding) return '/dashboard';
      if (!onboardingDone && !isOnboarding) return '/onboarding/select';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding/select',
        builder: (context, state) => const ServiceSelectorScreen(),
      ),
      GoRoute(
        path: '/onboarding/credentials',
        builder: (context, state) {
          final remaining = state.extra as List<String>;
          return CredentialInputScreen(remaining: remaining);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
