import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import '../fake_backend/providers.dart';

/// Post-login home for the user's *active* experience role.
String homeRouteForRole(UserRole? role) {
  switch (role) {
    case UserRole.storeOwner:
      return '/store';
    case UserRole.individualOwner:
      return '/owner';
    case UserRole.customer:
    case UserRole.guest:
    case null:
      return '/home';
  }
}

/// After login / register — unfinished onboarding goes to role selection.
String homeRouteForUser(AppUser? user) {
  if (user == null) return '/login';
  if (user.isGuest) return '/home';
  if (!user.onboardingCompleted || user.accountModes.isEmpty) {
    return '/onboarding/role';
  }
  return homeRouteForRole(user.role);
}

String homeRouteFromRef(WidgetRef ref) {
  return homeRouteForUser(ref.read(authProvider).user);
}
