import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screens.dart';
import '../../features/auth/presentation/screens/language_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/customer_onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/onboarding/presentation/screens/owner_onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../../features/onboarding/presentation/screens/store_onboarding_screen.dart';
import '../../features/booking/presentation/screens/booking_screens.dart';
import '../../features/dress/presentation/screens/dress_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_dresses_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_earnings_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_overview_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_profile_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_requests_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_shell.dart';
import '../../features/profile/presentation/screens/profile_screens.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/store_dashboard/presentation/screens/create_store_screen.dart';
import '../../features/store_dashboard/presentation/screens/store_account_screen.dart';
import '../../features/store_dashboard/presentation/screens/store_bookings_calendar_screens.dart';
import '../../features/store_dashboard/presentation/screens/store_inventory_screen.dart';
import '../../features/store_dashboard/presentation/screens/store_more_screens.dart';
import '../../features/store_dashboard/presentation/screens/store_overview_screen.dart';
import '../../features/store_dashboard/presentation/screens/store_shell.dart';
import '../../shared/enums/app_enums.dart';
import '../fake_backend/providers.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();
final _storeShellKey = GlobalKey<NavigatorState>();
final _ownerShellKey = GlobalKey<NavigatorState>();

/// Notifies GoRouter when auth changes without recreating the router.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(authProvider).user;
      final role = user?.role;
      final loc = state.matchedLocation;
      final onboardingPaths = {
        '/onboarding/role',
        '/onboarding/customer',
        '/onboarding/owner',
        '/onboarding/store',
        '/onboarding/complete',
        '/register',
        '/login',
        '/splash',
        '/language',
        '/onboarding',
        '/forgot-password',
        '/otp',
      };

      // Incomplete account setup → role / wizard flow
      if (user != null &&
          !user.isGuest &&
          (!user.onboardingCompleted || user.accountModes.isEmpty) &&
          !onboardingPaths.contains(loc) &&
          !loc.startsWith('/onboarding/')) {
        return '/onboarding/role';
      }

      // Active store experience stays in business shell (multi-mode switch changes role)
      if (role == UserRole.storeOwner) {
        const customerTabs = {'/home', '/search', '/favorites', '/profile'};
        if (customerTabs.contains(loc)) {
          return loc == '/profile' ? '/store/account' : '/store';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/role',
        builder: (_, _) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/customer',
        builder: (_, _) => const CustomerOnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/owner',
        builder: (_, _) => const OwnerOnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/store',
        builder: (_, _) => const StoreOnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/complete',
        builder: (_, state) {
          final next = state.uri.queryParameters['next'] ?? '/home';
          return OnboardingCompleteScreen(nextRoute: next);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) =>
            OtpScreen(phone: state.extra as String? ?? ''),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, _) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: FavoritesScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      // Professional store owner shell — separate from customer tabs
      ShellRoute(
        navigatorKey: _storeShellKey,
        builder: (_, _, child) => StoreShell(child: child),
        routes: [
          GoRoute(
            path: '/store',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StoreOverviewScreen()),
          ),
          GoRoute(
            path: '/store/inventory',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StoreInventoryScreen()),
          ),
          GoRoute(
            path: '/store/bookings',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StoreBookingsScreen()),
          ),
          GoRoute(
            path: '/store/calendar',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StoreCalendarScreen()),
          ),
          GoRoute(
            path: '/store/more',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StoreMoreScreen()),
          ),
          GoRoute(
            path: '/store/account',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StoreAccountScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/store/inventory/add',
        builder: (_, _) => const StoreAddEditDressScreen(),
      ),
      GoRoute(
        path: '/store/inventory/edit/:id',
        builder: (_, state) =>
            StoreAddEditDressScreen(dressId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/store/revenue',
        builder: (_, _) => const StoreRevenueScreen(),
      ),
      GoRoute(
        path: '/store/subscription',
        builder: (_, _) => const StoreSubscriptionScreen(),
      ),
      GoRoute(
        path: '/store/profile',
        builder: (_, _) => const StoreProfileEditScreen(),
      ),
      GoRoute(
        path: '/store/analytics',
        builder: (_, _) => const StoreAnalyticsScreen(),
      ),
      GoRoute(
        path: '/create-store',
        builder: (_, _) => const CreateStoreScreen(),
      ),
      GoRoute(
        path: '/dress/:id',
        builder: (_, state) => DressDetailScreen(
          dressId: state.pathParameters['id']!,
          heroTag: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (_, state) =>
            BookingFlowScreen(dressId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking-confirmation/:id',
        builder: (_, state) => BookingConfirmationScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/bookings',
        builder: (_, _) => const BookingsListScreen(),
      ),
      GoRoute(
        path: '/profile/transactions',
        builder: (_, _) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/profile/addresses',
        builder: (_, _) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/become-owner',
        builder: (_, _) => const BecomeOwnerScreen(),
      ),
      // Personal wardrobe owner shell — distinct from store & customer
      ShellRoute(
        navigatorKey: _ownerShellKey,
        builder: (_, _, child) => OwnerShell(child: child),
        routes: [
          GoRoute(
            path: '/owner',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: OwnerOverviewScreen()),
          ),
          GoRoute(
            path: '/owner/dresses',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: OwnerDressesScreen()),
          ),
          GoRoute(
            path: '/owner/requests',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: OwnerRequestsScreen()),
          ),
          GoRoute(
            path: '/owner/earnings',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: OwnerEarningsScreen()),
          ),
          GoRoute(
            path: '/owner/profile',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: OwnerProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/owner/add-dress',
        builder: (_, _) => const OwnerAddEditDressScreen(),
      ),
      GoRoute(
        path: '/owner/edit-dress/:id',
        builder: (_, state) =>
            OwnerAddEditDressScreen(dressId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/owner/history',
        builder: (_, _) => const OwnerHistoryScreen(),
      ),
    ],
  );
});
